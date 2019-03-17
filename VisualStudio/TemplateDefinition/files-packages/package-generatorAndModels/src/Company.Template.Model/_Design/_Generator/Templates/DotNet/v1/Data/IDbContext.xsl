<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>

  <xsl:param name="excludeKey"/>
  <xsl:param name="includeEntities"></xsl:param>
  <xsl:param name="excludeEntities"></xsl:param>

  <xsl:variable name="namespace"><xsl:value-of select="/Model/@namespace"/></xsl:variable>

  <xsl:template match='/'>
    <xsl:call-template name="header"><xsl:with-param name="filename" select="$filename"/><xsl:with-param name="xslTemplate" select="$xslTemplate"/></xsl:call-template>    
    <xsl:apply-templates select="//Entities"/>
  </xsl:template>

  <xsl:template match="Entities">
namespace <xsl:value-of select="$namespace"/>.Data
{
    using Model;
    using System.Data.Entity;
    #pragma warning disable // Disable all warnings
    <xsl:value-of select="$attributeGenerator"/>
    
    public interface IDatabaseContext
    {<xsl:apply-templates select="Entity"/>    
    }
}
  </xsl:template>

  <xsl:template match="Entity">
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">
        IDbSet&lt;<xsl:value-of select="@name"/>&gt; <xsl:value-of select="@pluralName"/> {get; set;}</xsl:if>
  </xsl:template>

</xsl:stylesheet>
