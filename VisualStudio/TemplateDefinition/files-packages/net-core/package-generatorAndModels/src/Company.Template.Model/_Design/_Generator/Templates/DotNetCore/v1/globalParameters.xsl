<?xml version = '1.0' encoding = 'iso-8859-1'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text" encoding="iso-8859-1"/>
  <xsl:param name="filename"/>
  <xsl:param name="excludeKey"/>
  <xsl:param name="includeEntities"></xsl:param>
  <xsl:param name="excludeEntities"></xsl:param>
  <!-- Ne fonctionne pas car @name est local a un template et ne peut être évalué. Il faut utiliser un template-->
  <xsl:template name="seleted-entities">
    <xsl:param name="name" />
    <xsl:choose>
      <xsl:when test="(string-length($includeEntities) &gt; 0 and contains($includeEntities,$name)) or  (string-length($excludeEntities) &gt; 0 and not(contains($excludeEntities,$name)) or (string-length($includeEntities) = 0 and string-length($excludeEntities)=0) )">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>  
</xsl:stylesheet>
