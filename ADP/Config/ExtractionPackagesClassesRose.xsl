<?xml version="1.0" encoding="ISO8859-1"?>
<xsl:stylesheet	version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>

<xsl:template match="uses">
	<HTML>
		<BODY>
			<TABLE Border="0" Width="100%">
				<TR>
					<TD Align="Center" Width="100%">
						<I><H3><xsl:value-of select="@qualifiedname"/></H3></I>
					</TD>
				</TR>
			</TABLE><TABLE Border="0" Width="100%">
				<TR>
					<TD>
						<xsl:apply-templates>
						<xsl:sort data-type="text" select="@name"/>
						</xsl:apply-templates>
						<HR/>
					</TD>
				</TR>
			</TABLE>
		</BODY>
	</HTML>
</xsl:template>

<xsl:template match="uses/class">
	<HR/>
	<TABLE Border="0" Width="100%">
		<TR>
			<TD Width="20%">Classe :</TD>
			<TD Width="80%"><B><xsl:value-of select="@name"/></B></TD>
		</TR>
		<xsl:apply-templates/>
	</TABLE>
</xsl:template>

<xsl:template match="uses/class/package">
	<TR>
		<TD Width="20%">Package :</TD>
		<TD Width="80%"><xsl:value-of select="@name"/></TD>
	</TR>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="uses/class/superclass">
	<TR>
		<TD Width="20%">Classe mère :</TD>
		<TD Width="80%"><xsl:value-of select="@name"/></TD>
	</TR>
</xsl:template>

<xsl:template match="uses/class/realizes">
	<TR>
		<TD Width="20%">Interfaces :</TD>
		<TD Width="80%"/>
	</TR>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="uses/class/realizes/interface">
	<TR>
		<TD Width="20%"/>
		<TD Width="80%"><xsl:value-of select="@name"/></TD>
	</TR>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="uses/class/attributes">
	<TR>
		<TD Width="20%">Attributs :</TD>
		<TD Width="80%"/>
	</TR>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="uses/class/attributes/class">
	<TR>
		<TD Width="20%"/>
		<TD Width="80%"><xsl:value-of select="@name"/></TD>
	</TR>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="uses/class/associations">
	<TR>
		<TD Width="20%">Associations :</TD>
		<TD Width="80%"/>
	</TR>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="uses/class/associations/class">
	<TR>
		<TD Align="Right" Width="20%">
			<xsl:if test="@type">
			<I>(<xsl:value-of select="@type"/>)</I>
			</xsl:if>
		</TD>
		<TD Width="80%"><xsl:value-of select="@name"/></TD>
	</TR>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="uses/class/parameters">
	<TR>
		<TD Width="20%">Paramètres :</TD>
		<TD Width="80%"/>
	</TR>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="uses/class/parameters/class">
	<TR>
		<TD Width="20%"/>
		<TD Width="80%"><xsl:value-of select="@name"/></TD>
	</TR>
	<xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
