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
            <xsl:apply-templates select="RelationShips/RelationShip[@relationType='many-to-many']" mode="many-to-many"/>
   </xsl:if>
  </xsl:template>
  
  <xsl:template match="RelationShip" mode="many-to-many">
    <xsl:variable name="entityName"><xsl:value-of select="../../@name"/></xsl:variable>
    <xsl:variable name="cascadeDelete"><xsl:value-of select="@cascadeDelete"/></xsl:variable>    
    <xsl:variable name="relationName"><xsl:value-of select="@relationName"/></xsl:variable>
    <xsl:variable name="relationNameProperty"><xsl:value-of select="@relationName"/>Rels</xsl:variable>
    <xsl:variable name="from"><xsl:value-of select="@type"/></xsl:variable>
    <xsl:variable name="property"><xsl:value-of select="//Model/Entities/Entity[@name=$from]/RelationShips/RelationShip[@relationName=$relationName]/@name"/></xsl:variable>
    <xsl:variable name="rightKey"><xsl:value-of select="//Model/Entities/Entity[@name=$from]/Properties/Property[@propertyType=1]/@persistenceName"/></xsl:variable>
    <xsl:variable name="leftKey"><xsl:value-of select="//Model/Entities/Entity[@name=$entityName]/Properties/Property[@propertyType=1]/@persistenceName"/></xsl:variable>
    <xsl:if test="starts-with($relationName, $entityName)">
    <xsl:call-template name="commentClass"/>
    public partial class <xsl:value-of select="@relationName"/>Map : EntityTypeConfiguration&lt;<xsl:value-of select="@relationName"/>&gt;
    {  
        /// &lt;summary&gt;
        /// Initializes a new instance of the &lt;see cref="<xsl:value-of select="@relationName"/>Map"/&gt; class.
        /// &lt;/summary&gt;    
        public override void Map(EntityTypeBuilder&lt;<xsl:value-of select="@relationName"/>&gt; builder)
        {       
            // N->N
            builder
                .HasKey(bc => new { bc.<xsl:value-of select="$entityName"/>Id, bc.<xsl:value-of select="@type"/>Id });

            builder
                .HasOne(bc => bc.<xsl:value-of select="$entityName"/>)
                .WithMany(b => b.<xsl:value-of select="$relationNameProperty"/>)
                .HasForeignKey(bc => bc.<xsl:value-of select="$entityName"/>Id);

            builder
                .HasOne(bc => bc.<xsl:value-of select="@type"/>)
                .WithMany(c => c.<xsl:value-of select="$relationNameProperty"/>)
                .HasForeignKey(bc => bc.<xsl:value-of select="@type"/>Id);
       }
    }
    </xsl:if>
  </xsl:template>

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
