<?xml version="1.0" encoding="iso-8859-1"?>
<!--
dblatex(1) XSL user stylesheet for asciidoc(1).
See dblatex(1) -p option.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- TOC links in the titles, and in blue. -->
  <xsl:param name="latex.hyperparam">colorlinks,linkcolor=blue,urlcolor=blue,citecolor=blue,filecolor=blue,pdfstartview=FitH,bookmarksnumbered=true</xsl:param>
  <xsl:param name="doc.publisher.show">0</xsl:param>
  <xsl:param name="doc.lot.show"></xsl:param>
  <xsl:param name="doc.layout">coverpage toc frontmatter mainmatter index</xsl:param>
  <!--<xsl:param name="doc.layout">mainmatter</xsl:param>-->
  <xsl:param name="term.breakline">1</xsl:param>
  <xsl:param name="doc.collab.show">0</xsl:param>
  <xsl:param name="doc.section.depth">3</xsl:param>
  <!--do make no toc in slide-->
  <xsl:param name="doc.toc.show">0</xsl:param>
  <xsl:param name="table.in.float">0</xsl:param>
  <xsl:param name="monoseq.hyphenation">0</xsl:param>
  <xsl:param name="latex.output.revhistory">0</xsl:param>
  <xsl:param name="literal.layout.options">frame=single,rulecolor=\color{listingFrameColor}</xsl:param>
  <xsl:variable name="latex.begindocument">
    <xsl:text>
    \begin{document}
    \sloppy
    </xsl:text>
  </xsl:variable>

  <!--
    Override default literallayout template.
    See `./dblatex/dblatex-readme.txt`.
  -->

  <xsl:template match="address|literallayout[@class!='monospaced']">
    <xsl:text>\begin{alltt}</xsl:text>
    <xsl:text>&#10;\normalfont{}&#10;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#10;\end{alltt}</xsl:text>
  </xsl:template>

  <xsl:template match="processing-instruction('asciidoc-pagebreak')">
    <!-- force hard pagebreak, varies from 0(low) to 4(high) -->
    <xsl:text>\pagebreak[4] </xsl:text>
    <xsl:apply-templates />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="processing-instruction('asciidoc-br')">
    <xsl:text>\newline&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="processing-instruction('asciidoc-hr')">
    <!-- draw a 444 pt line (centered) -->
    <xsl:text>\begin{center}&#10; </xsl:text>
    <xsl:text>\line(1,0){444}&#10; </xsl:text>
    <xsl:text>\end{center}&#10; </xsl:text>
  </xsl:template>
  
<!--
DocBook XSL 1.75.2: Nav headers are invalid XHTML (table width element)
-->
<xsl:param name="suppress.navigation" select="1"/>

<!--
DocBook XSL 1.75.2 doesn't handle admonition icons
-->
<xsl:param name="admon.graphics" select="0"/>

<!--
DocBook XLS 1.75.2 doesn't handle TOCs
-->
<xsl:param name="generate.toc">
  <xsl:choose>
    <xsl:when test="/article">
/article  nop
    </xsl:when>
    <xsl:when test="/book">
/book  nop
    </xsl:when>
  </xsl:choose>
</xsl:param>



</xsl:stylesheet>

