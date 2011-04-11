<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:db="http://docbook.org/ns/docbook"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:t="http://docbook.org/xslt/ns/template"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		exclude-result-prefixes="db f h m t xs"
                version="2.0">

<xsl:import href="/DocBook/base/html/docbook.xsl"/>

<xsl:output method="xhtml"/>

<xsl:param name="root.elements">
  <db:slides/>
</xsl:param>

<xsl:param name="docbook.css" select="'css/slides.css'"/>
<xsl:param name="jquery.js" select="'script/jquery-1.4.2.min.js'"/>
<xsl:param name="slides.js" select="'script/slides.js'"/>

<!-- ============================================================ -->

<xsl:template name="t:head">
  <xsl:param name="root" select="'not-used'"/>
  <xsl:param name="notes" select="0" tunnel="yes"/>

  <title>
    <xsl:choose>
      <xsl:when test="db:info/db:title">
	<xsl:value-of select="db:info/db:title"/>
      </xsl:when>
      <xsl:when test="db:title">
	<xsl:value-of select="db:title"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>???</xsl:text>
	<xsl:message>
	  <xsl:text>Warning: no title for root element?: </xsl:text>
	  <xsl:value-of select="local-name(.)"/>
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </title>

  <link rel="home" href="{f:filename(/db:slides, $notes)}" title="Home"/>
  <link rel="contents" title="Contents" href="toc"/>

  <xsl:if test="self::db:foil">
    <link rel="up" title="Up ({parent::*/@xml:id})" href="{f:filename(parent::*, $notes)}"/>
  </xsl:if>

  <link rel="first" title="First" href="{f:filename((//db:foil)[1], $notes)}"/>

  <xsl:variable name="pfoils"
		select="(preceding::db:foil
			 |preceding-sibling::db:foil
			 |parent::db:foilgroup
			 |parent::db:slides)"/>

  <xsl:if test="$pfoils">
    <link rel="prev" title="Previous"
	  href="{f:filename($pfoils[last()], $notes)}"/>
  </xsl:if>

  <xsl:variable name="nfoils"
		select="(following::db:foil
			 |following-sibling::db:foil
			 |following::db:foilgroup
			 |db:foil|db:foilgroup)"/>

  <xsl:if test="$nfoils">
    <link rel="next" title="Next ({$nfoils[1]/@xml:id})" href="{f:filename($nfoils[1], $notes)}"/>
  </xsl:if>

  <xsl:if test="$nfoils">
    <link rel="last" title="Last" href="{f:filename($nfoils[last()], $notes)}"/>
  </xsl:if>

  <xsl:for-each select="//db:foilgroup">
    <link rel="section" href="{f:filename(.,$notes)}">
      <xsl:variable name="title" select="(db:info/db:title|db:title)[1]"/>
      <xsl:attribute
	  name="title"
	  select="if (string-length($title) &gt; 20)
	          then concat(substring($title,1,17),'...')
		  else $title"/>
    </link>
  </xsl:for-each>

  <xsl:call-template name="css-style"/>
  <xsl:if test="$notes != 0">
    <link rel="stylesheet" type="text/css" href="notes.css" />
  </xsl:if>

  <script type="text/javascript" language="javascript" src="{$jquery.js}"/>
  <script type="text/javascript" src="{$slides.js}"/>

  <xsl:call-template name="javascript"/>
</xsl:template>

<xsl:template name="t:foil-header">
  <div class="header" id="foilheader">
    <xsl:apply-templates select="(db:title|db:info/db:title)[1]" mode="m:titlepage-mode"/>
  </div>
</xsl:template>

<xsl:template name="t:foil-body">
  <xsl:param name="notes" select="0" tunnel="yes"/>
  <div class="body" id="foilbody">
    <xsl:apply-templates select="node() except (db:foil|db:foilgroup)"/>

    <xsl:if test="self::db:foilgroup">
      <div class="itemizedlist">
        <ul>
          <xsl:apply-templates select="db:foil" mode="m:slidetoc"/>
        </ul>
      </div>
    </xsl:if>

  </div>
</xsl:template>

<xsl:template name="t:foil-footer">
  <div id="foilfooter" class="footer">

    <table cellpadding="0" cellspacing="0" width="100%" summary="layout hack">
      <tr>
	<td>&#160;</td>
	<td>
	  <xsl:apply-templates select="/db:slides/db:info/db:copyright"/>
	</td>
	<td>
	  <xsl:text>Slide </xsl:text>
	  <xsl:value-of select="if (self::db:foil)
				then count(preceding::db:foil)
				     +count(preceding::db:foilgroup)
				     +count(ancestor::db:foilgroup)
				     +1
				else count(preceding::db:foil)
				     +count(preceding::db:foilgroup)
				     +1"/>
	  <xsl:text>/</xsl:text>
	  <xsl:value-of select="count(//db:foilgroup|//db:foil)"/>
	</td>
      </tr>
    </table>
  </div>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:slides">
  <xsl:result-document href="index.html">
    <html>
      <head>
	<xsl:call-template name="t:head"/>
      </head>
      <body>
        <xsl:call-template name="t:slides-titlepage"/>
      </body>
    </html>
  </xsl:result-document>

  <xsl:result-document href="notes.html">
    <html>
      <head>
	<xsl:call-template name="t:head">
	  <xsl:with-param name="notes" select="1" tunnel="yes"/>
	</xsl:call-template>
	<link rel="bookmark" href="index.html" title="Foil"/>
      </head>
      <body>
	<h1>
	  <xsl:value-of select="db:info/db:title"/>
	</h1>
	<p>Start of presentation</p>
        <div id="foilfooter" class="footer"></div>
      </body>
    </html>
  </xsl:result-document>

  <xsl:result-document href="startup.html">
    <html>
      <head>
	<xsl:call-template name="t:head">
	  <xsl:with-param name="notes" select="1" tunnel="yes"/>
	</xsl:call-template>
      </head>
      <body id="startup">
	<h1>
	  <xsl:value-of select="db:info/db:title"/>
	</h1>
	<ul>
	  <li>
	    <a href="index.html" target="presentation">
	      <xsl:text>Open presentation</xsl:text>
	    </a>
	  </li>
	  <!--
	  <li>
	    <a href="notes.html" target="notes">
	      <xsl:text>Open notes</xsl:text>
	    </a>
	  </li>
	  -->
	</ul>
        <div id="foilfooter" class="footer"></div>
      </body>
    </html>
  </xsl:result-document>

  <xsl:apply-templates select="db:foil|db:foilgroup"/>

  <xsl:result-document href="toc.html">
    <html>
      <head>
	<xsl:call-template name="t:head"/>
      </head>
      <body>
	<h1>Contents</h1>
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
      </body>
    </html>
  </xsl:result-document>
