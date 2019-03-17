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
    <xsl:variable name="typeId"><xsl:value-of select="Properties/Property[@propertyType = 1]/@type"/></xsl:variable>
    <xsl:variable name="unitOfWorkName">I<xsl:value-of select="$dbNameContext"/>UnitOfWork</xsl:variable>
    <xsl:variable name="iRepository">I<xsl:value-of select="@name"/>Repository</xsl:variable>    
    <xsl:variable name="repository">_unitOfWork.<xsl:value-of select="@name"/>Repository</xsl:variable>
    public partial class <xsl:value-of select="@name"/>Service : I<xsl:value-of select="@name"/>Service
    {
        private ILog log = LogManager.GetLogger(typeof(<xsl:value-of select="@name"/>Service));
        private readonly <xsl:value-of select="$unitOfWorkName"/> _unitOfWork;   
        private <xsl:value-of select="$iRepository"/> _repo;
        
        public <xsl:value-of select="@name"/>Service(<xsl:value-of select="$unitOfWorkName"/> unitOfWork)
        {
            _unitOfWork = unitOfWork;
            _repo = <xsl:value-of select="$repository"/>;
        }
                
        public async Task&lt;IEnumerable&lt;<xsl:value-of select="@name"/>&gt;&gt; GetAll()
        {
            log.Info("GetAll");
            var result = await _repo.Get<xsl:value-of select="@pluralName"/>();
            log.Info("Ok.");
            return result;            
        }
    
        public async Task&lt;<xsl:value-of select="@name"/>&gt; GetById(<xsl:value-of select="$typeId"/> id)
        {
            log.Info("GetById");
            var result = await _repo.Get<xsl:value-of select="@name"/>(id);                        
            log.Info("Ok.");
            return result;
        }
    
        public async void Save(<xsl:value-of select="@name"/> entity)
        {
            log.Info("Save");
            _repo.Insert(entity);
            await _unitOfWork.SaveChangesAsync();
            log.Info("Ok.");            
        }
    
        public async void Save(IEnumerable&lt;<xsl:value-of select="@name"/>&gt; entities)
        {
            log.Info("Save");
            
            foreach (var item in entities)
            {
                _repo.Insert(item);
            }
            
            await _unitOfWork.SaveChangesAsync();
            log.Info("Ok.");
        }
                
        public async void Delete(<xsl:value-of select="$typeId"/> id)
        {
            log.Info("Delete by id");
            await _repo.Delete<xsl:value-of select="@name"/>(id);
            await _unitOfWork.SaveChangesAsync();
            log.Info("Ok.");
        }
                
        public async Task&lt;IEnumerable&lt;<xsl:value-of select="@name"/>&gt;&gt; Get(Expression&lt;Func&lt;<xsl:value-of select="@name"/>, bool&gt;&gt; expression)
        {
            log.Info("Get");
            var result = await _repo.Get(expression);
            log.Info("OK.");

            return result;
        }    
        
        public IQueryable&lt;<xsl:value-of select="@name"/>&gt; Query()
        {
            log.Info("Query");
            return _repo.All();            
        }        
        <xsl:apply-templates select="RelationShips/RelationShip"/>
    }
  </xsl:template>
  
  <xsl:template match="RelationShip">
    <xsl:variable name="relationEntity"><xsl:value-of select="@type"/></xsl:variable>
    <xsl:variable name="typeIdRelation"><xsl:value-of select="../../../Entity[@name=$relationEntity]/Properties/Property[@propertyType = 1]/@type"/></xsl:variable>
    <xsl:variable name="repository">_unitOfWork.<xsl:value-of select="../../@name"/>Repository</xsl:variable>

    <xsl:if test="@relationType='many-to-one'">
        public async Task&lt;IEnumerable&lt;<xsl:value-of select="../../@name"/>&gt;&gt; GetBy<xsl:value-of select="@type"/>(<xsl:value-of select="$typeIdRelation"/> id)
        {
            log.Info("GetBy<xsl:value-of select="@type"/>");
            var result = await _repo.Get(item => item.<xsl:value-of select="@type"/>Id.Equals(id));
            log.Info("OK.");

            return result;
        }</xsl:if>
  </xsl:template>
 
  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Model
{
    using Interfaces;
    using log4net;
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Linq.Expressions;
    using System.Threading.Tasks;
    #pragma warning disable // Disable all warnings
    <xsl:value-of select="$attributeGenerator"/>
  </xsl:template>

  <xsl:template name="footer">
}
  </xsl:template>

</xsl:stylesheet>
