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
  <xsl:variable name="newHttpHandler">new NativeMessageHandler()</xsl:variable>

  <xsl:template name="namespace">
namespace <xsl:value-of select="$namespace"/>.Client.Services
{
    using ModernHttpClient;
    using Newtonsoft.Json;
    using <xsl:value-of select="$namespace"/>.Model;
    using System;
    using System.Collections.ObjectModel;
    using System.Net.Http;
    using System.Threading.Tasks;

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
    <xsl:call-template name="SwaggerException"/>
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template match="Resource" mode="multi">
    <xsl:call-template name="body"/>
  </xsl:template>

  <xsl:template match="Resource">
    <xsl:call-template name="header">
      <xsl:with-param name="filename" select="$filename"/>
      <xsl:with-param name="xslTemplate" select="$xslTemplate"/>
    </xsl:call-template>
    <xsl:call-template name="namespace"/>
    <xsl:call-template name="body"/>
    <xsl:call-template name="SwaggerException"/>
    <xsl:call-template name="footer"/>
  </xsl:template>

  <xsl:template name="body">
    public partial class <xsl:value-of select="@id"/>Client
    {   
        private string _baseUrl = "";
        private System.Lazy&lt;JsonSerializerSettings&gt; _settings;
        private int _timeOut;
        
        public <xsl:value-of select="@id"/>Client(string baseUrl, int timeOut = 15)
        {
            BaseUrl = baseUrl; 
            _timeOut = timeOut;
            _settings = new System.Lazy&lt;JsonSerializerSettings&gt;(() => {
                var settings = new JsonSerializerSettings();
                UpdateJsonSerializerSettings(settings);
                return settings;
            });
        }
       
        public string BaseUrl 
        {
            get { return _baseUrl; }
            set { _baseUrl = value; }
        }
        
        partial void UpdateJsonSerializerSettings(JsonSerializerSettings settings);
        partial void ProcessResponse(System.Net.Http.HttpClient client, System.Net.Http.HttpResponseMessage response);
   
        <xsl:apply-templates select="Operations/Operation"/>
    }
  </xsl:template>

  <xsl:template match="Operation">
    <xsl:choose>
      <xsl:when test="@httpMethod='HttpGet'"><xsl:call-template name="http_get_template"/></xsl:when>
      <xsl:when test="@httpMethod='HttpPost'"><xsl:call-template name="http_post_template"/></xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
 
  <xsl:template name="http_get_template">
    <xsl:variable name="typeId"><xsl:value-of select="Parameters/Parameter[1]/@type"/></xsl:variable>
    <xsl:variable name="routePrefix">/<xsl:value-of select="../../@routePrefix"/>/</xsl:variable>     
    <xsl:variable name="response">ObservableCollection&lt;<xsl:value-of select="@responseItem"/>&gt;</xsl:variable>
    <xsl:variable name="queryName"><xsl:value-of select="@query"/></xsl:variable>
    <xsl:variable name="operationName"><xsl:value-of select="@id"/></xsl:variable>
    <xsl:variable name="parameterComment"><xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter" mode="comment" /></xsl:if></xsl:variable>
    <xsl:variable name="parameterCall">
       <xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter" mode="call" /></xsl:if>
    </xsl:variable>
    <xsl:variable name="parameterIsNull">
      <xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter[not(@default)]" mode="isNull" /></xsl:if>
    </xsl:variable>
    <xsl:variable name="parameterInitializePath">
       <xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter[@in='path']" mode="initialize" /></xsl:if>
    </xsl:variable>
    <xsl:variable name="parameterInitializeQuery">
       <xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter[@in='query']" mode="initialize" /></xsl:if>
    </xsl:variable>    
    <xsl:variable name="endRootUri">
       <xsl:if test="Parameters/Parameter">?</xsl:if>
    </xsl:variable>
    <xsl:variable name="endCodeInit">
       <xsl:if test="Parameters/Parameter">
            urlBuilder.Length--;</xsl:if>
    </xsl:variable>    
        public async Task&lt;<xsl:value-of select="$response"/>&gt; <xsl:value-of select="@name"/>(<xsl:value-of select="$parameterCall"/>)
        {<xsl:value-of select="$parameterIsNull"/>
           
            var urlBuilder = new System.Text.StringBuilder();
            urlBuilder.Append(BaseUrl).Append("<xsl:value-of select="$routePrefix"/><xsl:value-of select="@route"/><xsl:value-of select="$endRootUri"/>");
            <xsl:value-of select="$parameterInitializePath"/>
            <xsl:value-of select="$parameterInitializeQuery"/>
            <xsl:value-of select="$endCodeInit"/>
            var client = new HttpClient(<xsl:value-of select="$newHttpHandler"/>);
            client.Timeout = TimeSpan.FromSeconds(_timeOut);
            JsonSerializer _serializer = new JsonSerializer();
            var url = urlBuilder.ToString();            
            var response = await client.GetAsync(url).ConfigureAwait(false);
            var headers = System.Linq.Enumerable.ToDictionary(response.Headers, h_ => h_.Key, h_ => h_.Value);
            foreach (var item_ in response.Content.Headers)
                headers[item_.Key] = item_.Value;
            ProcessResponse(client, response);
            try {
                var status = ((int)response.StatusCode).ToString();
                if (status == "200") {
                    var responseData = await response.Content.ReadAsStringAsync().ConfigureAwait(false); 
                    var result = default(<xsl:value-of select="$response"/>); 
                    try {
                        result = JsonConvert.DeserializeObject&lt;<xsl:value-of select="$response"/>&gt;(responseData, _settings.Value);
                        return result; 
                    } 
                    catch (System.Exception exception) {
                        throw new SwaggerException("Could not deserialize the response body.", status, responseData, headers, exception);
                    }
                }
                else
                if (status == "401") {
                    var responseData = await response.Content.ReadAsStringAsync().ConfigureAwait(false); 
                    throw new SwaggerException("Unauthorized, the correct api_key must be specified", status, responseData, headers, null);
                }
                else
                if (status == "404") {
                    var responseData = await response.Content.ReadAsStringAsync().ConfigureAwait(false); 
                    var result = default(string); 
                    try {
                        result = JsonConvert.DeserializeObject&lt;string&gt;(responseData, _settings.Value);
                    } 
                    catch (System.Exception exception) {
                        throw new SwaggerException("Could not deserialize the response body.", status, responseData, headers, exception);
                    }
                    throw new SwaggerException&lt;string&gt;("Pas de données trouvées.", status, responseData, headers, result, null);
                }
                else
                if (status == "500") {
                    var responseData = await response.Content.ReadAsStringAsync().ConfigureAwait(false); 
                    throw new SwaggerException("Unexpected error.", status, responseData, headers, null);
                }
                else
                if (status != "200" &amp;&amp; status != "204") {
                    var responseData = await response.Content.ReadAsStringAsync().ConfigureAwait(false); 
                    throw new SwaggerException("The HTTP status code of the response was not expected (" + (int)response.StatusCode + ").", status, responseData, headers, null);
                }
                return default(<xsl:value-of select="$response"/>);
            }
            finally {
                if (client != null)
                    client.Dispose();
            }
        }
  </xsl:template>
  
