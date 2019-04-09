<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables;xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>
  
  <xsl:variable name="namespace"><xsl:value-of select="/Model/@namespace"/></xsl:variable>
  <xsl:variable name="dbNameContext">IDatabaseContext</xsl:variable>

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Data
{
    using Interfaces;
    using Model;
    using System;
    using System.Collections.Generic;
    using System.Data.Entity;
    using System.Linq;
    using System.Linq.Expressions;
    using System.Threading.Tasks;
    using TrackableEntities.Patterns.EF6;
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

  <xsl:template match="Entity" mode="multi"><xsl:call-template name="body"/></xsl:template>

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
    <xsl:variable name="entityList">IEnumerable&lt;<xsl:value-of select="@name"/>&gt;</xsl:variable>
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">
    public partial class <xsl:value-of select="@name"/>Repository : Repository&lt;<xsl:value-of select="@name"/>&gt;, I<xsl:value-of select="@name"/>Repository
    {
        private readonly <xsl:value-of select="$dbNameContext"/> _context;

        public <xsl:value-of select="@name"/>Repository(<xsl:value-of select="$dbNameContext"/> context) : base(context as DbContext)
        {
            _context = context;
        }
    
        public async Task&lt;<xsl:value-of select="$entityList"/>&gt; Get<xsl:value-of select="@pluralName"/>()
        {            
            <xsl:value-of select="$entityList"/> items = await _context.<xsl:value-of select="@pluralName"/>
                //.Include(o => o.xxxx)
                .ToListAsync();
            return items;            
        }
        
        public async Task&lt;<xsl:value-of select="@name"/>> Get<xsl:value-of select="@name"/>(<xsl:value-of select="$typeId"/> id)
        {
            <xsl:value-of select="@name"/> item = await _context.<xsl:value-of select="@pluralName"/>
                //.Include(o => o.xxxx)
                 .SingleOrDefaultAsync(o => o.<xsl:value-of select="@name"/>Id == id);
            return item;            
        }
        
        public async Task&lt;bool> Delete<xsl:value-of select="@name"/>(<xsl:value-of select="$typeId"/> id)
        {
            <xsl:value-of select="@name"/> item = await _context.<xsl:value-of select="@pluralName"/>
                //.Include(o => o.xxxx)
                 .SingleOrDefaultAsync(o => o.<xsl:value-of select="@name"/>Id == id);
            ApplyDelete(item);
            return true;
        }     

        public async Task&lt;IEnumerable&lt;<xsl:value-of select="@name"/>&gt;&gt; Get(Expression&lt;Func&lt;<xsl:value-of select="@name"/>, bool&gt;&gt; expression)
        {
            return await _context.<xsl:value-of select="@pluralName"/>.Where(expression).ToListAsync();            
        }        
        
        public IQueryable&lt;<xsl:value-of select="@name"/>&gt; All()
        {
            DatabaseContext db = (DatabaseContext)_context;

            return db.<xsl:value-of select="@pluralName"/>.AsQueryable&lt;<xsl:value-of select="@name"/>&gt;();
        }            
        
        <xsl:apply-templates select="./RelationShips/RelationShip[@relationType='one-to-many']" mode="oneToMany"/>        
    }
  </xsl:if>      
  </xsl:template>

  <xsl:template match="RelationShip" mode="oneToMany">
    <xsl:variable name="entityId"><xsl:value-of select="../../@name"/>Id</xsl:variable>
    <xsl:variable name="type"><xsl:value-of select="@type"/></xsl:variable>
    <xsl:variable name="entityNameContext"><xsl:value-of select="//Model/Entities/Entity[@name=$type]/@pluralName"/></xsl:variable>

    <xsl:variable name="typeId"><xsl:value-of select="../../Properties/Property[@propertyType = 1]/@type"/></xsl:variable>
        public async Task&lt;IEnumerable&lt;<xsl:value-of select="@type"/>>> Get<xsl:value-of select="@name"/>(<xsl:value-of select="$typeId"/>&#160;<xsl:value-of select="$entityId"/>)
        {            
            return await _context.<xsl:value-of select="$entityNameContext"/>.Where(item => item.<xsl:value-of select="$entityId"/>.Equals(<xsl:value-of select="$entityId"/>)).ToListAsync();
        }
    </xsl:template>

  <xsl:template name="footer">
}</xsl:template>

</xsl:stylesheet>
