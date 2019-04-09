<?xml version = '1.0' encoding = 'iso-8859-1'?>
<!-- Author  : S.ROKKANEN/RO2K - 18/06/2016 -->
<!-- Version : 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="../header.xsl"/>
  <xsl:import href="../variables.xsl"/>
  <xsl:output method="text" encoding="iso-8859-1"/>

  <xsl:param name="excludeKey">0</xsl:param>
  <xsl:param name="includeEntities"></xsl:param>
  <xsl:param name="excludeEntities"></xsl:param>

  <xsl:variable name="namespace"><xsl:value-of select="/ApiModel/@namespace"/></xsl:variable>
  <xsl:variable name="version">V1</xsl:variable>
  <xsl:variable name="dbNameContext">DatabaseContext</xsl:variable>

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>
{
    using Business;
    using Swashbuckle.Swagger.Annotations;
    using System.Net;
    using System.Net.Http;
    using System.Threading.Tasks;
    using System.Web.Http;
    #pragma warning disable // Disable all warnings
    <xsl:value-of select="$attributeGenerator"/>
  </xsl:template>

  <xsl:template match='/'>
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
      <xsl:with-param name="xslTemplate" select="$xslTemplate"/>
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    <xsl:apply-templates select="//Resource" mode="multi"/>
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template match="Resource" mode="multi">
    <xsl:call-template name="bodyInterface"/>
    <xsl:call-template name="bodyClass"/>
  </xsl:template>

  <xsl:template match="Resource">
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
      <xsl:with-param name="xslTemplate" select="$xslTemplate"/>
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    <xsl:call-template name="bodyInterface"/>
    <xsl:call-template name="bodyClass"/>
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template name="bodyInterface">
    public interface I<xsl:value-of select="@id"/>ControllerDefinition
    {<xsl:apply-templates select="Operations/Operation" mode="interface"/>
    }
    
  </xsl:template>

  <xsl:template name="bodyClass">
    <xsl:variable name="controler"><xsl:value-of select="@id"/>Controller</xsl:variable>
    <xsl:variable name="interface">I<xsl:value-of select="$controler"/>Definition</xsl:variable>
    [RoutePrefix("<xsl:value-of select="$version"/>")]
    public partial class <xsl:value-of select="$controler"/> : ApiController
    {
        private <xsl:value-of select="$interface"/> _implementation;
    
        /// <summary>
        /// Initializes a new instance of the &lt;see cref="<xsl:value-of select="$controler"/>"/&gt; class.
        /// </summary>
        /// <param name="service">The implementation http service.</param>
        public <xsl:value-of select="$controler"/>(<xsl:value-of select="$interface"/> implementation)
        {
            this._implementation = implementation;
        }
    <xsl:apply-templates select="Operations/Operation" mode="class"/>
    }
  </xsl:template>

  <xsl:template match="Operation" mode="interface">
    
  </xsl:template>

  <xsl:template match="Operation" mode="class">
    <xsl:choose>
      <xsl:when test="contains(@id,'list')"><xsl:call-template name="entities_list"/></xsl:when>
      <xsl:when test="contains(@id,'findById')"><xsl:call-template name="entities_findById"/></xsl:when>
      <xsl:when test="contains(@id,'create')"><xsl:call-template name="entities_create"/></xsl:when>
      <xsl:when test="contains(@id,'update')"><xsl:call-template name="entities_update"/></xsl:when>
      <xsl:when test="contains(@id,'delete')"><xsl:call-template name="entities_delete"/></xsl:when>
    </xsl:choose>

    <!-- 
        <xsl:call-template name="entities_upsert"/>
        <xsl:call-template name="entities_exists"/>
        <xsl:call-template name="entities_check_exists"/>
        <xsl:call-template name="entities_create_change_stream_get"/>
        <xsl:call-template name="entities_create_change_stream_post"/>
        <xsl:call-template name="entities_count"/>
        <xsl:call-template name="entities_findone"/>
        <xsl:call-template name="entities_batch_update"/>-->
  </xsl:template>

  <xsl:template name="declaration">
        private readonly ILog _log = LogManager.GetLogger(typeof(<xsl:value-of select="@id"/>Controller));
        // private readonly <xsl:value-of select="$dbNameContext"/> _dbContext = new <xsl:value-of select="$dbNameContext"/>();
  </xsl:template>

  <xsl:template name="entities_list">
    <xsl:call-template name="summary">
      <xsl:with-param name="title"><xsl:value-of select="Summary"/></xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="entity"><xsl:value-of select="../../@id"/></xsl:variable>
    <xsl:variable name="entities"><xsl:value-of select="../../@name"/></xsl:variable>
    <xsl:variable name="response"><xsl:value-of select="$entity"/>InfoResponse</xsl:variable>
    <xsl:variable name="queryName">FindAll<xsl:value-of select="$entities"/>Query</xsl:variable>    
        /// &lt;param name="id">Identifier.&lt;/param&gt;
        /// &lt;returns>list of entities&lt;/returns&gt;
        [HttpGet]
        [Route("<xsl:value-of select="$entities"/>")]
        [SwaggerOperation("<xsl:value-of select="$entity"/>_list")]
        [SwaggerResponse(HttpStatusCode.OK, Description = "OK, return list of entities", Type = typeof(<xsl:value-of select="$response"/>))]
        [SwaggerResponse(HttpStatusCode.NotFound, Description = "entity not found")]
        [SwaggerResponse(HttpStatusCode.Unauthorized, Description = HttpConstantMessages.Unauthorized)]
        public async Task&lt;HttpResponseMessage&gt; FindAllAsync()
        {
            return this._implementation.FindAllAsync();
        }
  </xsl:template>

  <xsl:template name="entities_upsert">
   <xsl:call-template name="summary">
      <xsl:with-param name="title"><xsl:value-of select="Summary"/></xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="entity"><xsl:value-of select="../../@id"/></xsl:variable>
    <xsl:variable name="entities"><xsl:value-of select="../../@name"/></xsl:variable>
        /// &lt;param name="id">Identifier.&lt;/param&gt;
        /// &lt;returns>list of entities&lt;/returns&gt;
        [HttpPut]
        [Route("<xsl:value-of select="@pluralName"/>")]
        [SwaggerOperation("<xsl:value-of select="$entity"/>_upsetr")]
        [SwaggerResponse(HttpStatusCode.OK, Description = "OK, update OK.", Type = typeof(List&lt;<xsl:value-of select="@name"/>Info&gt;))]
        [SwaggerResponse(HttpStatusCode.Unauthorized, Description = HttpConstantMessages.Unauthorized)]
        public async Task&lt;HttpResponseMessage&gt; UpsertAsync(string id)
        {
            return this._implementation.UpsertAsync(id);
        }
  </xsl:template>

  <xsl:template name="entities_create">
   <xsl:call-template name="summary">
      <xsl:with-param name="title"><xsl:value-of select="Summary"/></xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="entity"><xsl:value-of select="../../@id"/></xsl:variable>
    <xsl:variable name="dto"><xsl:value-of select="$entity"/>Info</xsl:variable>
    <xsl:variable name="entities"><xsl:value-of select="../../@name"/></xsl:variable>
        /// &lt;param name="id"><xsl:value-of select="@name"/>.&lt;/param&gt;
        /// &lt;returns>id&lt;/returns&gt;
        [HttpPost]
        [Route("<xsl:value-of select="$entities"/>")]
        [SwaggerOperation("<xsl:value-of select="$entity"/>_create")]
        [SwaggerResponse(HttpStatusCode.OK, Description = "OK, update OK.", Type = typeof(<xsl:value-of select="$entity"/>Info))]
        [SwaggerResponse(HttpStatusCode.Unauthorized, Description = HttpConstantMessages.Unauthorized)]
        public async Task&lt;HttpResponseMessage&gt; CreateAsync(<xsl:value-of select="$dto"/>&#160;<xsl:value-of select="$entity"/>)
        {
            return this._implementation.CreateAsync(<xsl:value-of select="$entity"/>);
        }
  </xsl:template>

  <xsl:template name="entities_findById">
    <xsl:call-template name="summary">
      <xsl:with-param name="title"><xsl:value-of select="Summary"/></xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="entity"><xsl:value-of select="../../@id"/></xsl:variable>
    <xsl:variable name="entities"><xsl:value-of select="../../@name"/></xsl:variable>
    <xsl:variable name="typeId"><xsl:value-of select="Parameters/Parameter[1]/@type"/></xsl:variable>
    <xsl:variable name="response"><xsl:value-of select="$entity"/>InfoResponse</xsl:variable>
    <xsl:variable name="queryName">FindBy<xsl:value-of select="$entity"/>IdQuery</xsl:variable>
        /// &lt;param name="id"><xsl:value-of select="$entity"/>.&lt;/param&gt;
        /// &lt;returns>id&lt;/returns&gt;
        [HttpGet]
        [Route("<xsl:value-of select="$entities"/>/{id}")]
        [SwaggerOperation("<xsl:value-of select="$entity"/>_findById")]
        [SwaggerResponse(HttpStatusCode.OK, Description = "OK, update OK.", Type = typeof(<xsl:value-of select="$entity"/>Info))]
        [SwaggerResponse(HttpStatusCode.Unauthorized, Description = HttpConstantMessages.Unauthorized)]
        public async Task&lt;HttpResponseMessage&gt; FindByIdAsync(<xsl:value-of select="$typeId"/> id)
        {
            return this._implementation.FindByIdAsync(id);            
        }
  </xsl:template>

  <xsl:template name="entities_exists">
    <xsl:call-template name="summary">
      <xsl:with-param name="title"><xsl:value-of select="Summary"/></xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="entity"><xsl:value-of select="../../@id"/></xsl:variable>
    <xsl:variable name="dto"><xsl:value-of select="$entity"/>Info</xsl:variable>
    <xsl:variable name="entities"><xsl:value-of select="../../@name"/></xsl:variable>
        /// &lt;param name="id"><xsl:value-of select="@name"/>.&lt;/param&gt;
        /// &lt;returns>id&lt;/returns&gt;
        [HttpHead]
        [Route("<xsl:value-of select="$entities"/>/{id}")]
        [SwaggerOperation("<xsl:value-of select="$entity"/>_exists")]
        [SwaggerResponse(HttpStatusCode.OK, Description = "OK, update OK.", Type = typeof(<xsl:value-of select="$dto"/>))]
        [SwaggerResponse(HttpStatusCode.Unauthorized, Description = HttpConstantMessages.Unauthorized)]
        public async Task&lt;HttpResponseMessage&gt; ExistsAsync(string id)
        {
            return this._implementation.ExistsAsync(id);
        }
  </xsl:template>

  <xsl:template name="entities_update">
    <xsl:call-template name="summary">
      <xsl:with-param name="title"><xsl:value-of select="Summary"/></xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="entity"><xsl:value-of select="../../@id"/></xsl:variable>
    <xsl:variable name="dto"><xsl:value-of select="$entity"/>Info</xsl:variable>
    <xsl:variable name="entities"><xsl:value-of select="../../@name"/></xsl:variable>
        /// &lt;param name="id"><xsl:value-of select="$entity"/>.&lt;/param&gt;
        /// &lt;returns>id&lt;/returns&gt;
        [HttpPut]
        [Route("<xsl:value-of select="$entities"/>/{id}")]
        [SwaggerOperation("<xsl:value-of select="$entity"/>_update")]
        [SwaggerResponse(HttpStatusCode.OK, Description = "OK, update OK.", Type = typeof(<xsl:value-of select="$dto"/>))]
        [SwaggerResponse(HttpStatusCode.Unauthorized, Description = HttpConstantMessages.Unauthorized)]
        public async Task&lt;HttpResponseMessage&gt; UpdateAsync(<xsl:value-of select="$entity"/> entity)
        {
            return this._implementation.UpdateAsync(entity);            
        }
  </xsl:template>

  <xsl:template name="entities_delete">
    <xsl:call-template name="summary">
      <xsl:with-param name="title"><xsl:value-of select="Summary"/></xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="entity"><xsl:value-of select="../../@id"/></xsl:variable>
    <xsl:variable name="dto"><xsl:value-of select="$entity"/>Info</xsl:variable>
    <xsl:variable name="entities"><xsl:value-of select="../../@name"/></xsl:variable>
     <xsl:variable name="typeId"><xsl:value-of select="Parameters/Parameter[1]/@type"/></xsl:variable>
        /// &lt;param name="id"><xsl:value-of select="@name"/>.&lt;/param&gt;
        /// &lt;returns>id&lt;/returns&gt;
        [HttpDelete]
        [Route("<xsl:value-of select="$entities"/>/{id}")]
        [SwaggerOperation("<xsl:value-of select="$entity"/>_delete")]
        [SwaggerResponse(HttpStatusCode.OK, Description = "OK, entity deleted.", Type = typeof(<xsl:value-of select="$dto"/>))]
        [SwaggerResponse(HttpStatusCode.Unauthorized, Description = HttpConstantMessages.Unauthorized)]
        public async Task&lt;HttpResponseMessage&gt; DeleteAsync(<xsl:value-of select="$typeId"/> id)
        {
            return this._implementation.DeleteAsync(id);            
        }
  </xsl:template>

  <xsl:template name="entities_check_exists">
    <xsl:call-template name="summary">
      <xsl:with-param name="title"><xsl:value-of select="Summary"/></xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="entity"><xsl:value-of select="../../@id"/></xsl:variable>
    <xsl:variable name="dto"><xsl:value-of select="$entity"/>Info</xsl:variable>
    <xsl:variable name="entities"><xsl:value-of select="../../@name"/></xsl:variable>
        /// &lt;param name="id"><xsl:value-of select="$entity"/>.&lt;/param&gt;
        /// &lt;returns>id&lt;/returns&gt;
        [HttpGet]
        [Route("<xsl:value-of select="$entities"/>/{id}/exists")]
        [SwaggerOperation("<xsl:value-of select="$entity"/>_check_exists")]
        [SwaggerResponse(HttpStatusCode.OK, Description = "OK, model instance exists.", Type = typeof(<xsl:value-of select="$dto"/>))]
        [SwaggerResponse(HttpStatusCode.Unauthorized, Description = HttpConstantMessages.Unauthorized)]
        public async Task&lt;HttpResponseMessage&gt; CheckExistsAsync(string id)
        {
            return this._implementation.CheckExistsAsync(id);
        }
  </xsl:template>

  <xsl:template name="entities_create_change_stream_get">
   <xsl:call-template name="summary">
      <xsl:with-param name="title"><xsl:value-of select="Summary"/></xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="entity"><xsl:value-of select="../../@id"/></xsl:variable>
    <xsl:variable name="dto"><xsl:value-of select="$entity"/>Info</xsl:variable>
    <xsl:variable name="entities"><xsl:value-of select="../../@name"/></xsl:variable>
        /// &lt;param name="id"><xsl:value-of select="@name"/>.&lt;/param&gt;
        /// &lt;returns>id&lt;/returns&gt;
        [HttpGet]
        [Route("<xsl:value-of select="$entities"/>/change-stream")]
        [SwaggerOperation("<xsl:value-of select="$entity"/>_create_change_stream")]
        [SwaggerResponse(HttpStatusCode.OK, Description = "OK.", Type = typeof(<xsl:value-of select="$dto"/>))]
        [SwaggerResponse(HttpStatusCode.Unauthorized, Description = HttpConstantMessages.Unauthorized)]
        public async Task&lt;HttpResponseMessage&gt; CreateChangeStreamAsync(string id)
        {
            return this._implementation.CreateChangeStreamAsync(id);      
        }
  </xsl:template>

  <xsl:template name="entities_create_change_stream_post">
     <xsl:call-template name="summary">
      <xsl:with-param name="title"><xsl:value-of select="Summary"/></xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="entity"><xsl:value-of select="../../@id"/></xsl:variable>
    <xsl:variable name="dto"><xsl:value-of select="$entity"/>Info</xsl:variable>
    <xsl:variable name="entities"><xsl:value-of select="../../@name"/></xsl:variable>
        /// &lt;param name="id"><xsl:value-of select="@name"/>.&lt;/param&gt;
        /// &lt;returns>id&lt;/returns&gt;
        [HttpPost]
        [Route("<xsl:value-of select="$entities"/>/change-stream")]
        [SwaggerOperation("<xsl:value-of select="$entity"/>_create_change_stream_post")]
        [SwaggerResponse(HttpStatusCode.OK, Description = "OK.", Type = typeof(<xsl:value-of select="$dto"/>))]
        [SwaggerResponse(HttpStatusCode.Unauthorized, Description = HttpConstantMessages.Unauthorized)]
        public async Task&lt;HttpResponseMessage&gt; CreateChangeStreamPostAsync(string id)
        {
            return this._implementation.CreateChangeStreamPostAsync(id); 
        }
  </xsl:template>

  <xsl:template name="entities_count">
     <xsl:call-template name="summary">
      <xsl:with-param name="title"><xsl:value-of select="Summary"/></xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="entity"><xsl:value-of select="../../@id"/></xsl:variable>
    <xsl:variable name="dto"><xsl:value-of select="$entity"/>Info</xsl:variable>
    <xsl:variable name="entities"><xsl:value-of select="../../@name"/></xsl:variable>
        /// &lt;param name="id"><xsl:value-of select="@name"/>.&lt;/param&gt;
        /// &lt;returns>id&lt;/returns&gt;
        [HttpGet]
        [Route("<xsl:value-of select="$entities"/>/count")]
        [SwaggerOperation("<xsl:value-of select="$entity"/>_count")]
        [SwaggerResponse(HttpStatusCode.OK, Description = "OK.", Type = typeof(int))]
        [SwaggerResponse(HttpStatusCode.Unauthorized, Description = HttpConstantMessages.Unauthorized)]
        public async Task&lt;HttpResponseMessage&gt; CountAsync()
        {
            return this._implementation.CountAsync(); 
        }
  </xsl:template>

  <xsl:template name="entities_findone">
    <xsl:call-template name="summary">
      <xsl:with-param name="title"><xsl:value-of select="Summary"/></xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="entity"><xsl:value-of select="../../@id"/></xsl:variable>
    <xsl:variable name="dto"><xsl:value-of select="$entity"/>Info</xsl:variable>
    <xsl:variable name="entities"><xsl:value-of select="../../@name"/></xsl:variable>
        /// &lt;param name="id"><xsl:value-of select="$entity"/>.&lt;/param&gt;
        /// &lt;returns>id&lt;/returns&gt;
        [HttpGet]
        [Route("<xsl:value-of select="$entities"/>/findOne")]
        [SwaggerOperation("<xsl:value-of select="$entity"/>_find_one")]
        [SwaggerResponse(HttpStatusCode.OK, Description = "OK.", Type = typeof(<xsl:value-of select="$dto"/>))]
        [SwaggerResponse(HttpStatusCode.Unauthorized, Description = HttpConstantMessages.Unauthorized)]
        public async Task&lt;HttpResponseMessage&gt; FindOneAsync(string id)
        {
            return this._implementation.FindOneAsync(id); 
        }
  </xsl:template>

  <xsl:template name="entities_batch_update">
    <xsl:call-template name="summary">
      <xsl:with-param name="title"><xsl:value-of select="Summary"/></xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="entity"><xsl:value-of select="../../@id"/></xsl:variable>
    <xsl:variable name="dto"><xsl:value-of select="$entity"/></xsl:variable>
    <xsl:variable name="entities"><xsl:value-of select="../../@name"/></xsl:variable>
        /// &lt;param name="id"><xsl:value-of select="$entity"/>.&lt;/param&gt;
        /// &lt;returns>id&lt;/returns&gt;
        [HttpPost]
        [Route("<xsl:value-of select="$entities"/>/update")]
        [SwaggerOperation("<xsl:value-of select="$entity"/>_batch_update")]
        [SwaggerResponse(HttpStatusCode.OK, Description = "OK.", Type = typeof(<xsl:value-of select="$dto"/>))]
        [SwaggerResponse(HttpStatusCode.Unauthorized, Description = HttpConstantMessages.Unauthorized)]
        public async Task&lt;HttpResponseMessage&gt; UpdateBatchAsync(string id)
        {
            return this._implementation.UpdateBatchAsync(id); 
        }
  </xsl:template>

  <xsl:template name="footer">
}
  </xsl:template>

  <xsl:template name="summary">
    <xsl:param name="title"/>
        /// &lt;summary&gt;
        /// <xsl:value-of select="$title"/>
        /// &lt;/summary&gt;</xsl:template>
</xsl:stylesheet>
