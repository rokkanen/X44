<?xml version = '1.0' encoding = 'utf-8'?>
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
    using Faker;
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
    public static class  <xsl:value-of select="@name"/>Extension
    {
      public static void MakeSample(this <xsl:value-of select="@name"/>Info&#160;<xsl:value-of select="@name"/>)
      {           <xsl:apply-templates select="Properties/Property"/>
      }
    }
  </xsl:template>

  <xsl:template match="Entity">
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
      <xsl:with-param name="xslTemplate" select="$xslTemplate"/>
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    public static class  <xsl:value-of select="@name"/>Extension
    {
      public static void MakeSample(this <xsl:value-of select="@name"/>Info&#160;<xsl:value-of select="@name"/>)
      {<xsl:apply-templates select="Properties/Property"/>
      }
    }
    <xsl:call-template name="footer"/>
  </xsl:template>

<xsl:template match="Property">
  <xsl:if test="@propertyType=2">
          &#160;<xsl:value-of select="../../@name"/>.<xsl:value-of select="@name"/> = (<xsl:value-of select="@type"/>)FakeHelper.Intance.GetRandomValue&lt;<xsl:value-of select="@type"/>&gt;("<xsl:value-of select="../../@name"/>.<xsl:value-of select="@name"/>");</xsl:if>
</xsl:template>

  <xsl:template name="footer">
}
  </xsl:template>

</xsl:stylesheet>
