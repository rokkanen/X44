<?xml version = '1.0' encoding = 'utf-8'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>
	<xsl:variable name="namespace"><xsl:value-of select="/Model/@namespace"/></xsl:variable>
  <xsl:variable name="listInterface">ICollection</xsl:variable>

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Model
{
    using System;
    using System.Collections.Generic;
    using System.Collections.ObjectModel;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Runtime.Serialization;
    using System.Xml.Serialization;
    using TrackableEntities;
    #pragma warning disable // Disable all warnings
    <xsl:value-of select="$attributeGenerator"/>
  </xsl:template>
  <xsl:template match='/'>
    <xsl:call-template name="header"><xsl:with-param name="filename" select="$filename"/><xsl:with-param name="xslTemplate" select="$xslTemplate"/></xsl:call-template>
    <xsl:call-template name="namespace"/>
		<xsl:apply-templates select="//Entity[not(contains(@name,'Info'))]" mode="multi"/>
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
    <xsl:variable name="typeId">
      <xsl:value-of select="Properties/Property[@propertyType = 1]/@type"/>
    </xsl:variable>
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">
    [DataContract]
    public partial class <xsl:value-of select="@name"/>: ITrackable, IMergeable
    {<xsl:call-template name="constructor"/>
    <xsl:call-template name="entityId"/>
    <xsl:apply-templates select="Properties/Property"/>
    <xsl:call-template name="trackingDbProperty"/>
    <xsl:call-template name="entityStatus"/>
    <xsl:call-template name="trackableEntities"/>
    <xsl:apply-templates select="RelationShips/RelationShip"/>
    <!-- <xsl:call-template name="relationOneToMany"/>-->
    <xsl:call-template name="relationManyToMany"/>
    }
    </xsl:if>
  </xsl:template>

  <xsl:template match="Property">    
		<xsl:variable name="xmlattribute">
			<xsl:choose>
				<xsl:when test="@type='string' or @type='int' or @type='Guid' or @type='DateTime'  or @type='double' or @type='byte' or @type='boolean'">
		[XmlAttribute("<xsl:value-of select="@name"/>")]</xsl:when>
				<xsl:otherwise><xsl:text></xsl:text></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
    <xsl:if test="@propertyType=2  or @propertyType=3">
      &#160;<xsl:value-of select="$xmlattribute"/>
        [DataMember]
        public <xsl:value-of select="@type"/>&#160;<xsl:value-of select="@name"/> { get; set; }</xsl:if>
    <xsl:if test="@propertyType=1 and $excludeKey=0">
      <xsl:variable name="defaultGuid">
        <xsl:if test="@type='Guid'">//= Guid.NewGuid(); // C# 6.0</xsl:if>
      </xsl:variable>      
      &#160;<xsl:value-of select="$xmlattribute"/>
        [DataMember]      
        public <xsl:value-of select="@type"/>&#160;<xsl:value-of select="@name"/> { get; set; }</xsl:if>
  </xsl:template>
  
  <xsl:template name="entityStatus">    
        [DataMember]
        public EntityStatus Status { get; set; }
  </xsl:template>
  
  <xsl:template name="trackableEntities">    
      // ---------------- Memory Tracking properties ----------------
      public TrackingState TrackingState { get; set; }
      public ICollection&lt;string&gt; ModifiedProperties { get; set; }
      public Guid EntityIdentifier { get; set; }
  </xsl:template>

  <xsl:template name="trackingDbProperty">      
    
        // ---------------- Database Tracking properties ----------------
        [DataMember]      
        public string CreatedBy { get; set; }

        [DataMember]      
        public string UpdateBy { get; set; }

        [DataMember]      
        public Nullable&lt;DateTime&gt; CreationDate { get; set; }

        [DataMember]      
        public Nullable&lt;DateTime&gt; UpdatedDate { get; set; }
  </xsl:template>

  <xsl:template match="RelationShip">
    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="@relationType='many-to-many' or @relationType='one-to-many'"><xsl:value-of select="$listInterface"/>&lt;<xsl:value-of select="@type"/>&gt;</xsl:when>
        <xsl:otherwise><xsl:value-of select="@type"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
        [DataMember]          
        public virtual <xsl:value-of select="$type"/>&#160;<xsl:value-of select="@name"/> { get; set; }
  </xsl:template>
  
  <xsl:template name="entityId">
    <xsl:variable name="typeId"><xsl:value-of select="Properties/Property[@propertyType = 1]/@type"/></xsl:variable>      
        [NotMapped]
        public <xsl:value-of select="$typeId"/> Id
        {
            get
            {
                return this.<xsl:value-of select="@name"/>Id;
            }
            set
            {
                this.<xsl:value-of select="@name"/>Id = value;
            }
        }</xsl:template>

  <xsl:template name="constructor">
        /// <summary>
        /// Initializes a new instance of the &lt;see cref="<xsl:value-of select="@name"/>"/&gt; class.
        /// </summary>
        public <xsl:value-of select="@name"/>()
        {<xsl:for-each select="RelationShips/RelationShip[@relationType='one-to-many' or @relationType='many-to-many']">
            this.<xsl:value-of select="@name"/> = new Collection&lt;<xsl:value-of select="@type"/>&gt;();</xsl:for-each>
        }
  </xsl:template>

  <xsl:template name="relationOneToMany">
    <xsl:for-each select="RelationShips/RelationShip[@relationType='one-to-many']">
      <xsl:variable name="relationName">
        <xsl:value-of select="@relationName"/>
      </xsl:variable>
      <xsl:variable name="relationType">
        <xsl:value-of select="@type"/>
      </xsl:variable>
      <xsl:variable name="relation"><xsl:value-of select="//Entity[@name=$relationType]/RelationShips/RelationShip[@relationName=$relationName]/@name"/></xsl:variable>
      <xsl:variable name="relationId"><xsl:value-of select="$relation"/>Id</xsl:variable>
        public virtual void Add<xsl:value-of select="@name"/>(<xsl:value-of select="@type"/>&#160;item)
        {
            item.<xsl:value-of select="$relationId"/> = this.<xsl:value-of select="../../@name"/>Id;
            this.<xsl:value-of select="@name"/>.Add(item);
         }
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="relationManyToMany">
    <xsl:for-each select="RelationShips/RelationShip[@relationType='many-to-many']">
        public virtual void Add<xsl:value-of select="@type"/>(<xsl:value-of select="@type"/>&#160;item)
        {
            this.<xsl:value-of select="@name"/>.Add(item);
        }
    </xsl:for-each>
  </xsl:template>

<xsl:template name="footer">
}
</xsl:template>

</xsl:stylesheet>
