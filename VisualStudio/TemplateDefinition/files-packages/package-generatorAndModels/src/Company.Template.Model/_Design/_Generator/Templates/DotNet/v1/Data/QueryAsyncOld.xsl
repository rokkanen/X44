<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../dbTypes.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>

  <xsl:param name="filename"/>

  <xsl:variable name="namespace"><xsl:value-of select="/Model/@namespace"/></xsl:variable>

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>
{
    using Dapper;
    using log4net;
    using Model;
    using System;
    using System.Collections.Generic;
    using System.Configuration;
    using System.Data;
    using System.Data.SqlClient;
    using System.Linq;
    using System.Threading.Tasks;
  </xsl:template>

  <xsl:template match='/'>       
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    <xsl:apply-templates select="//Query" mode="multi"/>
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template match="Query" mode="multi">
    <xsl:call-template name="body"/>
  </xsl:template>

  <xsl:template match="Query">
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    <xsl:call-template name="body"/>
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template name="body">
    <xsl:variable name="query"><xsl:value-of select="@name"/></xsl:variable>
    <xsl:variable name="code"><xsl:value-of select="Code"/></xsl:variable>
    <xsl:variable name="db"><xsl:value-of select="@type"/></xsl:variable>
    <xsl:variable name="adonetConnexion">
      <xsl:choose>
        <xsl:when test="$db='Oracle'">Oracle.ManagedDataAccess.Client.OracleConnection</xsl:when>
        <xsl:when test="$db='SqlServer'">System.Data.SqlClient.SqlConnection</xsl:when>
        <xsl:otherwise>System.Data.SqlClient.SqlConnection</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="contains($code,'SELECT') or contains($code,'select') or contains($code,'Select') ">
        <xsl:call-template name="querySelect">
          <xsl:with-param name="queryName"><xsl:value-of select="$query"/></xsl:with-param>
          <xsl:with-param name="sql"><xsl:value-of select="$code"/></xsl:with-param>
          <xsl:with-param name="connexion"><xsl:value-of select="@connexion"/></xsl:with-param>      
          <xsl:with-param name="connexionType"><xsl:value-of select="$adonetConnexion"/></xsl:with-param>      
        </xsl:call-template>        
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="queryStoredprocedure">
          <xsl:with-param name="queryName"><xsl:value-of select="$query"/></xsl:with-param>
          <xsl:with-param name="sql"><xsl:value-of select="$code"/></xsl:with-param>
          <xsl:with-param name="connexion"><xsl:value-of select="@connexion"/></xsl:with-param>      
          <xsl:with-param name="connexionType"><xsl:value-of select="$adonetConnexion"/></xsl:with-param>      
        </xsl:call-template>                
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>

  <xsl:template name="queryStoredprocedure">
    <xsl:param name="queryName"/>
    <xsl:param name="sql"/>
    <xsl:param name="connexion"/>
    <xsl:param name="connexionType"/>
    <xsl:variable name="response">IEnumerable&lt;<xsl:value-of select="@response"/>&gt;</xsl:variable>
    <xsl:variable name="dto"><xsl:value-of select="@response"/></xsl:variable>
    <xsl:variable name="db"><xsl:value-of select="@type"/></xsl:variable>
    <xsl:variable name="connexionString">
      <xsl:choose>
        <xsl:when test="$connexion=''">connectionString</xsl:when>
        <xsl:otherwise><xsl:value-of select="$connexion"/></xsl:otherwise>
      </xsl:choose>      
    </xsl:variable>    
    
    <xsl:variable name="dynamicParameter">
      <xsl:choose>
        <xsl:when test="$db='Oracle'">OracleDynamicParameters</xsl:when>
        <xsl:when test="$db='SqlServer'">DynamicParameters</xsl:when>
        <xsl:otherwise>DynamicParameters</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="parameterCall"><xsl:if test="//Query[@name=$queryName]/Parameters/Parameter"><xsl:apply-templates select="//Query[@name=$queryName]/Parameters" mode="storeprocedure" /></xsl:if></xsl:variable>
    public partial class <xsl:value-of select="$queryName"/>: IQueryAsync&lt;<xsl:value-of select="$response"/>&gt;
    {<xsl:apply-templates select="//Query[@name=$queryName]/Parameters" mode="classParameter"/>            
        private readonly ILog _log = LogManager.GetLogger(typeof(<xsl:value-of select="$queryName"/>));
        public bool Ok { get {return _ok;}}
        public string ErrorMessage { get {return _errorMessage;}}                
        private string _connectionString = ConfigurationManager.AppSettings["<xsl:value-of select="$connexionString"/>"];
        public Task&lt;<xsl:value-of select="$response"/>&gt; Result {get; private set;}
        private bool _ok = true;
        private string _errorMessage = "";
        <xsl:if test="//Query[@name=$queryName]/Parameters">public QueryParameter Parameter {get; set;}
        </xsl:if>                    
        public <xsl:value-of select="$queryName"/>()
        {<xsl:if test="//Query[@name=$queryName]/Parameters">
            this.Parameter = new QueryParameter();</xsl:if>
        }        
        
        public async void Execute()
        {              
            try
            {
                using (PerformanceTrace perf = new PerformanceTrace("<xsl:value-of select="$queryName"/>", _log))
                {
                    using (IDbConnection conn = new <xsl:value-of select="$connexionType"/>(_connectionString))
                    {     
                        var param = new <xsl:value-of select="$dynamicParameter"/>();
                        <xsl:value-of select="$parameterCall"/>                        
                        this.Result = conn.QueryAsync&lt;<xsl:value-of select="$dto"/>&gt;("<xsl:value-of select="$sql"/>", param, commandType: CommandType.StoredProcedure);                
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

 <xsl:template name="querySelect">
    <xsl:param name="queryName"/>
    <xsl:param name="sql"/>
    <xsl:param name="connexion"/>
    <xsl:param name="connexionType"/>
    <xsl:variable name="response">IEnumerable&lt;<xsl:value-of select="@response"/>&gt;</xsl:variable>
    <xsl:variable name="dto"><xsl:value-of select="@response"/></xsl:variable>   
    <xsl:variable name="connexionString">
      <xsl:choose>
        <xsl:when test="$connexion=''">connectionString</xsl:when>
        <xsl:otherwise><xsl:value-of select="$connexion"/></xsl:otherwise>
      </xsl:choose>      
    </xsl:variable>    
    <xsl:variable name="parameterDeclaration">
      <xsl:if test="//Query[@name=$queryName]/Parameters/Parameter">
            var param = new DynamicParameters();
      </xsl:if>      
    </xsl:variable>
    <xsl:variable name="parameterCall"><xsl:if test="//Query[@name=$queryName]/Parameters/Parameter"><xsl:apply-templates select="//Query[@name=$queryName]/Parameters" mode="select" /></xsl:if></xsl:variable>
    <xsl:variable name="query">
      <xsl:choose>
        <xsl:when test="//Query[@name=$queryName]/Parameters/Parameter">
                        conn.Open();<xsl:value-of select="$parameterCall"/>
                        this.Result = conn.QueryAsync&lt;<xsl:value-of select="$dto"/>&gt;(sql, param);
        </xsl:when>
        <xsl:otherwise>
                        conn.Open();
                        this.Result = conn.QueryAsync&lt;<xsl:value-of select="$dto"/>&gt;(sql);
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    public partial class <xsl:value-of select="$queryName"/>: IQueryAsync&lt;<xsl:value-of select="$response"/>&gt;
    {<xsl:apply-templates select="//Query[@name=$queryName]/Parameters" mode="classParameter"/>            
        private readonly ILog _log = LogManager.GetLogger(typeof(<xsl:value-of select="$queryName"/>));
        public bool Ok { get {return _ok;}}
        public string ErrorMessage { get {return _errorMessage;}}                
        private string _connectionString = ConfigurationManager.AppSettings["<xsl:value-of select="$connexionString"/>"];
        public Task&lt;<xsl:value-of select="$response"/>&gt; Result {get; private set;}
        private bool _ok = true;
        private string _errorMessage = "";
        <xsl:if test="//Query[@name=$queryName]/Parameters">public QueryParameter Parameter {get; set;}</xsl:if>                
        public <xsl:value-of select="$queryName"/>()
        {<xsl:if test="//Query[@name=$queryName]/Parameters">
            this.Parameter = new QueryParameter();</xsl:if>
        }        
        
        public async void Execute()
        {              
            string sql = @"<xsl:value-of select="$sql"/>";<xsl:value-of select="$parameterDeclaration"/>
            try
            {
                using (PerformanceTrace perf = new PerformanceTrace("<xsl:value-of select="$queryName"/>", _log))
                {
                    using (IDbConnection conn = new <xsl:value-of select="$connexionType"/>(_connectionString))
                    {<xsl:value-of select="$query"/>
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


 <xsl:template match="Parameter" mode="select">                
    <xsl:variable name="parameter">
      <xsl:choose>
        <xsl:when test="@name = 'Parameter'">Parameter</xsl:when>
        <xsl:otherwise>Parameter.<xsl:value-of select="@name"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
                        param.Add("<xsl:value-of select="@name"/>", <xsl:value-of select="$parameter"/>, dbType: DbType.<xsl:value-of select="@type"/>);</xsl:template>       

  <xsl:template match="Parameter" mode="storeprocedure">
     <xsl:variable name="db"><xsl:value-of select="@type"/></xsl:variable>
    <xsl:variable name="parameter">
      <xsl:choose>
        <xsl:when test="@name = 'Parameter'">Parameter</xsl:when>
        <xsl:otherwise>Parameter.<xsl:value-of select="@name"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="direction">
      <xsl:choose>
        <xsl:when test="@name = 'Result'">direction: ParameterDirection.Output</xsl:when>
        <xsl:otherwise>direction: ParameterDirection.Input</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="typeParam">
      <xsl:call-template name="getType">
        <xsl:with-param name="type"><xsl:value-of select="@type"/></xsl:with-param>
        <xsl:with-param name="db"><xsl:value-of select="$db"/></xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="dbType">
      <xsl:choose>
        <xsl:when test="$db='Oracle'">OracleDbType</xsl:when>
        <xsl:when test="$db='SqlServer'">DbType</xsl:when>
        <xsl:otherwise>DbType</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="paramAdd">
      <xsl:choose>
        <xsl:when test="@name = 'Result'">                
                        param.Add("<xsl:value-of select="@mapping"/>", dbType: <xsl:value-of select="$dbType"/>.<xsl:value-of select="$typeParam"/>, <xsl:value-of select="$direction"/>);</xsl:when>
        <xsl:otherwise>                
                        param.Add("<xsl:value-of select="@mapping"/>", dbType: <xsl:value-of select="$dbType"/>.<xsl:value-of select="$typeParam"/>, <xsl:value-of select="$direction"/>, value:Parameter.<xsl:value-of select="@name"/> );</xsl:otherwise>
      </xsl:choose>
    </xsl:variable><xsl:value-of select="$paramAdd"/>
  </xsl:template>
  <xsl:template match="Parameters" mode="classParameter">
        public class QueryParameter
        {<xsl:apply-templates select="Parameter" mode="classParameter"/>
        }
  </xsl:template>

  <xsl:template match="Parameter" mode="classParameter">
            public <xsl:value-of select="@type"/>&#160;<xsl:value-of select="@name"/>&#160;{get; set;}</xsl:template>
    
  <xsl:template name="footer">      
}
  </xsl:template>

</xsl:stylesheet>
