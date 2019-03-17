<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>

  <xsl:variable name="namespace"><xsl:value-of select="/Model/@namespace"/></xsl:variable>
  <xsl:variable name="dbNameContext">Database</xsl:variable>
  
  <xsl:template match='/'>
    <xsl:call-template name="header"><xsl:with-param name="filename" select="$filename"/><xsl:with-param name="xslTemplate" select="$xslTemplate"/></xsl:call-template>    
    <xsl:apply-templates select="//Entities"/>
  </xsl:template>

  <xsl:template match="Entities">
    <xsl:variable name="unitOfWork"><xsl:value-of select="$dbNameContext"/>UnitOfWork</xsl:variable>    
namespace <xsl:value-of select="$namespace"/>.Data
{
    using log4net;
    using Interfaces;
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    using System.Threading;
    using System.Threading.Tasks;
    using TrackableEntities.Patterns.EF6;
    #pragma warning disable // Disable all warnings
    <xsl:value-of select="$attributeGenerator"/>

    public partial class <xsl:value-of select="$unitOfWork"/>: UnitOfWork, I<xsl:value-of select="$unitOfWork"/>
    {    
        private static ILog log = LogManager.GetLogger(typeof(<xsl:value-of select="$unitOfWork"/>));

        #region private properties<xsl:apply-templates select="Entity" mode="privateFields"/>
        #endregion
        
        /// &lt;summary&gt;
        /// Initializes the &lt;see cref="<xsl:value-of select="$unitOfWork"/>"/&gt; class.
        /// &lt;/summary&gt;
        public <xsl:value-of select="$unitOfWork"/>(I<xsl:value-of select="$dbNameContext"/>Context context,<xsl:apply-templates select="Entity" mode="parameterContructor"/>)    
                                  :base(context as DbContext)                
        {
            log.Info("Initialize <xsl:value-of select="$unitOfWork"/>");
            <xsl:apply-templates select="Entity" mode="initPrivateFields"/>          
        }        
        
        #region public properties<xsl:apply-templates select="Entity" mode="property"/>    #endregion
        <xsl:call-template name="methods"/>        
    }
}
  </xsl:template>

  <xsl:template match="Entity" mode="privateFields">
    <xsl:variable name="repository"><xsl:value-of select="@name"/>Repository</xsl:variable>
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">
        private readonly I<xsl:value-of select="$repository"/>&#160;_<xsl:value-of select="$repository"/>;</xsl:if>
  </xsl:template>

  <xsl:template match="Entity" mode="parameterContructor">
    <xsl:variable name="repository"><xsl:value-of select="@name"/>Repository</xsl:variable>
    <xsl:variable name="sep"><xsl:if test="not(position()=last())">,</xsl:if></xsl:variable>
    
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">
                                  I<xsl:value-of select="$repository"/>&#160;<xsl:value-of select="$repository"/><xsl:value-of select="$sep"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="Entity" mode="initPrivateFields">
    <xsl:variable name="repository"><xsl:value-of select="@name"/>Repository</xsl:variable>
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">
            _<xsl:value-of select="$repository"/> = <xsl:value-of select="$repository"/>;</xsl:if>
  </xsl:template>

  <xsl:template match="Entity" mode="property">
    <xsl:variable name="repository"><xsl:value-of select="@name"/>Repository</xsl:variable>
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">
        public I<xsl:value-of select="$repository"/>&#160;<xsl:value-of select="$repository"/>
        {
            get { return _<xsl:value-of select="$repository"/>; }
        }
    </xsl:if>
  </xsl:template>

  <xsl:template name="methods">
        public override int SaveChanges()
        {
            try
            {
                return base.SaveChanges();
            }
            catch (DbUpdateConcurrencyException concurrencyException)
            {
                throw new UpdateConcurrencyException(concurrencyException.Message, concurrencyException);
            }
            catch (DbUpdateException updateException)
            {
                throw new UpdateException(updateException.Message,updateException);
            }
        }

        public override Task&lt;int&gt; SaveChangesAsync()
        {
            return SaveChangesAsync(CancellationToken.None);
        }

        public override Task&lt;int&gt; SaveChangesAsync(CancellationToken cancellationToken)
        {
            try
            {
                return base.SaveChangesAsync(cancellationToken);
            }
            catch (DbUpdateConcurrencyException concurrencyException)
            {
                throw new UpdateConcurrencyException(concurrencyException.Message, concurrencyException);
            }
            catch (DbUpdateException updateException)
            {
                throw new UpdateException(updateException.Message, updateException);
            }
        }</xsl:template>
  
  <xsl:template name="commentClass">
    /// &lt;summary&gt;
    /// Entity Framework Database Context
    /// &lt;/summary&gt;
    /// &lt;seealso cref="System.Data.Entity.DbContext" /&gt;
    /// &lt;seealso cref="<xsl:value-of select="$namespace"/>.Data.I<xsl:value-of select="$dbNameContext"/>Context" /&gt;</xsl:template>
</xsl:stylesheet>
