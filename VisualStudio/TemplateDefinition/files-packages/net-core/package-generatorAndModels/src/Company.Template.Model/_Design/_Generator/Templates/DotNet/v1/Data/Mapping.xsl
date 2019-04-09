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
namespace <xsl:value-of select="$namespace"/>.Model
{
    using Model;
    using System.ComponentModel.DataAnnotations.Schema;
    using System. Data.Entity.ModelConfiguration;
    
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
        public <xsl:value-of select="@name"/>Map()
        {   
            // ---------------- Entity ----------------
            ToTable("<xsl:value-of select="@persistenceName"/>");

            // ---------------- Key ----------------<xsl:apply-templates select="Properties/Property[@propertyType=1]" mode="id"/>
            
            // ---------------- Properties ----------------<xsl:apply-templates select="Properties/Property[@propertyType=2 or @propertyType=3]" mode="property"/>
            <!--<xsl:call-template name="trackingProperty2"/>
            <xsl:call-template name="trackableEntities"/>-->
            
            // ---------------- RelationShips ----------------<xsl:apply-templates select="RelationShips/RelationShip[@relationType='one-to-one']"   mode="one-to-one"/>
            <xsl:apply-templates select="RelationShips/RelationShip[@relationType='one-to-many']"  mode="one-to-many"/>
            <xsl:apply-templates select="RelationShips/RelationShip[@relationType='many-to-one']"  mode="many-to-one"/>
            <xsl:apply-templates select="RelationShips/RelationShip[@relationType='many-to-many']" mode="many-to-many"/>
        }
    }</xsl:if>
  </xsl:template>

  <xsl:template match="Property" mode="id">
    <xsl:variable name="storeGeneratedPattern"><xsl:value-of select="../Property[@propertyType=1]/@storeGeneratedPattern"/></xsl:variable>    
            HasKey(k => k.<xsl:value-of select="@name"/>);
            Property(k => k.<xsl:value-of select="@name"/>).HasDatabaseGeneratedOption(DatabaseGeneratedOption.<xsl:value-of select="$storeGeneratedPattern"/>).HasColumnName("<xsl:value-of select="@persistenceName"/>");</xsl:template>

  <xsl:template match="Property" mode="property">
    <xsl:variable name="isRequired"><xsl:if test="@isRequired='true'">.IsRequired()</xsl:if></xsl:variable>
    <xsl:variable name="length"><xsl:if test="@length!=''">.HasMaxLength(<xsl:value-of select="@length"/>)</xsl:if></xsl:variable>
            Property(p => p.<xsl:value-of select="@name"/>).HasColumnName("<xsl:value-of select="@persistenceName"/>")<xsl:value-of select="$isRequired"/><xsl:value-of select="$ length"/>;</xsl:template>

  <xsl:template match="RelationShip" mode="one-to-one">
    <xsl:variable name="entityName"><xsl:value-of select="../../@name"/></xsl:variable>
    <xsl:variable name="relationName"><xsl:value-of select="@relationName"/></xsl:variable>
    <xsl:variable name="cascadeDelete"><xsl:value-of select="@cascadeDelete"/></xsl:variable>
    <xsl:variable name="relation">
      <xsl:if test="starts-with($relationName, $entityName)">
        <xsl:choose>
          <xsl:when test="@isRequired='true'">
            HasRequired(to => to.<xsl:value-of select="@name"/>).WithRequiredPrincipal(from => from.<xsl:value-of select="$entityName"/>).WillCascadeOnDelete(<xsl:value-of select="$cascadeDelete"/>); // 1->1
          </xsl:when>
          <xsl:otherwise>
            HasOptional(to => to.<xsl:value-of select="@name"/>).WithRequired(from => from.<xsl:value-of select="$entityName"/>).WillCascadeOnDelete(<xsl:value-of select="$cascadeDelete"/>); // 0..1->1
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
    <xsl:variable name="with">
      <xsl:choose>
        <xsl:when test="@isRequired='true'">.WithRequired</xsl:when>
        <xsl:otherwise>.WithOptional</xsl:otherwise>
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
           &#160;HasMany&lt;<xsl:value-of select="@type"/>&gt;(r => r.<xsl:value-of select="$property"/>)<xsl:value-of select="$with"/>(r => r.<xsl:value-of select="$from"/>).HasForeignKey(f => f.<xsl:value-of select="$from"/>Id).WillCascadeOnDelete(<xsl:value-of select="$cascadeDelete"/>); // <xsl:value-of select="$cardinality"/>->N</xsl:template>
  
  <xsl:template match="RelationShip" mode="many-to-one">
    <xsl:variable name="relationName"><xsl:value-of select="@relationName"/></xsl:variable>
    <xsl:variable name="cascadeDelete"><xsl:value-of select="@cascadeDelete"/></xsl:variable>
    <xsl:variable name="has">
      <xsl:choose>
        <xsl:when test="@isRequired='true'">HasRequired</xsl:when>
        <xsl:otherwise>HasOptional</xsl:otherwise>
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
           &#160;<xsl:value-of select="$has"/>&lt;<xsl:value-of select="$from"/>&gt;(r => r.<xsl:value-of select="@name"/>).WithMany(r => r.<xsl:value-of select="$property"/>).HasForeignKey(f => f.<xsl:value-of select="$foreignKeyId"/>).WillCascadeOnDelete(<xsl:value-of select="$cascadeDelete"/>); // N-><xsl:value-of select="$cardinality"/>
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
    
            HasMany&lt;<xsl:value-of select="@type"/>&gt;(r => r.<xsl:value-of select="@name"/>)
                  .WithMany(r => r.<xsl:value-of select="$property"/>)
                  .Map(cs =>
                    {
                        cs.MapLeftKey("<xsl:value-of select="$leftKey"/>");
                        cs.MapRightKey("<xsl:value-of select="$rightKey"/>");
                        cs.ToTable("<xsl:value-of select="@persistenceName"/>");
                    }); // N->N
    </xsl:if>
  </xsl:template>


  <xsl:template name="entityStatus">
            Property(p => p.Status).HasColumnName("STATUS");</xsl:template>    

  <xsl:template name="trackingProperty1">
    
            // ---------------- Database Tracking properties ----------------
            Property(p => p.CreatedBy).HasColumnName("CREATED_BY");
            Property(p => p.UpdateBy).HasColumnName("UPDATED_BY");
            Property(p => p.CreationDate).HasColumnName("CREATION_DATE");
            Property(p => p.UpdatedDate).HasColumnName("UPDATED_DATE");
            Property(p => p.Status).HasColumnName("STATUS");</xsl:template>

  <xsl:template name="trackingProperty2">
    
            // ---------------- Database Tracking properties ----------------
            Property(p => p.CreatedBy).HasColumnName("CreatedBy").HasMaxLength(50);
            Property(p => p.UpdateBy).HasColumnName("UpdatedBy").HasMaxLength(50);
            Property(p => p.CreationDate).HasColumnName("CreationDate");
            Property(p => p.UpdatedDate).HasColumnName("UpdatedDate");
            Property(p => p.Status).HasColumnName("Status");</xsl:template>

  
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
