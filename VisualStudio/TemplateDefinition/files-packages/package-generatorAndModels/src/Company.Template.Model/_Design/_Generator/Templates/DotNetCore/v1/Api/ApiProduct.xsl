<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:output method="xml" encoding="iso-8859-1" indent="yes"/>

   <xsl:template match='/'>
   <xsl:apply-templates select='/ApiProduct/Entities'/>  
  </xsl:template>

  <xsl:template match="Entities">
    <ApiModel namespace="{../@namespace}">
    <xsl:apply-templates select="Entity"/>
    </ApiModel>
  </xsl:template>

  <xsl:template match="Entity">
    <Resource id="{@name}" name="{@plural}" routePrefix="v1">
      <Operations>
        <Operation id="{@name}_list" name="FindAllAsync" responseItem="object" query="FindAll{@plural}Query" httpMethod="HttpGet" version="" tags="" route="{@plural}">
          <Summary>Find all instances of the model matched by filter from the data source</Summary>
        </Operation>
        <Operation id="{@name}_findById" name="FindByIdAsync" responseItem="object" query="FindBy{@name}IdQuery" httpMethod="HttpGet" version="" tags="" route="{@plural}/{{id}}">
          <Summary>Find a model instance by id from the data source</Summary>
          <Parameters>
            <Parameter name="CategoryId" type="Guid"/>
          </Parameters>
        </Operation>
        <Operation id="{@name}_create" name="CreateAsync" responseItem="bool" query="Create{@name}Command" httpMethod="HttpPost" version="" tags="" route="{@plural}">
          <Summary>Create a new instance of the model and persist it into the data source</Summary>
          <Parameters>
            <Parameter name="{@name}" type="CategoryInfo"/>
          </Parameters>
        </Operation>
        <Operation id="{@name}_update" name="UpdateAsync" responseItem="bool" query="Update{@name}Command" httpMethod="HttpPut" version="" tags="" route="{@plural}/{{id}}">
          <Summary>Update attributes for a model instance and persist it into the data source.</Summary>
          <Parameters>
            <Parameter name="{@name}" type="object"/>
          </Parameters>
        </Operation>
        <Operation id="{@name}_delete" name="DeleteAsync" responseItem="bool" query="Delete{@name}Command" httpMethod="HttpDelete" version="" tags="" route="{@plural}/{{id}}">
          <Summary>Delete a model instance by id from the data source.</Summary>
          <Parameters>
            <Parameter name="id" type="Guid"/>
          </Parameters>
        </Operation>
      </Operations>
    </Resource>    
  </xsl:template>

</xsl:stylesheet>
