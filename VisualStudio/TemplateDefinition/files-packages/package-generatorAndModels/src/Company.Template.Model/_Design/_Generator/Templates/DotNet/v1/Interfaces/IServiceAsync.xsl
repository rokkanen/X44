<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>
  <xsl:variable name="namespace">
    <xsl:value-of select="/Model/@namespace"/>
  </xsl:variable>

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Model
{
    using System;
    using System.Collections.Generic;
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
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    <xsl:call-template name="body"/>    
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template name="body">
    <xsl:variable name="typeId"><xsl:value-of select="Properties/Property[@propertyType = 1]/@type"/></xsl:variable>
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">
    public partial interface I<xsl:value-of select="@name"/>Service : IService&lt;<xsl:value-of select="@name"/>,<xsl:value-of select="$typeId"/>&gt; 
    {<xsl:apply-templates select="RelationShips/RelationShip"/>
    }
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="RelationShip">
    <xsl:variable name="relationEntity"><xsl:value-of select="@type"/></xsl:variable>
    <xsl:variable name="typeIdRelation"><xsl:value-of select="../../../Entity[@name=$relationEntity]/Properties/Property[@propertyType = 1]/@type"/></xsl:variable>
    <xsl:if test="@relationType='many-to-one'">
        Task&lt;IEnumerable&lt;<xsl:value-of select="../../@name"/>&gt;&gt; GetBy<xsl:value-of select="@type"/>(<xsl:value-of select="$typeIdRelation"/> id);</xsl:if>
  </xsl:template>
   
  <xsl:template name="footer">
}
  </xsl:template>

</xsl:stylesheet>
