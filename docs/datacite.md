---
layout: card
title: "DataCite"
---

[DataCite](http://www.datacite.org) is a DOI registration agency for datasets.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>datacite</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>url (as DOI)<br/>contributor (as creator)</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>title<br/>publisher</td>
</tr>
<tr>
<td valign="top" width=30%><strong>Protocol</strong></td>
<td valign="top" width=70%>REST</td>
</tr>
<tr>
<td valign="top" width=30%><strong>Format</strong></td>
<td valign="top" width=70%>JSON or XML</td>
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
<td valign="top" width=80%>http://search.datacite.org/api?q=relatedIdentifier:DOI&fl=relatedIdentifier,doi,creator,title,publisher,publicationYear&fq=is_active:true&fq=has_metadata:true&indent=true</td>
</tr>
</tbody>
</table>

## Example Response

```json
{
  "responseHeader": {
    "status": 0,
    "QTime": 2
  },
  "response": {
    "numFound": 1,
    "start": 0,
    "docs": [
      {
        "doi": "10.5061/DRYAD.8515",
        "relatedIdentifier": [
          "HasPart:DOI:10.5061/DRYAD.8515/1",
          "HasPart:DOI:10.5061/DRYAD.8515/2",
          "IsReferencedBy:DOI:10.1371/JOURNAL.PPAT.1000446",
          "IsReferencedBy:DOI:"
        ],
        "creator": [
          "Ollomo, Benjamin",
          "Durand, Patrick",
          "Prugnolle, Franck",
          "Douzery, Emmanuel J. P.",
          "Arnathau, Céline",
          "Nkoghe, Dieudonné",
          "Leroy, Eric",
          "Renaud, François"
        ],
        "publisher": "Dryad Digital Repository",
        "title": [
          "Data from: A new malaria agent in African hominids."
        ],
        "publicationYear": "2011"
      }
    ]
  }
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/datacite.rb).

## Further Documentation
* [DataCite Metadata Search](http://search.datacite.org/help.html)
