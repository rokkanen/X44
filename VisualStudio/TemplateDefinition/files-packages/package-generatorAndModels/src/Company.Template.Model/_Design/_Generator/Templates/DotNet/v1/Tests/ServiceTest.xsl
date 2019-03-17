<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>
  <xsl:param name="excludeKey"/>
  <xsl:param name="includeEntities"></xsl:param>
  <xsl:param name="excludeEntities"></xsl:param>

  <xsl:variable name="namespace"><xsl:value-of select="/Model/@namespace"/></xsl:variable>
  <xsl:variable name="dbNameContext">Database</xsl:variable>

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Tests
{
    using Autofac;
    using log4net;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Model;
    using TrackableEntities;
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
    <xsl:call-template name="body"/>
  </xsl:template>

  <xsl:template match="Entity">
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
      <xsl:with-param name="xslTemplate" select="$xslTemplate"/>
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    <xsl:call-template name="body"/>
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template name="body">
    [TestClass]
    public partial class <xsl:value-of select="@name"/>ServiceTest
    {
      <xsl:call-template name="Declaration"/>
      <xsl:call-template name="Configure"/>
      <xsl:call-template name="CanAdd"/>
      <xsl:call-template name="CanDelete"/>
    }
  </xsl:template>

  <xsl:template name="Declaration">
        private static ILog _log = LogManager.GetLogger(typeof(<xsl:value-of select="@name"/>ServiceTest));
        private static I<xsl:value-of select="@name"/>Service _service;
  </xsl:template>


  <xsl:template name="Configure">
        [ClassInitialize]
        public static void Init(TestContext context)
        {
            log4net.Config.XmlConfigurator.Configure();
            Ioc.Register();
            AutoMapperConfig.Register();
            _service = Ioc.Container.Resolve&lt;I<xsl:value-of select="@name"/>Service&gt;();
        }
  </xsl:template>

  <xsl:template name="CanAdd">
        [TestMethod]
        [TestCategory("2-Service Layer")]
        [Owner("VS Template")]
        [Priority(2)]
        public void CanAdd<xsl:value-of select="@name"/>()
        {
            _log.Info("CanAdd<xsl:value-of select="@name"/>");
            var item = new <xsl:value-of select="@name"/>Info();
            
            item.MakeSample();
            item.TrackingState = TrackingState.Added;
            
            _service.Save(ref item);
            
            var result = _service.GetById(item.<xsl:value-of select="@name"/>Id);
            Assert.IsNotNull(result);
        }    
  </xsl:template>

  <xsl:template name="CanDelete">
        [TestMethod]
        [TestCategory("2-Service Layer")]
        [Owner("VS Template")]
        [Priority(2)]
        public void CanDelete<xsl:value-of select="@name"/>()
        {
            _log.Info("CanDelete<xsl:value-of select="@name"/>");
            var item = new <xsl:value-of select="@name"/>Info();
            
            item.MakeSample();       
            item.TrackingState = TrackingState.Added;
            _service.Save(ref item);
            
            var id = item.<xsl:value-of select="@name"/>Id;               
            _log.Info("Delete id = " + id.ToString());
            _service.Delete(id);
            
            var result = _service.GetById(id);
    
            Assert.IsNull(result);
        }            
  </xsl:template>
    
  <xsl:template name="footer">
}
  </xsl:template>

</xsl:stylesheet>