  <xsl:template name="http_post_template">
    <xsl:variable name="typeId"><xsl:value-of select="Parameters/Parameter[1]/@type"/></xsl:variable>
    <xsl:variable name="routePrefix">/<xsl:value-of select="../../@routePrefix"/>/</xsl:variable>     
    <xsl:variable name="response"><xsl:value-of select="@responseItem"/></xsl:variable>
    <xsl:variable name="queryName"><xsl:value-of select="@query"/></xsl:variable>
    <xsl:variable name="operationName"><xsl:value-of select="@id"/></xsl:variable>
    <xsl:variable name="parameterComment"><xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter" mode="comment" /></xsl:if></xsl:variable>
    <xsl:variable name="parameterCall">
       <xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter" mode="call" /></xsl:if>
    </xsl:variable>
    <xsl:variable name="parameterIsNull">
      <xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter[not(@default)]" mode="isNull" /></xsl:if>
    </xsl:variable>
    <xsl:variable name="parameterInitializePath">
       <xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter[@in='path']" mode="initialize" /></xsl:if>
    </xsl:variable>
    <xsl:variable name="parameterInitializeQuery">
       <xsl:if test="Parameters/Parameter"><xsl:apply-templates select="//Operation[@id=$operationName]/Parameters/Parameter[@in='query']" mode="initialize" /></xsl:if>
    </xsl:variable>    
    <xsl:variable name="endRootUri">
       <xsl:if test="Parameters/Parameter">?</xsl:if>
    </xsl:variable>
    <xsl:variable name="endCodeInit">
       <xsl:if test="Parameters/Parameter">
            urlBuilder.Length--;</xsl:if>
    </xsl:variable>    
        public async Task&lt;<xsl:value-of select="$response"/>&gt; <xsl:value-of select="@name"/>(<xsl:value-of select="$parameterCall"/>)
        {<xsl:value-of select="$parameterIsNull"/>
            var urlBuilder = new System.Text.StringBuilder();
            urlBuilder.Append(BaseUrl).Append("<xsl:value-of select="$routePrefix"/><xsl:value-of select="@route"/><xsl:value-of select="$endRootUri"/>");
            <xsl:value-of select="$parameterInitializePath"/>
            <xsl:value-of select="$parameterInitializeQuery"/>
            <xsl:value-of select="$endCodeInit"/>
            var client = new HttpClient(<xsl:value-of select="$newHttpHandler"/>);
            client.Timeout = TimeSpan.FromSeconds(_timeOut);
            JsonSerializer _serializer = new JsonSerializer();    
            var url = urlBuilder.ToString(); 
            var response = await client.PostAsync(url, null).ConfigureAwait(false);
            var headers = System.Linq.Enumerable.ToDictionary(response.Headers, h_ => h_.Key, h_ => h_.Value);
            foreach (var item_ in response.Content.Headers)
                headers[item_.Key] = item_.Value;
            ProcessResponse(client, response);
            try {
                var status = ((int)response.StatusCode).ToString();
                if (status == "200") {
                    return true;
                }
                else
                if (status == "406") {
                    var responseData = await response.Content.ReadAsStringAsync().ConfigureAwait(false); 
                    throw new SwaggerException("Erreur NOVA", status, responseData, headers, null);
                }
                else
                if (status != "200" &amp;&amp; status != "406") {
                    var responseData = await response.Content.ReadAsStringAsync().ConfigureAwait(false); 
                    throw new SwaggerException("The HTTP status code of the response was not expected (" + (int)response.StatusCode + ").", status, responseData, headers, null);
                }
                return default(<xsl:value-of select="$response"/>);
            }
            finally {
                if (client != null)
                    client.Dispose();
            }
        }
  </xsl:template>

