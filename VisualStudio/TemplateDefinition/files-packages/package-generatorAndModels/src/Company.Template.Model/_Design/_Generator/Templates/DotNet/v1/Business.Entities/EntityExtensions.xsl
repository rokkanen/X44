<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl" />
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:import href="../mixins.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>
  <xsl:variable name="namespace"><xsl:value-of select="/Model/@namespace"/></xsl:variable>

    <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Model
{
    using AutoMapper;
    using System.Collections.Generic;
    using System.Linq;
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
    public static partial class EntityExtensions
    {<xsl:call-template name="Entity"/>
    }
  </xsl:template>

  <xsl:template match="Entity">
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
      <xsl:with-param name="xslTemplate" select="$xslTemplate"/>
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    public static partial class EntityExtensions
    {<xsl:call-template name="Entity"/>
    }
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template name="Entity">
    <xsl:variable name="dto"><xsl:value-of select="@name"/></xsl:variable>
    <xsl:variable name="entity">
      <xsl:call-template name="string-replace-all">
        <xsl:with-param name="text" select="$dto" />
        <xsl:with-param name="replace" select="'Info'" />
        <xsl:with-param name="by" select="''" />
      </xsl:call-template>
    </xsl:variable>                        
        public static <xsl:value-of select="$dto"/> ConvertToDto(this <xsl:value-of select="$entity"/> entity)
        {
            return Mapper.Map&lt;<xsl:value-of select="$dto"/>&gt;(entity);
        }
        public static IEnumerable&lt;<xsl:value-of select="$dto"/>&gt; ConvertToDto(this IEnumerable&lt;<xsl:value-of select="$entity"/>&gt; entities)
        {
            return entities.Select(item => item.ConvertToDto()).ToList();
        }
        public static <xsl:value-of select="$entity"/> ConvertToEntity(this <xsl:value-of select="$dto"/> dto)
        {
            return Mapper.Map&lt;<xsl:value-of select="$entity"/>&gt;(dto);
        }
        public static IEnumerable&lt;<xsl:value-of select="$entity"/>&gt; ConvertToEntity(this IEnumerable&lt;<xsl:value-of select="$dto"/>&gt; dtos)
        {
            return dtos.Select(item => item.ConvertToEntity()).ToList();
        }</xsl:template>
  
<xsl:template name="footer">
}
</xsl:template>
  
</xsl:stylesheet>
