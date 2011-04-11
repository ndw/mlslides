<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:db="http://docbook.org/ns/docbook"
		xmlns:f="http://docbook.org/xslt/ns/extension"
                xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:t="http://docbook.org/xslt/ns/template"
		xmlns:m="http://docbook.org/xslt/ns/mode"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:plugin="http://marklogic.com/extension/plugin"
                xmlns:xdmp="http://marklogic.com/xdmp"
                xmlns:map="http://marklogic.com/map"
		exclude-result-prefixes="db f h l m t xs plugin xdmp map"
                extension-element-prefixes="xdmp"
                version="2.0">

<xsl:import href="slides.xsl"/>

<xdmp:import-module namespace="http://marklogic.com/extension/plugin"
                    href="/MarkLogic/plugin/plugin.xqy"/>

<xsl:param name="deck" as="xs:string"/>
<xsl:param name="slideno" as="xs:decimal?"/>
<xsl:param name="toc" as="xs:boolean" select="false()"/>

<xsl:param name="linenumbering" as="element()*">
<ln path="literallayout" everyNth="0"/>
<ln path="programlisting" everyNth="0"/>
<ln path="programlistingco" everyNth="0"/>
<ln path="screen" everyNth="0"/>
<ln path="synopsis" everyNth="0"/>
<ln path="address" everyNth="0"/>
<ln path="epigraph/literallayout" everyNth="0"/>
</xsl:param>

<!-- ====================================================================== -->

<xsl:param name="l10n.locale.dir" select="'/etc/locales/'"/>
<xsl:param name="x-l10n.locale.dir" select="'/DocBook/base/common/locales/'"/>

<xsl:function name="f:load-locale" as="element(l:l10n)">
  <xsl:param name="lang" as="xs:string"/>

<!--
  <xsl:variable name="dir" select="resolve-uri($l10n.locale.dir)"/>
  <xsl:variable name="locale-file"
                select="resolve-uri(concat($lang,'.xml'), $dir)"/>
  <xsl:variable name="l10n" select="doc($locale-file)/l:l10n"/>
-->

  <xsl:variable name="capability" select="concat('http://docbook.org/localization/', $lang)"/>
  <xsl:variable name="pluginuri" select="plugin:plugins($capability)[1]"/>
  <xsl:variable name="pluginfn" select="plugin:capability($capability, $pluginuri)"/>

  <xsl:sequence select="xdmp:apply($pluginfn)"/>
</xsl:function>

<xsl:function name="f:check-locale" as="xs:boolean">
  <xsl:param name="lang" as="xs:string"/>

  <xsl:variable name="capability" select="concat('http://docbook.org/localization/', $lang)"/>
  <xsl:variable name="pluginuri" select="plugin:plugins($capability)[1]"/>
  <xsl:variable name="pluginfn" select="plugin:capability($capability, $pluginuri)"/>

  <xsl:sequence select="exists($pluginfn)"/>
</xsl:function>

<!-- ====================================================================== -->

<xsl:template match="/">
  <xsl:choose>
    <xsl:when test="$toc">
      <xsl:apply-templates select="db:slides" mode="toc"/>
    </xsl:when>
    <xsl:when test="empty($slideno)">
      <xsl:apply-templates select="db:slides"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="(//db:foilgroup|//db:foil)[position()=$slideno]"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:slides">
  <html>
    <head>
      <xsl:call-template name="t:head"/>
    </head>
    <body>
      <xsl:call-template name="floating-nav"/>
      <xsl:call-template name="t:slides-titlepage"/>
    </body>
  </html>
</xsl:template>

<xsl:template match="db:slides" mode="toc">
  <html>
    <head>
      <xsl:call-template name="t:head"/>
    </head>
    <body>
      <div id="foilcontainer" class="foil">
        <div id="foilheader" class="header">
          <h1>Contents</h1>
        </div>
        <div id="foilbody" class="body">
          <ul>
            <li><a href=".">Home</a></li>
          </ul>
          <xsl:if test="db:foil">
            <ul>
              <xsl:apply-templates select="db:foil"
                                   mode="m:slidetoc"/>
            </ul>
          </xsl:if>
          <xsl:if test="db:foilgroup">
            <ul>
              <xsl:apply-templates select="db:foilgroup"
                                   mode="m:slidetoc"/>
            </ul>
          </xsl:if>
        </div>
      </div>
    </body>
  </html>
</xsl:template>

