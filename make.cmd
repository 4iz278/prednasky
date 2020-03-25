@echo off
call saxon9 -o:%1.html -s:%1.xml -xsl:reveal.xsl
mkdir e:\proj\kosek.cz\vyuka\4iz278\prednasky\%1
call saxon9 -o:e:\proj\kosek.cz\vyuka\4iz278\prednasky\%1\index.html -s:%1.xml -xsl:reveal-export.xsl
