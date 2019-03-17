<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>
	<xsl:variable name="namespace"><xsl:value-of select="/Model/@namespace"/></xsl:variable>

	<xsl:template match='/'>
    <xsl:call-template name="header"><xsl:with-param name="filename" select="$filename"/><xsl:with-param name="xslTemplate" select="$xslTemplate"/></xsl:call-template>
    <xsl:call-template name="namespace"/>
		<xsl:apply-templates select="//Entity" mode="multi"/>
		<xsl:call-template name="footer"/>
	</xsl:template>
	
	<xsl:template match="Entity" mode="multi">
    <xsl:call-template name="Entity"/>
	</xsl:template>

  <xsl:template match="Entity">
    <xsl:variable name="typeId"><xsl:value-of select="Properties/Property[@propertyType = 1]/@type"/></xsl:variable>
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
      <xsl:with-param name="xslTemplate" select="$xslTemplate"/>
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    <xsl:call-template name="Entity"/>
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template name="Entity">
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">  
    <xsl:apply-templates select="RelationShips/RelationShip[@relationType='many-to-many']"/>
    </xsl:if>
  </xsl:template>
 
  <xsl:template match="RelationShip">
    <xsl:variable name="type">
      <xsl:value-of select="@type"/>
    </xsl:variable>
    <xsl:variable name="typeId">
      <xsl:value-of select="//Entity[@name=$type]/Properties/Property[@propertyType = 1]/@type"/>
    </xsl:variable>
    public partial class <xsl:value-of select="@relationName"/>
    {
        public <xsl:value-of select="$typeId"/>&#160;<xsl:value-of select="@type"/>Id { get; set; }
        public <xsl:value-of select="@type"/>&#160;<xsl:value-of select="@type"/> { get; set; }
    }</xsl:template>

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Business
{
    using System;
  </xsl:template>

<xsl:template name="footer">
}
</xsl:template>

</xsl:stylesheet>