  <xsl:template match="Parameter" mode="call">        <xsl:value-of select="@type"/>&#160;<xsl:value-of select="@name"/>&#160;<xsl:value-of select="@default"/><xsl:if test="count(following-sibling::*)!=0">, </xsl:if></xsl:template>

  
  <xsl:template match="Parameter[not(@default)]" mode="isNull">
            if (<xsl:value-of select="@name"/> == null)
                throw new System.ArgumentNullException("<xsl:value-of select="@name"/>");</xsl:template>
  
  <xsl:template match="Parameter[@in='query']" mode="initialize">
    <xsl:variable name="lineofcode">
      <xsl:choose>
         <xsl:when  test="@default">&#160;&#160;&#160;if (<xsl:value-of select="@name"/> != null) urlBuilder.Append("<xsl:value-of select="@name"/>=").Append(System.Uri.EscapeDataString(System.Convert.ToString(<xsl:value-of select="@name"/>, System.Globalization.CultureInfo.InvariantCulture))).Append("&amp;");
         </xsl:when>
         <xsl:otherwise><xsl:if test="position() != 1">&#160;&#160;&#160;</xsl:if>urlBuilder.Append("<xsl:value-of select="@name"/>=").Append(System.Uri.EscapeDataString(System.Convert.ToString(<xsl:value-of select="@name"/>, System.Globalization.CultureInfo.InvariantCulture))).Append("&amp;");
         </xsl:otherwise>
       </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$lineofcode"/>
  </xsl:template>
  
  <xsl:template match="Parameter[@in='path']" mode="initialize">
            urlBuilder.Replace("{<xsl:value-of select="@name"/>}", System.Uri.EscapeDataString(System.Convert.ToString(<xsl:value-of select="@name"/>, System.Globalization.CultureInfo.InvariantCulture)));</xsl:template>
   
  
  <xsl:template match="Parameter" mode="comment">/// &lt;param name="<xsl:value-of select="@name"/>"&gt;<xsl:value-of select="@description"/>&lt;/param&gt;
  </xsl:template>
  
  <xsl:template name="footer">
}
  </xsl:template>

  <xsl:template name="SwaggerException">
    <xsl:value-of select="$attributeGenerator"/>
    public class SwaggerException : System.Exception
    {
        public string StatusCode { get; private set; }
        public string Response { get; private set; }
        public System.Collections.Generic.Dictionary&lt;string, System.Collections.Generic.IEnumerable&lt;string&gt;&gt; Headers { get; private set; }

        public SwaggerException(string message, string statusCode, string response, System.Collections.Generic.Dictionary&lt;string, System.Collections.Generic.IEnumerable&lt;string&gt;&gt; headers, System.Exception innerException) 
            : base(message, innerException)
        {
            StatusCode = statusCode;
            Response = response; 
            Headers = headers;
        }

        public override string ToString()
        {
            return string.Format("HTTP Response: \n\n{0}\n\n{1}", Response, base.ToString());
        }
    }

    <xsl:value-of select="$attributeGenerator"/>
    public class SwaggerException&lt;TResult&gt; : SwaggerException
    {
        public TResult Result { get; private set; }

        public SwaggerException(string message, string statusCode, string response, System.Collections.Generic.Dictionary&lt;string, System.Collections.Generic.IEnumerable&lt;string&gt;&gt; headers, TResult result, System.Exception innerException) 
            : base(message, statusCode, response, headers, innerException)
        {
            Result = result;
        }
    }    
  </xsl:template>

</xsl:stylesheet>
