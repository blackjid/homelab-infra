<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>
  <xsl:template match="node()|@*">
     <xsl:copy>
       <xsl:apply-templates select="node()|@*"/>
     </xsl:copy>
  </xsl:template>

  <xsl:template match="/domain/devices">
  <xsl:copy>
  <xsl:apply-templates select="node()|@*"/>
    <xsl:element name="hostdev">
      <xsl:attribute name="mode">subsystem</xsl:attribute>
      <xsl:attribute name="type">mdev</xsl:attribute>
      <xsl:attribute name="managed">yes</xsl:attribute>
      <xsl:attribute name="model">vfio-pci</xsl:attribute>
      <xsl:attribute name="display">off</xsl:attribute>
      <xsl:element name="source">
        <xsl:element name="address">
          <xsl:attribute name="uuid">${gpu_guid}</xsl:attribute>
        </xsl:element>
      </xsl:element>
      <xsl:element name="address">
        <xsl:attribute name="type">pci</xsl:attribute>
        <xsl:attribute name="domain">0x0000</xsl:attribute>
        <xsl:attribute name="bus">0x00</xsl:attribute>
        <xsl:attribute name="slot">0x09</xsl:attribute>
        <xsl:attribute name="function">0x0</xsl:attribute>
      </xsl:element>
    </xsl:element>
  </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
