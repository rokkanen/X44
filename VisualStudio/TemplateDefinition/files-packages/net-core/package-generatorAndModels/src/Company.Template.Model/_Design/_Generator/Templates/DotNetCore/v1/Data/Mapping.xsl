<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>
  
  <xsl:variable name="namespace"><xsl:value-of select="/Model/@namespace"/></xsl:variable>

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Data
{
    using Business;
    using System.ComponentModel.DataAnnotations.Schema;
    using Microsoft.EntityFrameworkCore;
    using Microsoft.EntityFrameworkCore.Metadata.Builders;

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
      <xsl:call-template name="commentClass"/>
    public partial class <xsl:value-of select="@name"/>Map : EntityTypeConfiguration&lt;<xsl:value-of select="@name"/>&gt;
    {  
        /// &lt;summary&gt;
        /// Initializes a new instance of the &lt;see cref="<xsl:value-of select="@name"/>Map"/&gt; class.
        /// &lt;/summary&gt;    
        public override void Map(EntityTypeBuilder&lt;<xsl:value-of select="@name"/>&gt; builder)
        {   
            // ---------------- Entity ----------------
            builder.ToTable("<xsl:value-of select="@persistenceName"/>");

            // ---------------- Key ----------------<xsl:apply-templates select="Properties/Property[@propertyType=1]" mode="id"/>
            
            // ---------------- Properties ----------------<xsl:apply-templates select="Properties/Property[@propertyType=2 or @propertyType=3]" mode="property"/>
            <!--<xsl:call-template name="trackingProperty2"/>
            <xsl:call-template name="trackableEntities"/>-->
            
            // ---------------- RelationShips ----------------<xsl:apply-templates select="RelationShips/RelationShip[@relationType='one-to-one']"   mode="one-to-one"/>
            <xsl:apply-templates select="RelationShips/RelationShip[@relationType='one-to-many']"  mode="one-to-many"/>
            <xsl:apply-templates select="RelationShips/RelationShip[@relationType='many-to-one']"  mode="many-to-one"/>
        }
    }</xsl:if>
  </xsl:template>

  <xsl:template match="Property" mode="id">
    <xsl:variable name="storeGeneratedPattern"><xsl:value-of select="../Property[@propertyType=1]/@storeGeneratedPattern"/></xsl:variable>    
            builder.HasKey(k => k.<xsl:value-of select="@name"/>);
            builder.Property(k => k.<xsl:value-of select="@name"/>).ValueGeneratedOnAdd().HasColumnName("<xsl:value-of select="@persistenceName"/>");</xsl:template>

  <xsl:template match="Property" mode="property">
    <xsl:variable name="isRequired"><xsl:if test="@isRequired='true'">.IsRequired()</xsl:if></xsl:variable>
    <xsl:variable name="length"><xsl:if test="@length!=''">.HasMaxLength(<xsl:value-of select="@length"/>)</xsl:if></xsl:variable>
            builder.Property(p => p.<xsl:value-of select="@name"/>).HasColumnName("<xsl:value-of select="@persistenceName"/>")<xsl:value-of select="$isRequired"/><xsl:value-of select="$ length"/>;</xsl:template>

  <xsl:template match="RelationShip" mode="one-to-one">
    <xsl:variable name="entityName"><xsl:value-of select="../../@name"/></xsl:variable>
    <xsl:variable name="relationName"><xsl:value-of select="@relationName"/></xsl:variable>
    <xsl:variable name="cascadeDelete"><xsl:value-of select="@cascadeDelete"/></xsl:variable>
    <xsl:variable name="cascadeDeleteMethod">
      <xsl:if test="$cascadeDelete='true'">.OnDelete(DeleteBehavior.Cascade)</xsl:if>
    </xsl:variable>
    <xsl:variable name="relation">
      <xsl:if test="starts-with($relationName, $entityName)">
        <xsl:choose>
          <xsl:when test="@isRequired='true'">
            builder.HasRequired(to => to.<xsl:value-of select="@name"/>).WithRequiredPrincipal(from => from.<xsl:value-of select="$entityName"/>)<xsl:value-of select="$cascadeDeleteMethod"/>; // 1->1
          </xsl:when>
          <xsl:otherwise>
            builder.HasOne(to => to.<xsl:value-of select="@name"/>).WithRequired(from => from.<xsl:value-of select="$entityName"/>)<xsl:value-of select="$cascadeDeleteMethod"/>; // 0..1->1
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
            <xsl:value-of select="$relation"/>
  </xsl:template>
  
  <xsl:template match="RelationShip" mode="one-to-many">
    <xsl:variable name="entityName"><xsl:value-of select="../../@name"/></xsl:variable>
    <xsl:variable name="relationName"><xsl:value-of select="@relationName"/></xsl:variable>
    <xsl:variable name="cascadeDelete"><xsl:value-of select="@cascadeDelete"/></xsl:variable>
    <xsl:variable name="cascadeDeleteMethod">
      <xsl:if test="$cascadeDelete='true'">.OnDelete(DeleteBehavior.Cascade)</xsl:if>
    </xsl:variable>
    <xsl:variable name="with">
      <xsl:choose>
        <xsl:when test="@isRequired='true'">.WithRequired</xsl:when>
        <xsl:otherwise>.WithOne</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="cardinality">
      <xsl:choose>
        <xsl:when test="@isRequired='true'">1</xsl:when>
        <xsl:otherwise>0..1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="to"><xsl:value-of select="@type"/></xsl:variable>
    <xsl:variable name="property"><xsl:value-of select="@name"/></xsl:variable>
    <xsl:variable name="from"><xsl:value-of select="//Model/Entities/Entity[@name=$to]/RelationShips/RelationShip[@relationName=$relationName]/@name"/></xsl:variable>
           &#160;builder.HasMany&lt;<xsl:value-of select="@type"/>&gt;(r => r.<xsl:value-of select="$property"/>)<xsl:value-of select="$with"/>(r => r.<xsl:value-of select="$from"/>).HasForeignKey(f => f.<xsl:value-of select="$from"/>Id)<xsl:value-of select="$cascadeDeleteMethod"/>; // <xsl:value-of select="$cardinality"/>->N</xsl:template>
  
  <xsl:template match="RelationShip" mode="many-to-one">
    <xsl:variable name="relationName"><xsl:value-of select="@relationName"/></xsl:variable>
    <xsl:variable name="cascadeDelete"><xsl:value-of select="@cascadeDelete"/></xsl:variable>
    <xsl:variable name="cascadeDeleteMethod">
      <xsl:if test="$cascadeDelete='true'">.OnDelete(DeleteBehavior.Cascade)</xsl:if>
    </xsl:variable>
    <xsl:variable name="has">
      <xsl:choose>
        <xsl:when test="@isRequired='true'">HasRequired</xsl:when>
        <xsl:otherwise>HasOne</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="cardinality">
      <xsl:choose>
        <xsl:when test="@isRequired='true'">1</xsl:when>
        <xsl:otherwise>0..1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="foreignKeyId"><xsl:value-of select="@name"/>Id</xsl:variable>

    <xsl:variable name="from"><xsl:value-of select="@type"/></xsl:variable>
    <xsl:variable name="property"><xsl:value-of select="//Model/Entities/Entity[@name=$from]/RelationShips/RelationShip[@relationName=$relationName]/@name"/></xsl:variable>
           &#160;builder.<xsl:value-of select="$has"/>(r => r.<xsl:value-of select="@name"/>).WithMany(r => r.<xsl:value-of select="$property"/>).HasForeignKey(f => f.<xsl:value-of select="$foreignKeyId"/>)<xsl:value-of select="$cascadeDeleteMethod"/>; // N-><xsl:value-of select="$cardinality"/>
  </xsl:template>
 
  <xsl:template match="RelationShip" mode="many-to-many">
    <xsl:variable name="entityName"><xsl:value-of select="../../@name"/></xsl:variable>
    <xsl:variable name="cascadeDelete"><xsl:value-of select="@cascadeDelete"/></xsl:variable>    
    <xsl:variable name="relationName"><xsl:value-of select="@relationName"/></xsl:variable>
    <xsl:variable name="from"><xsl:value-of select="@type"/></xsl:variable>
    <xsl:variable name="property"><xsl:value-of select="//Model/Entities/Entity[@name=$from]/RelationShips/RelationShip[@relationName=$relationName]/@name"/></xsl:variable>
    <xsl:variable name="rightKey"><xsl:value-of select="//Model/Entities/Entity[@name=$from]/Properties/Property[@propertyType=1]/@persistenceName"/></xsl:variable>
    <xsl:variable name="leftKey"><xsl:value-of select="//Model/Entities/Entity[@name=$entityName]/Properties/Property[@propertyType=1]/@persistenceName"/></xsl:variable>
    <xsl:if test="starts-with($relationName, $entityName)">
            builder.Entity&lt;<xsl:value-of select="$relationName"/>&gt;()
                   .HasOne(o => o.<xsl:value-of select="@type"/>)
                   .WithMany(r => r.<xsl:value-of select="$relationName"/>Rels)
                   .HasForeignKey(r => r.<xsl:value-of select="@type"/>Id); // N->N
    </xsl:if>
  </xsl:template>


  <xsl:template name="entityStatus">
            builder.Property(p => p.Status).HasColumnName("STATUS");</xsl:template>    

  <xsl:template name="trackingProperty1">
    
            // ---------------- Database Tracking properties ----------------
            builder.Property(p => p.CreatedBy).HasColumnName("CREATED_BY");
            builder.Property(p => p.UpdateBy).HasColumnName("UPDATED_BY");
            builder.Property(p => p.CreationDate).HasColumnName("CREATION_DATE");
            builder.Property(p => p.UpdatedDate).HasColumnName("UPDATED_DATE");
            builder.Property(p => p.Status).HasColumnName("STATUS");</xsl:template>

  <xsl:template name="trackingProperty2">
    
            // ---------------- Database Tracking properties ----------------
            builder.Property(p => p.CreatedBy).HasColumnName("CreatedBy").HasMaxLength(50);
            builder.Property(p => p.UpdateBy).HasColumnName("UpdatedBy").HasMaxLength(50);
            builder.Property(p => p.CreationDate).HasColumnName("CreationDate");
            builder.Property(p => p.UpdatedDate).HasColumnName("UpdatedDate");
            builder.Property(p => p.Status).HasColumnName("Status");</xsl:template>

  
  <xsl:template name="trackableEntities">
    
            // ---------------- Trackable Properties (Memory) ----------------
            this.Ignore(t => t.TrackingState);
            this.Ignore(t => t.ModifiedProperties);
            this.Ignore(t => t.EntityIdentifier);</xsl:template>
  <xsl:template name="footer">
}
  </xsl:template>

  <xsl:template name="commentClass">
    /// &lt;summary&gt;
    /// Mapping definition for the entity: <xsl:value-of select="@name"/>
    /// &lt;/summary&gt;
    /// &lt;seealso cref="System.Data.Entity.ModelConfiguration.EntityTypeConfiguration{Nova.Model.<xsl:value-of select="@name"/>}" /&gt;</xsl:template>

</xsl:stylesheet>
