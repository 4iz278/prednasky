<?xml version="1.0" encoding="utf-8"?>	<!---->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:db="http://docbook.org/ns/docbook"
		xmlns:dbs="http://docbook.org/ns/docbook-slides"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:t="http://docbook.org/xslt/ns/template"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:tmpl="http://docbook.org/xslt/titlepage-templates"
		exclude-result-prefixes="db f h m t xs dbs tmpl"
                version="2.0">

<xsl:import href="/src/dbxslt2/xslt/slidesng/reveal/reveal.xsl"/>

<xsl:param name="reveal.uri">reveal/</xsl:param>
<xsl:param name="linenumbering" as="element()*"/>

<xsl:template name="t:user-css">
  <xsl:param name="node"/>
  <style type="text/css">
    .reveal { font-family: Calibri, sans-serif; }
    .reveal h1 { font-size: 3em; }
    .reveal h1, .reveal h2, .reveal h3, .reveal h4, .reveal h5, .reveal h6 {
              font-family: 'Calibri', sans-serif;
	      letter-spacing: 0em;
              line-height: 1em;
              text-align: center;
              /* font-stretch: ultra-condensed; */
	      /* font-weight: bold; */ }
    .slides .author { font-size: larger; font-weight: bold; }
    .slides .email { font-size: 70%; font-weight: normal; }
    .conftitle, .confdate { display: block; }
    .conftitle, .releaseinfo, .copyright { margin-top: 0.5em ! important; }
    .reveal pre { width: 100%; }
    .reveal table td { vertical-align: middle; }
    .reveal table td, .reveal table th { padding: 5px; text-align: inherit; }
    .reveal section img {
              border: none;
              box-shadow: none; }
    /* .reveal .slides { text-align: left; } */
    .releaseinfo, .author, .copyright { text-align: center; }
    .warning {
      background-color: red;
      margin-top: 5px;
      border: solid red 2px;
      border-radius: 10px;
      }
    table {
      margin-left: auto !important;
      margin-right: auto !important;
    }
    .variablelist { text-align: left; }
    dd { margin-left: 2em !important; }
    .title { font-weight: bold !important; }
  </style>
</xsl:template>

<!-- Keep relative URIs -->
<xsl:template match="@fileref">
  <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="db:author|db:othercredit" mode="m:titlepage-mode">
  <xsl:variable name="content" as="node()*">
    <xsl:choose>
      <xsl:when test="db:orgname">
        <xsl:apply-templates select="db:orgname"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="db:personname"/>
        <xsl:if test="db:email">
	  <br/>
          <xsl:apply-templates select="db:email"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <div>
    <xsl:sequence select="f:html-attributes(.)"/>
    <xsl:sequence select="$content"/>    
  </div>
</xsl:template>

<xsl:param name="syntax-highlighter">1</xsl:param>

<xsl:template match="db:tag[not(@class)] | db:tag[@class = 'element']">
  <a href="https://html.spec.whatwg.org/#the-{normalize-space(.)}-element" target="htmlls">
    <xsl:apply-imports/>
  </a>
</xsl:template>

<xsl:template match="processing-instruction('br')">
  <br/>
</xsl:template>

<xsl:template match="db:programlisting|db:synopsis"
	      mode="m:verbatim">
  <xsl:param name="lines" select="()" as="xs:string*"/>
  <xsl:variable name="this" select="."/>

  <xsl:variable name="startno" as="xs:decimal">
    <xsl:choose>
      <xsl:when test="@startinglinenumber">
        <xsl:value-of select="xs:decimal(@startinglinenumber) - 1"/>
      </xsl:when>
      <xsl:when test="@continuation = 'continues'">
        <xsl:variable name="prev"
             select="preceding::*[node-name(.)=node-name($this)][1]"/>
        <xsl:choose>
          <xsl:when test="empty($prev)">
            <xsl:value-of select="0"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="f:lastLineNumber($prev)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="numbered" as="xs:boolean"
                select="f:lineNumbering(.,'everyNth') != 0"/>

  <xsl:variable name="data-attr" as="attribute()*">
    <xsl:choose>
      <xsl:when test="$syntax-highlighter = '0'">
        <!-- nop -->
      </xsl:when>
      <xsl:when test="empty($lines)">
        <xsl:if test="$startno != 0 and $numbered">
          <xsl:attribute name="data-start" select="$startno + 1"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$startno != 0">
            <xsl:attribute name="data-line-offset" select="$startno"/>
            <xsl:variable name="adj-lines" as="xs:string*">
              <xsl:for-each select="$lines">
                <xsl:choose>
                  <xsl:when test="contains(.,'-')">
                    <xsl:variable name="l1" select="substring-before(.,'-')"/>
                    <xsl:variable name="l2" select="substring-after(.,'-')"/>
                    <xsl:value-of select="concat(xs:decimal($l1) + $startno,
                                                 '-',
                                                 xs:decimal($l2) + $startno)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="xs:decimal(.) + $startno"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:variable>
            <xsl:attribute name="data-line" select="string-join($adj-lines,',')"/>
          </xsl:when>
          <xsl:otherwise>
          <xsl:attribute name="data-line" select="string-join($lines,',')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="pre" as="element()">
    <pre>
      <xsl:sequence select="$data-attr"/>
      <xsl:sequence select="f:html-attributes(., @xml:id, local-name(.),
                                              f:syntax-highlight-class($this))"/>
      <code data-noescape="data-noescape">
        <xsl:apply-templates/>
      </code>
    </pre>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$syntax-highlighter = '0' and $numbered">
      <div class="numbered-verbatim">
        <table border="0">
          <tr>
            <td align="right" valign="top">
              <pre class="line-numbers">
                <xsl:for-each
                    select="tokenize(string-join($pre/h:code//text(),''),'&#10;')">
                  <code class="line-number">
                    <xsl:value-of select="position() + $startno"/>
                  </code>
                  <xsl:text>&#10;</xsl:text>
                </xsl:for-each>
              </pre>
            </td>
            <td valign="top">
              <xsl:sequence select="$pre"/>
            </td>
          </tr>
        </table>
      </div>
    </xsl:when>
    <xsl:when test="$syntax-highlighter = '0'"> <!-- and not($numbered) -->
      <div class="unnumbered-verbatim">
        <xsl:sequence select="$pre"/>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$pre"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:replaceable" priority="1">
  <xsl:call-template name="t:inline-italicseq"/>
</xsl:template>

</xsl:stylesheet>

