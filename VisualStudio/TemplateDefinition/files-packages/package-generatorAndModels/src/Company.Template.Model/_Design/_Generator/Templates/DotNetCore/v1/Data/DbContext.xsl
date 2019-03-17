<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>

  <xsl:variable name="namespace"><xsl:value-of select="/Model/@namespace"/></xsl:variable>
  <xsl:variable name="dbNameContext">DatabaseContext</xsl:variable>
  <xsl:variable name="dbNameInitializer">DatabaseInitializer</xsl:variable>
  <xsl:variable name="UseDb">UseSqlServer</xsl:variable>

  <xsl:template match='/'>
    <xsl:call-template name="header"><xsl:with-param name="filename" select="$filename"/><xsl:with-param name="xslTemplate" select="$xslTemplate"/></xsl:call-template>    
    <xsl:apply-templates select="//Entities"/>
  </xsl:template>

  <xsl:template match="Entities">
    
namespace <xsl:value-of select="$namespace"/>.Data
{
    using log4net;
    using Business;
    using Microsoft.EntityFrameworkCore;
    #pragma warning disable // Disable all warnings
    <xsl:value-of select="$attributeGenerator"/>

    <xsl:call-template name="commentClass"/>
    public partial class <xsl:value-of select="$dbNameContext"/>: DbContext
    {
        private static ILog _log = LogManager.GetLogger(typeof(<xsl:value-of select="$dbNameContext"/>));
        private string _connectionString;

        #region public properties <xsl:apply-templates select="Entity[not(contains(@name,'Info'))]" mode="DbSet"/>
        #endregion

        /// &lt;summary&gt;
        /// Initializes the &lt;see cref="<xsl:value-of select="$dbNameContext"/>"/&gt; class.
        /// &lt;/summary&gt;
        public <xsl:value-of select="$dbNameContext"/>(DbContextOptions&lt;<xsl:value-of select="$dbNameContext"/>&gt; options): base(options)
        {
        }
        
        /// &lt;summary&gt;
        /// Initializes a new instance of the &lt;see cref="<xsl:value-of select="$dbNameContext"/>"/&gt; class.
        /// &lt;/summary&gt;
        public <xsl:value-of select="$dbNameContext"/>()
        {
        }    
        
        /// &lt;summary&gt;
        /// Initializes a new instance of the &lt;see cref="<xsl:value-of select="$dbNameContext"/>"/&gt; class.
        /// &lt;/summary&gt;
        public DatabaseContext(string connectionString)
        {
            _connectionString = connectionString;
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {   
            if (!string.IsNullOrEmpty(_connectionString))
              optionsBuilder.<xsl:value-of select="$UseDb"/>(_connectionString);
        }
        
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {          
            base.OnModelCreating(modelBuilder);
            ConfigureMapping(modelBuilder);          
        }

        private static void ConfigureMapping(ModelBuilder modelBuilder)
        {<xsl:apply-templates select="Entity[not(contains(@name,'Info'))]" mode="Mapping"/>
         <xsl:apply-templates select="Entity[not(contains(@name,'Info')) and child::RelationShips/RelationShip[@relationType='many-to-many' and @relationName[starts-with(.,../../../@name)]]]/RelationShips/RelationShip[@relationType='many-to-many']" mode="Mapping"/>
        }          
    }
}
  </xsl:template>

  <xsl:template match="Entity" mode="DbSet">
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">
        public DbSet&lt;<xsl:value-of select="@name"/>&gt; <xsl:value-of select="@pluralName"/> {get; set;}</xsl:if>
  </xsl:template>

  <xsl:template match="RelationShip" mode="Mapping">
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">
            modelBuilder.AddConfiguration(new <xsl:value-of select="@relationName"/>Map());</xsl:if>
  </xsl:template>
  
  <xsl:template match="Entity" mode="Mapping">
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">
            modelBuilder.AddConfiguration(new <xsl:value-of select="@name"/>Map());</xsl:if>
  </xsl:template>

  <xsl:template name="commentOnModelCreating">
        /// <summary>
        /// This method is called when the model for a derived context has been initialized, but
        /// before the model has been locked down and used to initialize the context.  The default
        /// implementation of this method does nothing, but it can be overridden in a derived class
        /// such that the model can be further configured before it is locked down.
        /// </summary>
        /// <param name="modelBuilder">The builder that defines the model for the context being created.</param>
        /// <remarks>
        /// Typically, this method is called only once when the first instance of a derived context
        /// is created.  The model for that context is then cached and is for all further instances of
        /// the context in the app domain.  This caching can be disabled by setting the ModelCaching
        /// property on the given ModelBuidler, but note that this can seriously degrade performance.
        /// More control over caching is provided through use of the DbModelBuilder and DbContextFactory
        /// classes directly.
        /// </remarks>    
  </xsl:template>

  <xsl:template name="commentClass">
    /// &lt;summary&gt;
    /// Entity Framework Core Database Context
    /// &lt;/summary&gt;
    /// &lt;seealso cref="Microsoft.EntityFrameworkCore.DbContext" /&gt;</xsl:template>    
</xsl:stylesheet>
