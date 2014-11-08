---
layout: card
title: "PubMed Central"
---

[PubMed Central](http://www.ncbi.nlm.nih.gov/pmc/) is a free full-text archive of biomedical and life sciences journal literature at the U.S. National Institutes of Health's National Library of Medicine. PubMed Central provides information about citing articles in PubMed.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=20%><strong>ALM Name</strong></td>
<td valign="top" width=80%>pubmed</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>id (as pmcid)<br/>url as (http://www.ncbi.nlm.nih.gov/pmc/articles/PMCID)</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>none</td>
</tr>
<tr>
<td valign="top" width=30%><strong>Protocol</strong></td>
<td valign="top" width=70%>REST</td>
</tr>
<tr>
<td valign="top" width=30%><strong>Format</strong></td>
<td valign="top" width=70%>XML</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Rate-limiting</strong></td>
<td valign="top" width=80%>unknown</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Authentication</strong></td>
<td valign="top" width=80%>no</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Restriction by IP Address</strong></td>
<td valign="top" width=80%>no</td>
</tr>
<tr>
<td valign="top" width=20%><strong>API URL</strong></td>
<td valign="top" width=80%>http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=PMID</td>
</tr>
</tbody>
</table>

## Example

```xml
<PubMedToPMCcitingformSET>
	<REFORM>
		<PMID>19562078</PMID>
		<PMCID>2768794</PMCID>
		<PMCID>2855371</PMCID>
		<PMCID>2931710</PMCID>
		<PMCID>2956678</PMCID>
		<PMCID>3059854</PMCID>
		<PMCID>3162524</PMCID>
		<PMCID>3214728</PMCID>
		<PMCID>3328792</PMCID>
		<PMCID>3335864</PMCID>
		<PMCID>3357800</PMCID>
	</REFORM>
</PubMedToPMCcitingformSET>
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/pub_med.rb).

## API Documentation
* [PubMed Central citation data](http://www.pubmedcentral.nih.gov/utils/)
* [Entrez to PMC Citing - parse for total citations](http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi)
* Ned to convert an article DOI into a PubMed ID
* Include number of citations and a [link back to PMC](http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=1751066)
