---
layout: card
title: "Copernicus"
---

This source is providing usage stats from the Open Access publisher [Copernicus Publications](http://www.copernicus.org).

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>copernicus</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>&nbsp;</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
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
<td valign="top" width=80%>not known</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Authentication</strong></td>
<td valign="top" width=80%>Basic Authentication</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Restriction by IP Address</strong></td>
<td valign="top" width=80%>no</td>
</tr>
<tr>
<td valign="top" width=20%><strong>API URL</strong></td>
<td valign="top" width=80%>&nbsp;</td>
</tr>
</tbody>
</table>

## Example Response

```json
{
   "doi": "doi:10.5194/ms-2-175-2011",
   "journalId": "449",
   "articleId": "28",
   "title": "Robust design ...",
   "volumeNumber": "2",
   "firstPage": "175",
   "msNumber": "ms-2011-14",
   "msId": "10760",
   "counter": {
       "PdfDownloads": "5",
       "AbstractViews": "60",
       "BibtexDownloads": "0",
       "RisDownloads": "0",
       "XmlDownloads": "0"
   }
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/copernicus.rb).

## Further information
* [Copernicus Publications website](http://publications.copernicus.org)
