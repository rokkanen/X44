<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>
  
  <xsl:variable name="namespace"><xsl:value-of select="/QueryModel/@namespace"/></xsl:variable>
  <xsl:variable name="dbNameContext">DatabaseContext</xsl:variable>
  
  <xsl:param name="CustomQueries" select="document($QueriesFile)"/>

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Data
{
    using AutoMapper;
    using Dapper;
    using log4net;
    using Model;
    using System;
    using System.Collections.Generic;
    using System.Configuration;
    using System.Data;
    using System.Data.Entity;
    using System.Data.SqlClient;
    using System.Linq;
    using System.Threading.Tasks;
    #pragma warning disable // Disable all warnings
    <xsl:value-of select="$attributeGenerator"/>
  </xsl:template>

  <xsl:template match='/'>       
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
      <xsl:with-param name="xslTemplate" select="$xslTemplate"/>
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    <xsl:apply-templates select="//Entity" mode="multi"/>
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template match="Entity" mode="multi">
    <xsl:call-template name="body"/>
  </xsl:template>

  <xsl:template match="Entity">
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
      <xsl:with-param name="xslTemplate" select="$xslTemplate"/>
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    <xsl:call-template name="body"/>
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template name="body">
    <xsl:variable name="findAllQuery">FindAll<xsl:value-of select="@pluralName"/>Query</xsl:variable>
    <xsl:variable name="findByIdQuery">FindBy<xsl:value-of select="@name"/>IdQuery</xsl:variable>
    <xsl:variable name="findByNameQuery">FindBy<xsl:value-of select="@name"/>NameQuery</xsl:variable>    
    <xsl:variable name="typeId"><xsl:value-of select="Properties/Property[@propertyType = 1]/@type"/></xsl:variable>
    <xsl:variable name="id"><xsl:value-of select="@name"/>Id</xsl:variable>
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>            
    </xsl:variable>
    <xsl:variable name="overrideQuery1"><xsl:value-of select="$CustomQueries//QueryModel/Queries/Query[@name=$findAllQuery]/Code"/></xsl:variable>
    
    <xsl:if test="$selected=1">
      <xsl:choose>
        <xsl:when test="$overrideQuery1=''">
          <xsl:call-template name="queryClass">
            <xsl:with-param name="queryName"><xsl:value-of select="$findAllQuery"/></xsl:with-param>
            <xsl:with-param name="queryCode">var result = _dbContext.<xsl:value-of select="@pluralName"/>.ToList();</xsl:with-param>
          </xsl:call-template>                
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="queryClassDapper">
            <xsl:with-param name="queryName"><xsl:value-of select="$findAllQuery"/></xsl:with-param>
            <xsl:with-param name="sql"><xsl:value-of select="$overrideQuery1"/></xsl:with-param>
            <xsl:with-param name="dto"><xsl:value-of select="$CustomQueries//QueryModel/Queries/Query[@name=$findAllQuery]/@entity"/></xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
                  
      <xsl:call-template name="queryClass">
        <xsl:with-param name="queryName"><xsl:value-of select="$findByIdQuery"/></xsl:with-param>
        <xsl:with-param name="queryCode">var result = _dbContext.<xsl:value-of select="@pluralName"/>
                                         .Where(item => item.<xsl:value-of select="$id"/>.Equals(Parameter.<xsl:value-of select="$id"/>))
                                         .ToList();
        </xsl:with-param>
      </xsl:call-template>
      
      <xsl:call-template name="queryClass">
        <xsl:with-param name="queryName"><xsl:value-of select="$findByNameQuery"/></xsl:with-param>
        <xsl:with-param name="queryCode">var result = _dbContext.<xsl:value-of select="@pluralName"/>.ToList();</xsl:with-param>
      </xsl:call-template>
    </xsl:if>    
    </xsl:template>

  <xsl:template match="RelationShip" mode="oneToMany">
    <xsl:variable name="findRelatedQuery">FindRelated<xsl:value-of select="@name"/>Query</xsl:variable>
    <xsl:variable name="entityId"><xsl:value-of select="../../@name"/>Id</xsl:variable>
    <xsl:variable name="typeId"><xsl:value-of select="../../Properties/Property[@propertyType = 1]/@type"/></xsl:variable>        
    <xsl:call-template name="queryClass">
      <xsl:with-param name="queryName"><xsl:value-of select="$findRelatedQuery"/></xsl:with-param>
      <xsl:with-param name="queryCode">var result = _dbContext.<xsl:value-of select="@pluralName"/>.ToList();</xsl:with-param>
    </xsl:call-template>    
  </xsl:template>

  <xsl:template name="queryClass">
    <xsl:param name="queryName"/>
    <xsl:param name="queryCode"/>
    <xsl:variable name="dto"><xsl:value-of select="@name"/>Info</xsl:variable>
    <xsl:variable name="response"><xsl:value-of select="$dto"/>Response</xsl:variable>
    public partial class <xsl:value-of select="$queryName"/>: IQuery&lt;<xsl:value-of select="$dto"/>,<xsl:value-of select="$response"/>&gt;
    {
        private readonly ILog _log = LogManager.GetLogger(typeof(<xsl:value-of select="$queryName"/>));
        public bool Ok { get {return _ok;}}
        public string ErrorMessage { get {return _errorMessage;}}        
        private readonly <xsl:value-of select="$dbNameContext"/> _dbContext = new <xsl:value-of select="$dbNameContext"/>();
        public <xsl:value-of select="$dto"/> Parameter {get; private set;}
        public <xsl:value-of select="$response"/> Response {get; private set;}
        private bool _ok = true;
        private string _errorMessage = "";
                
        public <xsl:value-of select="$queryName"/>()
        {
            this.Parameter = new <xsl:value-of select="$dto"/>();
            this.Response  = new <xsl:value-of select="$response"/>();
        }

        public void Execute()
        {            
            try
            {
                using (PerformanceTrace perf = new PerformanceTrace("<xsl:value-of select="$queryName"/>", _log))
                {
                    <xsl:value-of select="$queryCode"/>

                    // Transform Business entity to Dto
                    var dto = Mapper.Map&lt;IEnumerable&lt;<xsl:value-of select="$dto"/>&gt;&gt;(result);
                    this.Response.entries = dto;
                }
            }
            catch (Exception ex)
            {
                _ok = false;
                _errorMessage = ex.Message.ToString();            
                _log.Error(ex);
            }                                                         
        }                
    }</xsl:template>
  
    <xsl:template name="queryClassDapper">
    <xsl:param name="queryName"/>
    <xsl:param name="sql"/>
    <xsl:param name="dto"/>
    <xsl:variable name="response"><xsl:value-of select="$dto"/>Response</xsl:variable>      
    public partial class <xsl:value-of select="$queryName"/>: IQuery&lt;<xsl:value-of select="$dto"/>,<xsl:value-of select="$response"/>&gt;
    {
        private readonly ILog _log = LogManager.GetLogger(typeof(<xsl:value-of select="$queryName"/>));
        public bool Ok { get {return _ok;}}        
        private string _connectionString = ConfigurationManager.ConnectionStrings["connectionString"].ConnectionString;
        public <xsl:value-of select="$dto"/> Parameter {get; private set;}
        public <xsl:value-of select="$response"/> Response {get; private set;}
        private bool _ok = true;
        private string _errorMessage = "";
        
        public <xsl:value-of select="$queryName"/>()
        {
            this.Parameter = new <xsl:value-of select="$dto"/>();
            this.Response  = new <xsl:value-of select="$response"/>();
        }        
        
        public void Execute()
        {              
            string sql = @"<xsl:value-of select="$sql"/>";        
            try
            {
                using (PerformanceTrace perf = new PerformanceTrace("<xsl:value-of select="$queryName"/>", _log))
                {
                    using (IDbConnection db = new SqlConnection(_connectionString))
                    {
                        var result = db.Query&lt;<xsl:value-of select="$dto"/>&gt;(sql).AsList();
                        this.Response.entries = result;                    
                    }
                }
            }
            catch (Exception ex)
            {
                _ok = false;
                _errorMessage = ex.Message.ToString();                                    
                _log.Error(ex);
            }                                                         
        }                
    }</xsl:template>
  
  <xsl:template name="footer">
}
  </xsl:template>

</xsl:stylesheet>
