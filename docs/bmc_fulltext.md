---
layout: card
title: "BMC Fulltext"
---

Search the fulltext content of BioMed Central articles for scholarly works.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>Lagotto Name</strong></td>
<td valign="top" width=70%>bmc_fulltext</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Lagotto Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Lagotto Core Attributes</strong></td>
<td valign="top" width=80%>&nbsp;</td>
</tr>
<td valign="top" width=20%><strong>Lagotto Other Attributes</strong></td>
<td valign="top" width=80%>&nbsp;</td>
</tr>
<tr>
<td valign="top" width=30%><strong>Protocol</strong></td>
<td valign="top" width=70%>REST</td>
</tr>
<tr>
<td valign="top" width=30%><strong>Format</strong></td>
<td valign="top" width=70%>JSON</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Rate-limiting</strong></td>
<td valign="top" width=80%>no</td>
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
<td valign="top" width=80%>http://www.biomedcentral.com/search/results?terms=URL&format=json</td>
</tr>
<tr>
<td valign="top" width=20%><strong>License</strong></td>
<td valign="top" width=80%>unknown</td>
</tr>
</tbody>
</table>

## Example Response

```json
{
  "entries": [
    {
      "arxId": "s13007-014-0041-7",
      "blurbTitle": "Mapping mutations from SNP data",
      "blurbText": "This article describes a software tool that can be used to map SNPs identified in high-throughput sequencing data from bulked segregant populations. The software maps SNPs present in annotated coding sequences, which may represent candidate causative mutations.",
      "imageUrl": "/content/figures/s13007-014-0041-7-toc.gif",
      "articleUrl": "/content/10/1/41",
      "articleFullUrl": "http://www.plantmethods.com/content/10/1/41",
      "type": "software",
      "doi": "10.1186/s13007-014-0041-7",
      "isOpenAccess": "true",
      "isFree": "true",
      "isHighlyAccessed": "false",
      "bibliograhyTitle": "<p>Mapping mutations in plant genomes with the user-friendly web application CandiSNP</p>",
      "authorNames": "        \n    <span class=\"author-names\">    Etherington GJ, Monaghan J, Zipfel C and MacLean D</span>\n    ",
      "longCitation": "<em>Plant Methods</em> 2014, <strong>10</strong>:41",
      "status": "LIVE",
      "abstractPath": "http://www.plantmethods.com/content/10/1/41/abstract",
      "journal Id": "10088",
      "published Date": "2014-12-30"
    }
  ]
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/bmc_fulltext.rb).
