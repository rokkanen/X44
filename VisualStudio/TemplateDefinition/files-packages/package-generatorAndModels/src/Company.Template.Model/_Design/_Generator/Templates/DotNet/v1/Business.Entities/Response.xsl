<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:import href="../mixins.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>
  <xsl:variable name="namespace"><xsl:value-of select="/Model/@namespace"/></xsl:variable>
  <xsl:variable name="listImplementation">Collection</xsl:variable>

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Model
{
    using System.Collections.Generic;
    using System.Linq;
    using System.Runtime.Serialization;
    
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
      <xsl:call-template name="Entity"/>
    </xsl:if>
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
      <xsl:call-template name="Entity"/>
    </xsl:if>
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
    /// &lt;summary&gt;
    /// <xsl:value-of select="@name"/> Response.
    /// &lt;/summary&gt;
    /// &lt;seealso cref="Nova.Model.IResponse{<xsl:value-of select="@name"/>}" /&gt;
    public class <xsl:value-of select="@name"/>Response : IResponse&lt;<xsl:value-of select="@name"/>&gt;
    {
        /// &lt;summary&gt;
        /// The Kind of data is <xsl:value-of select="$kindListPrefix"/>
        /// &lt;/summary&gt;
        [DataMember]
        public string kind
        {
            get
            {
                return "<xsl:value-of select="$kindListPrefix"/>#<xsl:value-of select="@name"/>";
            }
            private set { }
        }

        /// &lt;summary&gt;
        /// Number of returned elements
        /// &lt;/summary&gt;
        [DataMember]
        public int count
        {
            get
            {
                return this.entries.Count();
            }
            private set { }
        }

        /// &lt;summary&gt;
        /// List of <xsl:value-of select="@pluralName"/>
        /// &lt;/summary&gt;
        [DataMember]
        public IEnumerable&lt;<xsl:value-of select="@name"/>&gt; entries { get; set; }
    }        
  </xsl:template>
  
<xsl:template name="footer">
}
</xsl:template>	
</xsl:stylesheet>
