<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:import href="../mixins.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>
  <xsl:variable name="namespace"><xsl:value-of select="/Model/@namespace"/></xsl:variable>

  <xsl:template match='/'>
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
      <xsl:with-param name="xslTemplate" select="$xslTemplate"/>
    </xsl:call-template>
    <xsl:apply-templates select="//Entities"/>
  </xsl:template>

  <xsl:template match="Entities">
namespace <xsl:value-of select="$namespace"/>.Model
{
    using AutoMapper;
     #pragma warning disable // Disable all warnings
    <xsl:value-of select="$attributeGenerator"/>

    /// &lt;summary&gt;
    /// AutoMapper configuration
    /// ------------------------
    ///     Usage:
    ///             var entity = Mapper.Map&lt;TEntityType&gt;(dto);
    ///             or 
    ///             var dto    = Mapper.Map&lt;TDtoType&gt;(entity);
    ///             
    /// &lt;/summary>
    public class AutoMapperConfig
    {
        public static void Register()
        {
            Mapper.Initialize( cfg => {<xsl:apply-templates select="Entity[contains(@name,'Info') and not(contains(@name,'SummaryInfo'))]"/>
            });    
        }
    }
}
  </xsl:template>

  <xsl:template match="Entity">    
    <xsl:variable name="dto"><xsl:value-of select="@name"/></xsl:variable>
    <xsl:variable name="entity">
      <xsl:call-template name="string-replace-all">
        <xsl:with-param name="text" select="$dto" />
        <xsl:with-param name="replace" select="'Info'" />
        <xsl:with-param name="by" select="''" />
      </xsl:call-template>
    </xsl:variable>                        
                  cfg.CreateMap&lt;<xsl:value-of select="$entity"/>, <xsl:value-of select="$dto"/>&gt;();
                  cfg.CreateMap&lt;<xsl:value-of select="$dto"/>, <xsl:value-of select="$entity"/>&gt;();</xsl:template>
</xsl:stylesheet>
