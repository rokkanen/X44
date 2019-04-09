<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../dbTypes.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>

  <xsl:variable name="namespace"><xsl:value-of select="/CommandModel/@namespace"/></xsl:variable>
  
  <xsl:variable name="string">Varchar2</xsl:variable>
  <xsl:variable name="XmlDocument">XmlType</xsl:variable>
  <xsl:variable name="DateTime">Date</xsl:variable>  

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
    #pragma warning disable // Disable all warnings
    <xsl:value-of select="$attributeGenerator"/>
  </xsl:template>

  <xsl:template match='/'>       
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
      <xsl:with-param name="xslTemplate" select="$xslTemplate"/>
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    <xsl:apply-templates select="//Command" mode="multi"/>
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template match="Command" mode="multi">
    <xsl:call-template name="body"/>
  </xsl:template>

  <xsl:template match="Command">
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
      <xsl:with-param name="xslTemplate" select="$xslTemplate"/>
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    <xsl:call-template name="body"/>
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template name="body">
    <xsl:variable name="command"><xsl:value-of select="@name"/></xsl:variable>
    <xsl:variable name="code"><xsl:value-of select="Code"/></xsl:variable>
    <xsl:variable name="dto"><xsl:value-of select="@response"/></xsl:variable>
    <xsl:variable name="db"><xsl:value-of select="@type"/></xsl:variable>
    <xsl:variable name="adonetConnexion">
      <xsl:choose>
        <xsl:when test="$db='Oracle'">Oracle.ManagedDataAccess.Client.OracleConnection</xsl:when>
        <xsl:when test="$db='SqlServer'">System.Data.SqlClient.SqlConnection</xsl:when>
        <xsl:otherwise>System.Data.SqlClient.SqlConnection</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="starts-with($code,'INSERT') or starts-with($code,'DELETE') or starts-with($code,'UPDATE') or starts-with($code,'insert') or starts-with($code,'delete') or starts-with($code,'update')  or starts-with($code,'Insert') or starts-with($code,'Delete') or starts-with($code,'Update')">
      <!-- Not Supported-->
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="commandStoredprocedure">
          <xsl:with-param name="commandName"><xsl:value-of select="$command"/></xsl:with-param>
          <xsl:with-param name="sql"><xsl:value-of select="$code"/></xsl:with-param>
          <xsl:with-param name="dto"><xsl:value-of select="$dto"/></xsl:with-param>
          <xsl:with-param name="connexion"><xsl:value-of select="@connexion"/></xsl:with-param>      
          <xsl:with-param name="connexionType"><xsl:value-of select="$adonetConnexion"/></xsl:with-param>      
        </xsl:call-template>                
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>

  <xsl:template name="commandStoredprocedure">
    <xsl:param name="commandName"/>
    <xsl:param name="sql"/>
    <xsl:param name="dto"/>
    <xsl:param name="connexion"/>
    <xsl:param name="connexionType"/>
    <xsl:variable name="db"><xsl:value-of select="@type"/></xsl:variable>
    <xsl:variable name="response"><xsl:value-of select="@resultType"/></xsl:variable>
    <xsl:variable name="hasParameters"><xsl:value-of select="//Command[@name=$commandName]/Parameters"/></xsl:variable>
    <xsl:variable name="resultParameter"><xsl:value-of select="//Command[@name=$commandName]/Parameters/Parameter[@name='Result']/@mapping"/></xsl:variable>
    <xsl:variable name="resultParameterType"><xsl:value-of select="//Command[@name=$commandName]/Parameters/Parameter[@name='Result']/@type"/></xsl:variable>
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
    <xsl:variable name="parameterCall"><xsl:if test="//Command[@name=$commandName]/Parameters/Parameter"><xsl:apply-templates select="//Command[@name=$commandName]/Parameters" mode="storeprocedure" /></xsl:if></xsl:variable>
    public partial class <xsl:value-of select="$commandName"/>Command: ICommand
    {   <xsl:apply-templates select="//Command[@name=$commandName]/Parameters" mode="classParameter"/>
        <xsl:if test="//Command[@name=$commandName]/Parameters">      public CommandParameter Parameter {get; private set;}</xsl:if>
        public bool Ok { get {return _ok;}}
        public string ErrorMessage { get {return _errorMessage;}}                
        public Int64 Result {get; private set;}
        private bool _ok = true;
        private string _errorMessage = "";
        private readonly ILog _log = LogManager.GetLogger(typeof(<xsl:value-of select="$commandName"/>Command));
        private string _connectionString = ConfigurationManager.AppSettings["<xsl:value-of select="$connexionString"/>"];
                
        public <xsl:value-of select="$commandName"/>Command()
        {<xsl:if test="//Command[@name=$commandName]/Parameters">
            this.Parameter = new CommandParameter();</xsl:if>
        }   
        
        public async void Execute()
        { 
            string sql = "<xsl:value-of select="$sql"/>";
            var param = new <xsl:value-of select="$dynamicParameter"/>();
            
            try
            {
                using (PerformanceTrace perf = new PerformanceTrace("<xsl:value-of select="$commandName"/>", _log))
                {
                    using (var conn = new <xsl:value-of select="$connexionType"/>(_connectionString))
                    {     
                        conn.Open();<xsl:value-of select="$parameterCall"/>                        
                        this.Result = await conn.ExecuteAsync(sql, param, commandType: CommandType.StoredProcedure);                                                                       
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

 <xsl:template name="commandSQL">
    <xsl:param name="commandName"/>
    <xsl:param name="sql"/>
    <xsl:param name="dto"/>
    <xsl:param name="connexion"/>
    <xsl:param name="connexionType"/>
    <xsl:variable name="response"><xsl:value-of select="@resultType"/></xsl:variable>
    <xsl:variable name="hasParameters"><xsl:value-of select="//Command[@name=$commandName]/Parameters"/></xsl:variable>
    <xsl:variable name="connexionString">
      <xsl:choose>
        <xsl:when test="$connexion=''">connectionString</xsl:when>
        <xsl:otherwise><xsl:value-of select="$connexion"/></xsl:otherwise>
      </xsl:choose>      
    </xsl:variable>    
    <xsl:variable name="parameterDeclaration">
      <xsl:if test="//Command[@name=$commandName]/Parameters/Parameter">
            var param = new DynamicParameters();
      </xsl:if>      
    </xsl:variable>
    <xsl:variable name="parameterCall"><xsl:if test="//Command[@name=$commandName]/Parameters/Parameter"><xsl:apply-templates select="//Command[@name=$commandName]/Parameters" mode="select" /></xsl:if></xsl:variable>
    <xsl:variable name="command">
      <xsl:choose>
        <xsl:when test="//Command[@name=$commandName]/Parameters/Parameter">
                        conn.Open();<xsl:value-of select="$parameterCall"/>
                        this.Result = conn.Query&lt;<xsl:value-of select="$dto"/>&gt;(sql, param);
        </xsl:when>
        <xsl:otherwise>
                        conn.Open();
                        this.Result = conn.Query&lt;<xsl:value-of select="$dto"/>&gt;(sql);
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
   
    public partial class <xsl:value-of select="$commandName"/>: ICommand&lt;IEnumerable&lt;<xsl:value-of select="$response"/>&gt;&gt;
    {   <xsl:apply-templates select="//Command[@name=$commandName]/Parameters" mode="classParameter"/>
        <xsl:if test="//Command[@name=$commandName]/Parameters">      public CommandParameter Parameter {get; private set;}</xsl:if>
        public bool Ok { get {return _ok;}}
        public string ErrorMessage { get {return _errorMessage;}}                
        private string _connectionString = ConfigurationManager.AppSettings["<xsl:value-of select="$connexionString"/>"];
        public IEnumerable&lt;<xsl:value-of select="$response"/>&gt; Result {get; private set;}
        private bool _ok = true;
        private string _errorMessage = "";
        private readonly ILog _log = LogManager.GetLogger(typeof(<xsl:value-of select="$commandName"/>));

        public <xsl:value-of select="$commandName"/>()
        {<xsl:if test="//Command[@name=$commandName]/Parameters">
            this.Parameter = new CommandParameter();</xsl:if>
        }   

        public async void Execute()
        {              
            string sql = @"<xsl:value-of select="$sql"/>";<xsl:value-of select="$parameterDeclaration"/>
            try
            {
                using (PerformanceTrace perf = new PerformanceTrace("<xsl:value-of select="$commandName"/>", _log))
                {
                    using (var conn = new <xsl:value-of select="$connexionType"/>(_connectionString))
                    {
                        <xsl:value-of select="$command"/>
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
        <xsl:when test="@type='XmlDocument' and $db='Oracle'">new Oracle.ManagedDataAccess.Types.OracleXmlType(conn,Parameter.<xsl:value-of select="@name"/>)</xsl:when>
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
                        param.Add("<xsl:value-of select="@mapping"/>", dbType: <xsl:value-of select="$dbType"/>.<xsl:value-of select="$typeParam"/>, <xsl:value-of select="$direction"/>, value:<xsl:value-of select="$parameter"/> );</xsl:otherwise>
      </xsl:choose>
    </xsl:variable><xsl:value-of select="$paramAdd"/>
  </xsl:template>

  <xsl:template match="Parameters" mode="classParameter">
        public class CommandParameter
        {<xsl:apply-templates select="Parameter" mode="classParameter"/>
        }
        
  </xsl:template>

  <xsl:template match="Parameter" mode="classParameter">
     <xsl:variable name="assignProperty">
      <xsl:choose>
        <xsl:when test="@value"> = <xsl:value-of select="@value"/>;</xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
     <xsl:variable name="privateSet">
      <xsl:choose>
        <xsl:when test="@value">private</xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
            public <xsl:value-of select="@type"/>&#160;<xsl:value-of select="@name"/>&#160;{get; <xsl:value-of select="$privateSet"/> set;}<xsl:value-of select="$assignProperty"/>
</xsl:template>

   <xsl:template name="footer">      
}
  </xsl:template>

</xsl:stylesheet>
