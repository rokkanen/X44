<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 11/02/2018 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text" encoding="iso-8859-1"/>

  <xsl:template match='/'>
  <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match='SoftwareSystem'>
@echo off
set project=Company.Template
set templateName=%1
set projectModelCsproj=%project%.Model\%project%.Model.csproj
cd ../SolutionTemplate
md %templateName%
cd %templateName%
md src
cd src    
    <xsl:apply-templates select="//Container" mode="prj"/>
	
REM /// Dependencies<xsl:apply-templates select="//RelationShip"/>

cd..
REM Copy files-packages
<xsl:apply-templates select="//Component[@technology='files-package']" mode="files-package"/>

cd src
REM /// Create solution
dotnet new sln --name %project%<xsl:apply-templates select="//Container" mode="sln"/>

REM Add the 4.x Model Project (contains the EDMX models) in the project solution
dotnet sln "%project%.sln" add %projectModelCsproj%

  </xsl:template>

  <xsl:template match="Container" mode="prj">

dotnet new <xsl:value-of select="@technology"/> --name <xsl:value-of select="@id"/>
del <xsl:value-of select="@id"/>\Class1.cs
REM /// Add Nuget packages<xsl:apply-templates select="Components/Component[@technology='nuget']" mode="nuget"/>
<xsl:apply-templates select="Components/Component[@technology='folder']" mode="folder"/>
  </xsl:template>
  
  <xsl:template match="Container" mode="sln">
<xsl:variable name="csProject"><xsl:value-of select="@id"/>\<xsl:value-of select="@id"/>.csproj</xsl:variable>
dotnet sln "%project%.sln" add <xsl:value-of select="$csProject"/>
</xsl:template>

  <xsl:template match="Component" mode="nuget">
    <xsl:variable name="csProject"><xsl:value-of select="../../@id"/>\<xsl:value-of select="../../@id"/>.csproj</xsl:variable>
dotnet add <xsl:value-of select="$csProject"/> package <xsl:value-of select="@id"/></xsl:template>
  
  <xsl:template match="Component" mode="folder">
mkdir <xsl:value-of select="@id"/></xsl:template>  

  <xsl:template match="RelationShip">
    <xsl:variable name="csProjectSrc"><xsl:value-of select="@sourceId"/>\<xsl:value-of select="@sourceId"/>.csproj</xsl:variable>   
    <xsl:variable name="csProjectDest"><xsl:value-of select="@targetId"/>\<xsl:value-of select="@targetId"/>.csproj</xsl:variable> 
dotnet add <xsl:value-of select="$csProjectSrc"/> reference <xsl:value-of select="$csProjectDest"/>
  </xsl:template>

  <xsl:template match="Component" mode="files-package">
robocopy ..\..\TemplateDefinition\files-packages\<xsl:value-of select="@id"/> . /S /E</xsl:template>

</xsl:stylesheet>
