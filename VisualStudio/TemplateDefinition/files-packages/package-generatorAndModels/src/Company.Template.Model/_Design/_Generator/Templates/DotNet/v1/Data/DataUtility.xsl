<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>

  <xsl:variable name="namespace"><xsl:value-of select="/Model/@namespace"/></xsl:variable> 							

  <xsl:template match="Entities">
namespace <xsl:value-of select="$namespace"/>.Data
{
    using Model;
    using System.Collections;
    using System.Collections.Generic;
    using System.Collections.ObjectModel;
    #pragma warning disable // Disable all warnings
    <xsl:value-of select="$attributeGenerator"/>

    public static class DatabaseUtility
    {
        public static void Populate(DatabaseContext context)
        {<xsl:apply-templates select="Entity[not(contains(@name,'Info'))]"/>          
        }
    }
}
  </xsl:template>

	<xsl:template match='/'>
    <xsl:call-template name="header"><xsl:with-param name="filename" select="$filename"/></xsl:call-template>    
		<xsl:apply-templates select="//Entities"/>
	</xsl:template>

  <xsl:template match="Entity">
        
          &#160;List&lt;<xsl:value-of select="@name"/>&gt; <xsl:value-of select="@pluralName"/> = new List&lt;<xsl:value-of select="@name"/>&gt;();
           if (<xsl:value-of select="@pluralName"/>.LoadFromCsv&lt;<xsl:value-of select="@name"/>&gt;(@"./Data/<xsl:value-of select="@pluralName"/>.csv"))
           {           
              foreach (var item in <xsl:value-of select="@pluralName"/>)
              {
                    context.<xsl:value-of select="@pluralName"/>.Add(item);                    
              }
              
              context.SaveChanges();
           }
  </xsl:template>

</xsl:stylesheet>
