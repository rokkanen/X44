<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>
  <xsl:variable name="namespace"><xsl:value-of select="/Model/@namespace"/></xsl:variable>
  <xsl:variable name="listImplementation">Collection</xsl:variable>

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Model
{
    using System.Collections.Generic;
    using System.Collections.ObjectModel;
    #pragma warning disable // Disable all warnings
    <xsl:value-of select="$attributeGenerator"/>

</xsl:template>

  <xsl:template match='/'>       
    <xsl:call-template name="header"><xsl:with-param name="filename" select="$filename"/><xsl:with-param name="xslTemplate" select="$xslTemplate"/></xsl:call-template>
    <xsl:call-template name="namespace"/>
		<xsl:apply-templates select="//Entity" mode="multi"/>
		<xsl:call-template name="footer"/>
	</xsl:template>

	<xsl:template match="Entity" mode="multi">
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">
    public partial class <xsl:value-of select="@name"/>Collection: <xsl:value-of select="$listImplementation"/>&lt;<xsl:value-of select="@name"/>&gt; {}</xsl:if>
  </xsl:template>

  <xsl:template match="Entity">
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
      <xsl:with-param name="xslTemplate" select="$xslTemplate"/>
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">
    public partial class <xsl:value-of select="@name"/>Collection: &lt;<xsl:value-of select="@name"/>&gt; {}<xsl:call-template name="footer"/></xsl:if>
  </xsl:template>

<xsl:template name="footer">
}
</xsl:template>	
</xsl:stylesheet>
