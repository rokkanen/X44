<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:import href="../globalParameters.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>
	<xsl:variable name="namespace"><xsl:value-of select="/Model/@namespace"/></xsl:variable>
  <xsl:variable name="listInterface">List</xsl:variable>

	<xsl:template match='/'>
    <xsl:call-template name="header"><xsl:with-param name="filename" select="$filename"/><xsl:with-param name="xslTemplate" select="$xslTemplate"/></xsl:call-template>
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
    <xsl:variable name="typeId">
      <xsl:value-of select="Properties/Property[@propertyType = 1]/@type"/>
    </xsl:variable>
    <xsl:variable name="selected">
      <xsl:call-template name="seleted-entities">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$selected=1">
      
    public partial class <xsl:value-of select="@name"/>
    {<xsl:call-template name="constructor"/>
    <xsl:apply-templates select="Properties/Property"/>
    <xsl:apply-templates select="RelationShips/RelationShip"/>
    <!--<xsl:call-template name="relationOneToMany"/>-->
    <xsl:call-template name="relationManyToMany"/>
    }
    </xsl:if>
  </xsl:template>

  <xsl:template match="Property">    
		public <xsl:value-of select="@type"/>&#160;<xsl:value-of select="@name"/>
		{ 
			  get { return _<xsl:value-of select="@name"/>; }
			  set
			  {
				    if (Equals(value, _<xsl:value-of select="@name"/>)) return;
				    _<xsl:value-of select="@name"/> = value;
			  }
		}
        private <xsl:value-of select="@type"/> _<xsl:value-of select="@name"/>;
  </xsl:template>
 
  <xsl:template match="RelationShip">
    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="@relationType='many-to-many' or @relationType='one-to-many'"><xsl:value-of select="$listInterface"/>&lt;<xsl:value-of select="@type"/>&gt;</xsl:when>
        <xsl:otherwise><xsl:value-of select="@type"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
		public <xsl:value-of select="$type"/>&#160;<xsl:value-of select="@name"/>
		{
			get { return _<xsl:value-of select="@name"/>; }
			set
			{
				if (Equals(value, _<xsl:value-of select="@name"/>)) return;
				_<xsl:value-of select="@name"/> = value;
			}
		}
		private <xsl:value-of select="$type"/>&#160;_<xsl:value-of select="@name"/>;                
  </xsl:template>
  
  <xsl:template name="entityId">
    <xsl:variable name="typeId"><xsl:value-of select="Properties/Property[@propertyType = 1]/@type"/></xsl:variable>      
        public <xsl:value-of select="$typeId"/> Id
        {
            get
            {
                return this.<xsl:value-of select="@name"/>Id;
            }
            set
            {
                this.<xsl:value-of select="@name"/>Id = value;
            }
        }
  </xsl:template>

  <xsl:template name="constructor">
        /// <summary>
        /// Initializes a new instance of the &lt;see cref="<xsl:value-of select="@name"/>"/&gt; class.
        /// </summary>
        public <xsl:value-of select="@name"/>()
        {
        }
  </xsl:template>

  <xsl:template name="relationOneToMany">
    <xsl:for-each select="RelationShips/RelationShip[@relationType='one-to-many']">
      <xsl:variable name="relationName">
        <xsl:value-of select="@relationName"/>
      </xsl:variable>
      <xsl:variable name="relationType">
        <xsl:value-of select="@type"/>
      </xsl:variable>
      <xsl:variable name="relationId"><xsl:value-of select="//Entity[@name=$relationType]/RelationShips/RelationShip[@relationName=$relationName]/@name"/>Id</xsl:variable>

        public virtual void Add<xsl:value-of select="@type"/>(<xsl:value-of select="@type"/>&#160;item)
        {   
            item.Id = this.<xsl:value-of select="$relationId"/>;
            this.<xsl:value-of select="@name"/>.Add(item);
         }
    </xsl:for-each>
    
  </xsl:template>

  <xsl:template name="relationManyToMany">
    <xsl:for-each select="RelationShips/RelationShip[@relationType='many-to-many']">
        public virtual void Add<xsl:value-of select="@type"/>(<xsl:value-of select="@type"/>&#160;item)
        {
            this.<xsl:value-of select="@name"/>.Add(item);
        }
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Model
{
    using System;
    using System.Collections.Generic;
    #pragma warning disable // Disable all warnings
    <xsl:value-of select="$attributeGenerator"/>

  </xsl:template>

<xsl:template name="footer">
}
</xsl:template>

</xsl:stylesheet>
