---
layout: card
title: "PLOS Fulltext"
---

Search the fulltext content of PLOS articles for scholarly works.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>plos_fulltext</td>
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
<td valign="top" width=80%>http://api.plos.org/search?q=everything:"DOI"+OR+everything:"URL"&fq=doc_type:full&fl=id,publication_date,title,cross_published_journal_name,author_display,article_type&wt=json&facet=false&rows=100&hl=false</td>
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
  "response": {
    "numFound": 1,
    "start": 0,
    "docs": [
      {
        "id": "10.1371/journal.pcbi.1003833",
        "cross_published_journal_name": [
          "PLOS Computational Biology",
          "PLOS Collections"
        ],
        "publication_date": "2014-09-11T00:00:00Z",
        "article_type": "Editorial",
        "author_display": [
          "Nicolas P. Rougier",
          "Michael Droettboom",
          "Philip E. Bourne"
        ],
        "title": "Ten Simple Rules for Better Figures"
      }
    ]
  }
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/plos_fulltext.rb).
