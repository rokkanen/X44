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

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Model
{
    using Data;
    using log4net;
    using System;
    using System.Collections.Generic;
    using System.Linq;
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
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    <xsl:call-template name="body"/>
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template name="body">
    <xsl:variable name="id"><xsl:value-of select="@name"/>Id</xsl:variable>
    <xsl:variable name="dto"><xsl:value-of select="@name"/>Info</xsl:variable>
    <xsl:variable name="typeId"><xsl:value-of select="Properties/Property[@propertyType = 1]/@type"/></xsl:variable>
    <xsl:variable name="query1">FindAll<xsl:value-of select="@pluralName"/>Query</xsl:variable>
    <xsl:variable name="query2">FindBy<xsl:value-of select="@name"/>IdQuery</xsl:variable>
    <xsl:variable name="query3">FindBy<xsl:value-of select="@name"/>NameQuery</xsl:variable>
    <xsl:variable name="query4">FindRelated<xsl:value-of select="@name"/>Query</xsl:variable>
    public partial class <xsl:value-of select="@name"/>Service : I<xsl:value-of select="@name"/>Service
    {
        private ILog _log = LogManager.GetLogger(typeof(<xsl:value-of select="@name"/>Service));
                
        public IEnumerable&lt;<xsl:value-of select="$dto"/>&gt; GetAll()
        {
            <xsl:value-of select="$query1"/> query = new <xsl:value-of select="$query1"/>();             
            query.Execute();                        
            return query.Response.entries;            
        }
    
        public <xsl:value-of select="$dto"/> GetById(<xsl:value-of select="$typeId"/> id)
        {
            <xsl:value-of select="$query2"/> query = new <xsl:value-of select="$query2"/>();             
            query.Parameter.<xsl:value-of select="$id"/> = id;
            query.Execute();                        
            var result = query.Response.entries;
            return result.FirstOrDefault();                        
        }
    
        public void Save(ref <xsl:value-of select="$dto"/> entity)
        {
            var command = new Save<xsl:value-of select="@name"/>Command();
            command.Parameter = entity;
            command.Execute();
            if (command.Ok) entity = command.Result;
        }
    
        public void Save(ref IEnumerable&lt;<xsl:value-of select="$dto"/>&gt; entities)
        {
            var command = new Save<xsl:value-of select="@pluralName"/>Command();
            command.Parameter = entities;
            command.Execute();
        }
                
        public void Delete(<xsl:value-of select="$typeId"/> id)
        {
            var command = new Delete<xsl:value-of select="@name"/>Command();
            command.Parameter = id;
            command.Execute();
        }<xsl:apply-templates select="RelationShips/RelationShip"/>
    }</xsl:template>
  
  <xsl:template match="RelationShip">
    <xsl:variable name="id"><xsl:value-of select="@type"/>Id</xsl:variable>
    <xsl:variable name="dto"><xsl:value-of select="../../@name"/>Info</xsl:variable>
    <xsl:variable name="relationEntity"><xsl:value-of select="@type"/></xsl:variable>
    <xsl:variable name="typeIdRelation"><xsl:value-of select="../../../Entity[@name=$relationEntity]/Properties/Property[@propertyType = 1]/@type"/></xsl:variable>
    <xsl:variable name="pluralName"><xsl:value-of select="../../@pluralName"/></xsl:variable>

    <xsl:if test="@relationType='many-to-one'">
        public IEnumerable&lt;<xsl:value-of select="$dto"/>&gt; GetBy<xsl:value-of select="@type"/>(<xsl:value-of select="$typeIdRelation"/> id)
        {        
            _log.Info("GetBy<xsl:value-of select="@type"/>");
            <xsl:value-of select="$dbNameContext"/> _dbContext = new <xsl:value-of select="$dbNameContext"/>();
            return _dbContext.<xsl:value-of select="$pluralName"/>.Where(item => item.<xsl:value-of select="$id"/>.Equals(id)).Project().To&lt;<xsl:value-of select="$dto"/>&gt;().ToList();                           
        }</xsl:if>
  </xsl:template>
 
  <xsl:template name="footer">
}</xsl:template>

</xsl:stylesheet>
