<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>


<xsl:param name="keep.relative.image.uris" select="0"/>

<!-- ==================================================================== -->

<xsl:template name="count.uri.path.depth">
  <xsl:param name="filename" select="''"/>
  <xsl:param name="count" select="0"/>

  <xsl:choose>
    <xsl:when test="contains($filename, '/')">
      <xsl:call-template name="count.uri.path.depth">
        <xsl:with-param name="filename"
                        select="substring-after($filename, '/')"/>
        <xsl:with-param name="count" select="$count + 1"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$count"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="trim.common.uri.paths">
  <xsl:param name="uriA" select="''"/>
  <xsl:param name="uriB" select="''"/>
  <xsl:param name="return" select="'A'"/>

  <xsl:choose>
    <xsl:when test="contains($uriA, '/') and contains($uriB, '/')                     and substring-before($uriA, '/') = substring-before($uriB, '/')">
      <xsl:call-template name="trim.common.uri.paths">
        <xsl:with-param name="uriA" select="substring-after($uriA, '/')"/>
        <xsl:with-param name="uriB" select="substring-after($uriB, '/')"/>
        <xsl:with-param name="return" select="$return"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$return = 'A'">
          <xsl:value-of select="$uriA"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$uriB"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="copy-string">
  <!-- returns 'count' copies of 'string' -->
  <xsl:param name="string"/>
  <xsl:param name="count" select="0"/>
  <xsl:param name="result"/>

  <xsl:choose>
    <xsl:when test="$count&gt;0">
      <xsl:call-template name="copy-string">
        <xsl:with-param name="string" select="$string"/>
        <xsl:with-param name="count" select="$count - 1"/>
        <xsl:with-param name="result">
          <xsl:value-of select="$result"/>
          <xsl:value-of select="$string"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$result"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ==================================================================== -->

 <!-- Image filename to use -->
<xsl:template match="imagedata|graphic|inlinegraphic" mode="filename.get">
   <xsl:choose>
   <xsl:when test="@entityref">
     <xsl:value-of select="unparsed-entity-uri(@entityref)"/>
   </xsl:when>
   <xsl:when test="@fileref">
    <xsl:apply-templates select="@fileref"/>
  </xsl:when>
  </xsl:choose>
</xsl:template>

<!-- Resolve xml:base attributes (taken from the DocBook Project) -->
<xsl:template match="@fileref">
  <!-- need a check for absolute urls -->
  <xsl:choose>
    <xsl:when test="contains(., ':') or starts-with(.,'/')">
      <!-- it has a uri scheme or starts with '/', so it is an absolute uri -->
      <xsl:value-of select="."/>
    </xsl:when>
    <xsl:when test="$keep.relative.image.uris != 0">
      <!-- leave it alone -->
      <xsl:value-of select="."/>
    </xsl:when>
    <xsl:otherwise>
      <!-- its a relative uri -->
      <xsl:call-template name="relative-uri">
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ==================================================================== -->
 
</xsl:stylesheet>
