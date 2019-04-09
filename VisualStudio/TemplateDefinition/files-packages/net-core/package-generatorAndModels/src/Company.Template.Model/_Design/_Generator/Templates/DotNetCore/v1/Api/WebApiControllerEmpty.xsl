<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>

  <xsl:param name="excludeKey">0</xsl:param>
  <xsl:param name="includeEntities"></xsl:param>
  <xsl:param name="excludeEntities"></xsl:param>

  <xsl:variable name="namespace"><xsl:value-of select="/ApiModel/@namespace"/></xsl:variable>
  <xsl:variable name="version">V1</xsl:variable>
  <xsl:variable name="dbNameContext">DatabaseContext</xsl:variable>

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Api
{
    using Business;
    using Infrastructure;
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Net;
    using System.Net.Http;
    using System.Threading.Tasks;
    using log4net;
    using Microsoft.AspNetCore.Mvc;
    using Swashbuckle.AspNetCore.SwaggerGen;
    using Microsoft.Extensions.Configuration;
    #pragma warning disable // Disable all warnings
    <xsl:value-of select="$attributeGenerator"/>
    
  </xsl:template>

  <xsl:template match='/'>
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
      <xsl:with-param name="xslTemplate" select="$xslTemplate"/>
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    <xsl:apply-templates select="//Resource" mode="multi"/>
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template match="Resource" mode="multi">
    <xsl:call-template name="body"/>
  </xsl:template>

  <xsl:template match="Resource">
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
      <xsl:with-param name="xslTemplate" select="$xslTemplate"/>
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    <xsl:call-template name="body"/>
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template name="body">
    [Route("<xsl:value-of select="@routePrefix"/>")] // Prefix
    public partial class <xsl:value-of select="@id"/>Controller : Controller
    {<xsl:call-template name="declaration"/>
    <xsl:apply-templates select="Operations/Operation"/>
    }
  </xsl:template>

  <xsl:template match="Operation">
    <xsl:choose>
      <xsl:when test="@httpMethod='HttpGet'"><xsl:call-template name="http_get_template"/></xsl:when>
      <xsl:when test="@httpMethod='HttpPost'"><xsl:call-template name="http_post_template"/></xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="declaration">
    <xsl:variable name="controller"><xsl:value-of select="@id"/>Controller</xsl:variable>
        private readonly ILog _log = LogManager.GetLogger(typeof(<xsl:value-of select="$controller"/>));
        IConfiguration _config;
        
        public <xsl:value-of select="$controller"/>(IConfiguration config)
        {
            _config = config;
        }
  </xsl:template>
  
   <xsl:template name="http_get_template">  
    <xsl:variable name="routePrefix">/<xsl:value-of select="../../@routePrefix"/>/</xsl:variable>
    <xsl:variable name="entity"><xsl:value-of select="../../@id"/></xsl:variable>     
    <xsl:variable name="entities"><xsl:value-of select="../../@name"/></xsl:variable>
    <xsl:variable name="typeId"><xsl:value-of select="Parameters/Parameter[1]/@type"/></xsl:variable>
    <xsl:variable name="response">IEnumerable&lt;<xsl:value-of select="@responseItem"/>&gt;</xsl:variable>
    <xsl:variable name="queryName"><xsl:value-of select="@query"/></xsl:variable>
    <xsl:variable name="operationName"><xsl:value-of select="@id"/></xsl:variable>
    <xsl:variable name="parameterComment"><xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter" mode="comment" /></xsl:if></xsl:variable>
    <xsl:variable name="parameterCall">
       <xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter" mode="call" /></xsl:if>
    </xsl:variable>
    <xsl:variable name="parameterInitialize">
       <xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter" mode="initialize" /></xsl:if>
    </xsl:variable>
    <xsl:variable name="parameterLogPath">
       <xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter[@in='path']" mode="log" /></xsl:if>
    </xsl:variable>
    <xsl:variable name="parameterLogQuery">
       <xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter[@in='query']" mode="log" /></xsl:if>
    </xsl:variable>   
     <xsl:variable name="endRootUri">
       <xsl:if test="Parameters/Parameter">?</xsl:if>
    </xsl:variable>
    <xsl:variable name="endCodeInit">
       <xsl:if test="Parameters/Parameter">
            urlBuilder.Length--;</xsl:if>
    </xsl:variable>         
        /// &lt;summary&gt;
        /// <xsl:value-of select="Summary"/>
        /// &lt;/summary&gt;
        <xsl:value-of select="$parameterComment"/>      /// &lt;returns>id&lt;/returns&gt;
        [<xsl:value-of select="@httpMethod"/>]
        [Route("<xsl:value-of select="@route"/>")]
        [SwaggerOperation("<xsl:value-of select="@id"/>")]
        [SwaggerResponse((int)HttpStatusCode.OK, Description = "OK, Request succeed.", Type = typeof(<xsl:value-of select="$response"/>))]
        [SwaggerResponse((int)HttpStatusCode.NotFound, Description = "No data for request.", Type = typeof(string))]
        [SwaggerResponse((int)HttpStatusCode.Unauthorized, Description = "Unauthorized, the correct api_key must be specified")]
        [SwaggerResponse((int)HttpStatusCode.BadRequest, Description = "Error in query.")]
        [SwaggerResponse((int)HttpStatusCode.InternalServerError, Description = "Unexpected error.")]
        public async Task&lt;IActionResult&gt; <xsl:value-of select="@name"/>(<xsl:value-of select="$parameterCall"/>)
        {
             return Ok(null);
        }
  </xsl:template>
  
   <xsl:template name="http_post_template">  
    <xsl:variable name="routePrefix">/<xsl:value-of select="../../@routePrefix"/>/</xsl:variable> 
    <xsl:variable name="entity"><xsl:value-of select="../../@id"/></xsl:variable>     
    <xsl:variable name="entities"><xsl:value-of select="../../@name"/></xsl:variable>
    <xsl:variable name="typeId"><xsl:value-of select="Parameters/Parameter[1]/@type"/></xsl:variable>
    <xsl:variable name="response"><xsl:value-of select="@responseItem"/></xsl:variable>
    <xsl:variable name="queryName"><xsl:value-of select="@query"/></xsl:variable>
    <xsl:variable name="operationName"><xsl:value-of select="@id"/></xsl:variable>
    <xsl:variable name="parameterComment"><xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter" mode="comment" /></xsl:if></xsl:variable>
    <xsl:variable name="parameterCall">
       <xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter" mode="call" /></xsl:if>
    </xsl:variable>
    <xsl:variable name="parameterInitialize">
       <xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter" mode="initializeCommand" /></xsl:if>
    </xsl:variable>
    <xsl:variable name="parameterLogPath">
       <xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter[@in='path']" mode="log" /></xsl:if>
    </xsl:variable>
    <xsl:variable name="parameterLogQuery">
       <xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter[@in='query']" mode="log" /></xsl:if>
    </xsl:variable>   
     <xsl:variable name="endRootUri">
       <xsl:if test="Parameters/Parameter">?</xsl:if>
    </xsl:variable>
    <xsl:variable name="endCodeInit">
       <xsl:if test="Parameters/Parameter">
            urlBuilder.Length--;</xsl:if>
    </xsl:variable>    
        /// &lt;summary&gt;
        /// <xsl:value-of select="Summary"/>
        /// &lt;/summary&gt;
        <xsl:value-of select="$parameterComment"/>      /// &lt;returns>id&lt;/returns&gt;
        [<xsl:value-of select="@httpMethod"/>]
        [Route("<xsl:value-of select="@route"/>")]
        [SwaggerOperation("<xsl:value-of select="@id"/>")]
        [SwaggerResponse((int)HttpStatusCode.OK, Description = "OK, Request succeed.", Type = typeof(<xsl:value-of select="$response"/>))]
        [SwaggerResponse((int)HttpStatusCode.Unauthorized, Description = "Unauthorized, the correct api_key must be specified")]
        [SwaggerResponse((int)HttpStatusCode.BadRequest, Description = "System returned an error.")]
        public async Task&lt;IActionResult&gt; <xsl:value-of select="@name"/>(<xsl:value-of select="$parameterCall"/>)
        {
             return Ok(null);
        }
  </xsl:template>

  <xsl:template match="Parameter" mode="call">        <xsl:value-of select="@type"/>&#160;<xsl:value-of select="@name"/>&#160;<xsl:value-of select="@default"/><xsl:if test="count(following-sibling::*)!=0">, </xsl:if></xsl:template>

  <xsl:template match="Parameter" mode="initialize">
            query.Parameter.<xsl:value-of select="@name"/> = <xsl:value-of select="@name"/>;</xsl:template>
   <xsl:template match="Parameter" mode="initializeCommand">
            command.Parameter = <xsl:value-of select="@name"/>;</xsl:template>  
  
  <xsl:template match="Parameter" mode="initializeCommand_________TOBE_REVIEWED___________">
            command.Parameter.<xsl:value-of select="@name"/> = <xsl:value-of select="@name"/>;</xsl:template>  
  <xsl:template match="Parameter" mode="comment"><xsl:if test="position() != 1">&#160;&#160;&#160;&#160;&#160;&#160;</xsl:if>/// &lt;param name="<xsl:value-of select="@name"/>"&gt;<xsl:value-of select="@description"/>&lt;/param&gt;
  </xsl:template>
  
   <xsl:template match="Parameter[not(@default)]" mode="isNull">
            if (<xsl:value-of select="@name"/> == null)
                throw new System.ArgumentNullException("<xsl:value-of select="@name"/>");</xsl:template>
  
  <xsl:template match="Parameter[@in='query']" mode="log">
    <xsl:variable name="lineofcode">
      <xsl:choose>
         <xsl:when  test="@default">&#160;&#160;&#160;if (<xsl:value-of select="@name"/> != null) urlBuilder.Append("<xsl:value-of select="@name"/>=").Append(System.Uri.EscapeDataString(System.Convert.ToString(<xsl:value-of select="@name"/>, System.Globalization.CultureInfo.InvariantCulture))).Append("&amp;");
         </xsl:when>
         <xsl:otherwise><xsl:if test="position() != 1">&#160;&#160;&#160;</xsl:if>urlBuilder.Append("<xsl:value-of select="@name"/>=").Append(System.Uri.EscapeDataString(System.Convert.ToString(<xsl:value-of select="@name"/>, System.Globalization.CultureInfo.InvariantCulture))).Append("&amp;");
         </xsl:otherwise>
       </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$lineofcode"/>
  </xsl:template>
  
  <xsl:template match="Parameter[@in='path']" mode="log">
            urlBuilder.Replace("{<xsl:value-of select="@name"/>}", System.Uri.EscapeDataString(System.Convert.ToString(<xsl:value-of select="@name"/>, System.Globalization.CultureInfo.InvariantCulture)));</xsl:template>
  
  <xsl:template name="footer">
}
  </xsl:template>

</xsl:stylesheet>