</xsl:template>

<xsl:template name="t:slides-titlepage">
  <div class="titlepage">
    <h1>
      <xsl:apply-templates select="db:info/db:title/node()"/>
    </h1>
    <xsl:if test="db:info/db:subtitle">
      <h2>
        <xsl:apply-templates select="db:info/db:subtitle/node()"/>
      </h2>
    </xsl:if>
    <div class="author">
      <xsl:apply-templates select="db:info/db:author"
                           mode="m:titlepage-mode"/>
      <xsl:if test="db:info/db:author//db:orgname">
        <h2>
          <xsl:value-of select="(db:info/db:author//db:orgname)[1]"/>
        </h2>
      </xsl:if>
    </div>
    <xsl:if test="db:info/db:pubdate">
      <div class="pubdate">
        <h2>
          <xsl:value-of
              select="format-date(xs:date(db:info/db:pubdate[1]),'[D] [MNn,*-3] [Y0001]')"/>
        </h2>
      </div>
    </xsl:if>
  </div>
</xsl:template>

<xsl:template match="db:slides/db:info/db:title
		     |db:foilgroup/db:info/db:title
		     |db:foil/db:info/db:title
                     |db:foilgroup/db:title
                     |db:foil/db:title"
	      mode="m:titlepage-mode"
	      priority="100">
  <h1>
    <xsl:apply-templates/>
  </h1>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:foil|db:foilgroup">
  <xsl:result-document href="{f:filename(.,0)}">
    <html>
      <head>
	<xsl:call-template name="t:head"/>
	<link rel="bookmark" href="{f:filename(.,1)}" title="Speaker notes"/>
      </head>
      <body>
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
  </xsl:result-document>

  <xsl:result-document href="{f:filename(.,1)}">
    <html>
      <head>
	<xsl:call-template name="t:head">
	  <xsl:with-param name="notes" select="1" tunnel="yes"/>
	</xsl:call-template>
	<link rel="bookmark" href="{f:filename(.,0)}" title="Foil"/>
      </head>
      <body>
	<div class="speakernotes">
	  <xsl:call-template name="t:foil-header"/>
	  <div class="thumbnail">
	    <xsl:apply-templates select="node() except db:foil">
	      <xsl:with-param name="notes" select="1" tunnel="yes"/>
	    </xsl:apply-templates>
	    <xsl:if test="self::db:foilgroup">
	      <ul>
		<xsl:apply-templates select="db:foil" mode="m:slidetoc"/>
	      </ul>
	    </xsl:if>
	  </div>
	  <xsl:if test="db:speakernotes">
	    <div class="notes">
	      <h2>Notes</h2>
	      <xsl:apply-templates select="db:speakernotes/*"/>
	    </div>
	  </xsl:if>

	  <xsl:variable name="nfoils"
			select="(following::db:foil
				|following-sibling::db:foil
				|following::db:foilgroup
				|db:foil|db:foilgroup)"/>

	  <xsl:if test="$nfoils">
	    <p>
	      <xsl:text>Next: </xsl:text>
	      <cite>
		<xsl:value-of select="$nfoils[1]/db:info/db:title"/>
	      </cite>
	    </p>
	  </xsl:if>

	  <xsl:call-template name="t:foil-footer"/>
	</div>
      </body>
    </html>
  </xsl:result-document>

  <xsl:apply-templates select="db:foil"/>
</xsl:template>

<xsl:template match="db:speakernotes"/>

<!-- ============================================================ -->

<xsl:template match="db:foilgroup" mode="m:slidetoc">
  <li>
    <a href="{f:filename(.,0)}">
      <xsl:value-of select="db:info/db:title"/>
    </a>
    <ul>
      <xsl:apply-templates select="db:foil" mode="m:slidetoc"/>
    </ul>
  </li>
</xsl:template>

<xsl:template match="db:foil" mode="m:slidetoc">
  <xsl:if test="not(contains(concat(' ', @role, ' '),' notoc '))">
    <li>
      <a href="{f:filename(.,0)}">
        <xsl:value-of select="(db:info/db:title|db:title)[1]"/>
      </a>
    </li>
  </xsl:if>
</xsl:template>

<!-- ============================================================ -->

<xsl:function name="f:filename" as="xs:string">
  <xsl:param name="foil" as="element()"/>
  <xsl:param name="notes"/>

  <xsl:variable name="num" as="xs:string">
    <xsl:choose>
      <xsl:when test="$foil/self::db:slides">/</xsl:when>
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

  <xsl:value-of select="$num"/>
</xsl:function>

</xsl:stylesheet>