<xsl:template name="floating-nav">
  <xsl:variable name="notes" select="0"/>

  <xsl:variable name="home" as="xs:string" select="f:filename(/db:slides, $notes)"/>
  <xsl:variable name="up" as="xs:string?">
    <xsl:if test="self::db:foil">
      <xsl:value-of select="f:filename(parent::*, $notes)"/>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="pfoils"
		select="(preceding::db:foil
			 |preceding-sibling::db:foil
			 |parent::db:foilgroup
			 |parent::db:slides)"/>

  <xsl:variable name="prev" as="xs:string?">
    <xsl:if test="$pfoils">
      <xsl:value-of select="f:filename($pfoils[last()], $notes)"/>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="nfoils"
		select="(following::db:foil
			 |following-sibling::db:foil
			 |following::db:foilgroup
			 |db:foil|db:foilgroup)"/>

  <xsl:variable name="next" as="xs:string?">
    <xsl:if test="$nfoils">
      <xsl:value-of select="f:filename($nfoils[1], $notes)"/>
    </xsl:if>
  </xsl:variable>

  <div id="nav">
    <xsl:if test="$home != $up">
      <a href="{$home}">↟</a>
      <xsl:text>&#160;</xsl:text>
    </xsl:if>
    <xsl:if test="self::db:slides">
      <a href="toc">⊡</a>
      <xsl:text>&#160;</xsl:text>
    </xsl:if>
    <xsl:if test="$prev">
      <a href="{$prev}">⟵</a>
      <xsl:text>&#160;</xsl:text>
    </xsl:if>
    <xsl:if test="$up">
      <a href="{$up}">↑</a>
      <xsl:text>&#160;</xsl:text>
    </xsl:if>
    <xsl:if test="$next">
      <a href="{$next}">⟶</a>
      <xsl:text>&#160;</xsl:text>
    </xsl:if>
  </div>
</xsl:template>

<xsl:template match="db:foil|db:foilgroup">
  <!--
  <xsl:message>
    <xsl:value-of select="concat('Processing: ', @xml:id)"/>
  </xsl:message>
  -->
  <html>
    <head>
      <xsl:call-template name="t:head"/>
    </head>
    <body>
      <xsl:call-template name="floating-nav"/>
      <div id="foilcontainer">
        <xsl:choose>
          <xsl:when test="following::db:foil|db:foil">
            <xsl:attribute name="class" select="'foil'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class" select="'lastfoil'"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="t:foil-header"/>
        <xsl:call-template name="t:foil-body">
          <xsl:with-param name="notes" select="0" tunnel="yes"/>
        </xsl:call-template>
        <xsl:call-template name="t:foil-footer"/>
      </div>
    </body>
  </html>
</xsl:template>

<!-- ====================================================================== -->

<xsl:template name="css-style">
  <xsl:choose>
    <xsl:when test="$docbook.css.inline = 0">
      <link rel="stylesheet" type="text/css" href="{$docbook.css}"/>
    </xsl:when>
    <xsl:otherwise>
      <style type="text/css">
	<xsl:copy-of select="unparsed-text($docbook.css, 'us-ascii')"/>
      </style>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:if test="processing-instruction('background')">
    <style type="text/css">
div.foil {
   background-image: url(<xsl:value-of select="processing-instruction('background')"/>);
}
    </style>
  </xsl:if>
</xsl:template>

<xsl:template name="t:foil-footer">
  <xsl:variable name="nfoils"
		select="(following::db:foil
			 |following-sibling::db:foil
			 |following::db:foilgroup
			 |db:foil|db:foilgroup)"/>

  <div id="foilfooter" class="footer">
    <div class="footertext">
      <span class="slideno">
        <xsl:choose>
          <xsl:when test="false() and $nfoils">
            <a href="{f:filename($nfoils[1], 0)}">Slide </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Slide </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="if (self::db:foil)
                              then count(preceding::db:foil)
                                   +count(preceding::db:foilgroup)
                                   +count(ancestor::db:foilgroup)
                                   +1
                              else count(preceding::db:foil)
                                   +count(preceding::db:foilgroup)
                                   +1"/>
      </span>
      <span class="slidecopy">
        <xsl:apply-templates select="/db:slides/db:info/db:copyright"/>
      </span>
    </div>
  </div>
</xsl:template>

<xsl:template match="db:phrase[@revisionflag='deleted']">
  <del>
    <xsl:apply-imports/>
  </del>
</xsl:template>

<!-- ============================================================ -->

<xsl:function name="f:filename" as="xs:string">
  <xsl:param name="foil" as="element()"/>
  <xsl:param name="notes"/>

  <xsl:variable name="num" as="xs:string">
    <xsl:choose>
      <xsl:when test="$foil/self::db:slides">
        <xsl:value-of select="''"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count($foil/preceding::db:foilgroup)
                              + count($foil/ancestor::db:foilgroup)
                              + count($foil/preceding::db:foil) + 1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="p1" select="count($foil/preceding::db:foilgroup)"/>
  <xsl:variable name="p2" select="count($foil/ancestor::db:foilgroup)"/>
  <xsl:variable name="p3" select="count($foil/preceding::db:foil)"/>

  <!--
  <xsl:message>
    <xsl:value-of select="concat('filename: ', $foil/@xml:id, ': ', $num, ' (',$p1,',',$p2,',',$p3,')')"/>
  </xsl:message>
  -->

  <xsl:value-of select="concat('/slides', substring-before($deck, '/slides.xml'), '/', $num)"/>
</xsl:function>

</xsl:stylesheet>
