<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>

  <xsl:variable name="namespace"><xsl:value-of select="/CommandModel/@namespace"/></xsl:variable>
  <xsl:variable name="dbNameContext">DatabaseContext</xsl:variable>

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Data
{
    using AutoMapper;
    using log4net;
    using Model;
    using System;
    using System.Collections.Generic;
    using System.Data.Entity;
    using System.Linq;
    using System.Security.Principal;
    using System.Threading.Tasks;
    using TrackableEntities;
    using TrackableEntities.EF6;
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
    <xsl:variable name="id"><xsl:value-of select="@name"/>Id</xsl:variable>
    <xsl:variable name="dto"><xsl:value-of select="@name"/>Info</xsl:variable>
    <xsl:variable name="dtos">IEnumerable&lt;<xsl:value-of select="$dto"/>&gt;</xsl:variable>
    <xsl:variable name="typeId"><xsl:value-of select="Properties/Property[@propertyType = 1]/@type"/></xsl:variable>
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">      
      <xsl:call-template name="queryClass">
        <xsl:with-param name="queryName">Save<xsl:value-of select="@name"/>Command</xsl:with-param>
        <xsl:with-param name="input"><xsl:value-of select="$dto"/></xsl:with-param>
        <xsl:with-param name="map">// Transform Dto to Business entity
                    var entity = Mapper.Map&lt;<xsl:value-of select="@name"/>&gt;(Parameter);</xsl:with-param>        
        <xsl:with-param name="returnValue1">public <xsl:value-of select="$dto"/> Result { get; private set; }
        </xsl:with-param>
        <xsl:with-param name="returnValue2">
                    // Transform Business entity to Dto
                    this.Result = Mapper.Map&lt;<xsl:value-of select="$dto"/>&gt;(entity);</xsl:with-param>
        <xsl:with-param name="queryCode">
          
                    if (entity.TrackingState == TrackingState.Added)
                    {
                        entity.CreationDate = DateTime.UtcNow;
                        entity.CreatedBy = WindowsIdentity.GetCurrent().Name;
                    }
                    else
                    {
                        entity.UpdatedDate = DateTime.UtcNow;
                        entity.UpdateBy = WindowsIdentity.GetCurrent().Name;
                    }    
                    
                    _dbContext.ApplyChanges(entity);
                    _dbContext.SaveChanges();
        </xsl:with-param>
      </xsl:call-template>
      
      <xsl:call-template name="queryClass">
        <xsl:with-param name="queryName">Save<xsl:value-of select="@pluralName"/>Command</xsl:with-param>
        <xsl:with-param name="input"><xsl:value-of select="$dtos"/></xsl:with-param>
        <xsl:with-param name="map">var entities = Mapper.Map&lt;IEnumerable&lt;<xsl:value-of select="@name"/>&gt;&gt;(Parameter);</xsl:with-param>        
        <xsl:with-param name="queryCode">
                    
                    foreach (var entity in entities)
                    {
                        if (entity.TrackingState == TrackingState.Added)
                        {
                            entity.CreationDate = DateTime.UtcNow;
                            entity.CreatedBy = WindowsIdentity.GetCurrent().Name;
                        }
                        else
                        {
                            entity.UpdatedDate = DateTime.UtcNow;
                            entity.UpdateBy = WindowsIdentity.GetCurrent().Name;
                        }    
                        
                        _dbContext.ApplyChanges(entity);
                    }
            
                    _dbContext.SaveChanges();</xsl:with-param>
      </xsl:call-template>

      <xsl:call-template name="queryClass">
        <xsl:with-param name="queryName">Delete<xsl:value-of select="@name"/>Command</xsl:with-param>
        <xsl:with-param name="input"><xsl:value-of select="$typeId"/></xsl:with-param>
        <xsl:with-param name="map"></xsl:with-param>                
        <xsl:with-param name="queryCode"><xsl:value-of select="@name"/> entity = _dbContext.<xsl:value-of select="@pluralName"/>.SingleOrDefault(item => item.<xsl:value-of select="@name"/>Id.Equals(Parameter));

                    if (entity != null)
                    {
                        entity.TrackingState = TrackingState.Deleted;
                        _dbContext.ApplyChanges(entity);
                        _dbContext.SaveChanges();
                    }</xsl:with-param>
      </xsl:call-template>
       
    </xsl:if>    
    </xsl:template>

  <xsl:template match="RelationShip" mode="oneToMany">
    <xsl:variable name="entityId"><xsl:value-of select="../../@name"/>Id</xsl:variable>
    <xsl:call-template name="queryClass">
      <xsl:with-param name="queryName">FindRelated<xsl:value-of select="@name"/>Query</xsl:with-param>
      <xsl:with-param name="queryCode">var result = _dbContext.<xsl:value-of select="@pluralName"/>.Project().ToList();</xsl:with-param>
    </xsl:call-template>    
  </xsl:template>

  <xsl:template name="queryClass">
    <xsl:param name="queryName"/>
    <xsl:param name="queryCode"/>
    <xsl:param name="input"/>
    <xsl:param name="returnValue1"/>
    <xsl:param name="returnValue2"/>
    <xsl:param name="map"/>
    public partial class <xsl:value-of select="$queryName"/> : ICommand&lt;<xsl:value-of select="$input"/>&gt;
    {
        public <xsl:value-of select="$input"/> Parameter {get; set;}
        public bool Ok { get {return _ok;}}
        public string ErrorMessage { get {return _errorMessage;}}
        <xsl:value-of select="$returnValue1"/>
        private readonly ILog _log = LogManager.GetLogger(typeof(<xsl:value-of select="$queryName"/>));
        private readonly <xsl:value-of select="$dbNameContext"/> _dbContext = new <xsl:value-of select="$dbNameContext"/>();
        private bool _ok = true;
        private string _errorMessage = "";
        
        public void Execute()
        {            
            try
            {
                using (PerformanceTrace perf = new PerformanceTrace("<xsl:value-of select="$queryName"/>", _log))
                {
                    <xsl:value-of select="$map"/><xsl:value-of select="$queryCode"/><xsl:value-of select="$returnValue2"/>
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
