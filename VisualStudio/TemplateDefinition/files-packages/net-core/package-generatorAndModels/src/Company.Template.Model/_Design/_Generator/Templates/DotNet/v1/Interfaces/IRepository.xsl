<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>
  <xsl:variable name="namespace">
    <xsl:value-of select="/Model/@namespace"/>
  </xsl:variable>

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Interfaces
{
    using Model;
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Linq.Expressions;    
    using System.Threading.Tasks;
    using TrackableEntities.Patterns;
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
    <xsl:variable name="typeId"><xsl:value-of select="Properties/Property[@propertyType = 1]/@type"/></xsl:variable>
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">
    public partial interface I<xsl:value-of select="@name"/>Repository : IRepository&lt;<xsl:value-of select="@name"/>&gt;, IRepositoryAsync&lt;<xsl:value-of select="@name"/>>
    {
        Task&lt;IEnumerable&lt;<xsl:value-of select="@name"/>>> Get<xsl:value-of select="@pluralName"/>();
        Task&lt;<xsl:value-of select="@name"/>> Get<xsl:value-of select="@name"/>(<xsl:value-of select="$typeId"/> id);
        Task&lt;bool> Delete<xsl:value-of select="@name"/>(<xsl:value-of select="$typeId"/> id);<xsl:apply-templates select="./RelationShips/RelationShip[@relationType='one-to-many']" mode="oneToMany"/>
        Task&lt;IEnumerable&lt;<xsl:value-of select="@name"/>&gt;&gt; Get(Expression&lt;Func&lt;<xsl:value-of select="@name"/>, bool&gt;&gt; expression);
        IQueryable&lt;<xsl:value-of select="@name"/>&gt; All();        
    }
    </xsl:if>    
    </xsl:template>

  <xsl:template match="RelationShip" mode="oneToMany">
    <xsl:variable name="entityId"><xsl:value-of select="../../@name"/>Id</xsl:variable>
    <xsl:variable name="typeId"><xsl:value-of select="../../Properties/Property[@propertyType = 1]/@type"/></xsl:variable>    
        Task&lt;IEnumerable&lt;<xsl:value-of select="@type"/>>> Get<xsl:value-of select="@name"/>(<xsl:value-of select="$typeId"/>&#160;<xsl:value-of select="$entityId"/>);</xsl:template>
  
  <xsl:template name="footer">
}
  </xsl:template>

</xsl:stylesheet>
