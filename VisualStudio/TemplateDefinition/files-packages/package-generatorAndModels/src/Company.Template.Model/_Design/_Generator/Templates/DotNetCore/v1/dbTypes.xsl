<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text" encoding="iso-8859-1"/>

  <xsl:template name="getType">
    <xsl:param name="type"/>
    <xsl:param name="db"/>
    <xsl:choose>
      <xsl:when test="$db='Oracle' and $type = 'string'">Varchar2</xsl:when>
      <xsl:when test="$db='Oracle' and $type = 'String'">Varchar2</xsl:when>
      <xsl:when test="$db='Oracle' and $type = 'char'">Varchar2</xsl:when>
      <xsl:when test="$db='Oracle' and $type = 'XmlDocument'">XmlType</xsl:when>
      <xsl:when test="$db='Oracle' and $type = 'int'">Int64</xsl:when>
      <xsl:when test="$db='Oracle' and $type = 'DateTime'">Date</xsl:when>
      <xsl:when test="$db='Oracle' and starts-with($type,'IEnumerable')">RefCursor</xsl:when> 
      <xsl:when test="$db='SqlServer' and $type = 'string'">string</xsl:when>
      <xsl:when test="$db='SqlServer' and $type = 'string[]'">Object</xsl:when>
      <xsl:when test="$db='SqlServer' and $type = 'char'">string</xsl:when>
      <xsl:when test="$db='SqlServer' and $type = 'XmlDocument'">XmlType</xsl:when>
      <xsl:when test="$db='SqlServer' and $type = 'int'">Int64</xsl:when>
      <xsl:when test="$db='SqlServer' and $type = 'DateTime'">Date</xsl:when>
      <xsl:when test="$db='SqlServer' and $type = 'object'">Object</xsl:when>
      <xsl:when test="$db='SqlServer' and starts-with($type,'IEnumerable')">RefCursor</xsl:when>
            
      <xsl:otherwise>
        <xsl:value-of select="$type"/>
      </xsl:otherwise>
    </xsl:choose>        
  </xsl:template>
  
</xsl:stylesheet>
