---
layout: card
title: "ADS"
---

Search the Astrophysics Data System (ADS) for ArXiV preprints associated with a DOI.

## Required configuration fields

* **access_token**: can be obtained by creating an account [here](http://hourly.adslabs.org/).

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>ads</td>
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
<td valign="top" width=80%>yes</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Authentication</strong></td>
<td valign="top" width=80%>yes</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Restriction by IP Address</strong></td>
<td valign="top" width=80%>no</td>
</tr>
<tr>
<td valign="top" width=20%><strong>API URL</strong></td>
<td valign="top" width=80%>http://adsws-staging.elasticbeanstalk.com/v1/search/query?fl=title%2Cauthor%2Ccitation%2Cpubdate%2Cdoi%2Cidentifier&q=doi%3ADOI&access_token=ACCESS_TOKEN&rows=100&start=0</td>
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
  "responseHeader": {
    "status": 0,
    "QTime": 62,
    "params": {
      "fl": "title,author,citation,pubdate,doi,identifier",
      "sort": "date desc",
      "start": "0",
      "q": "doi:10.1371/journal.pone.0118494",
      "wt": "json",
      "access_token": "12345",
      "rows": "100"
    }
  },
  "response": {
    "numFound": 1,
    "start": 0,
    "docs": [
      {
        "identifier": [
          "2015arXiv150304201V",
          "10.1371/journal.pone.0118494",
          "1503.04201",
          "2015arXiv150304201V",
          "10.1371/journal.pone.0118494",
          "2015PLoSO..1018494V"
        ],
        "pubdate": "2015-03-00",
        "doi": [
          "10.1371/journal.pone.0118494"
        ],
        "author": [
          "von Hippel, Ted",
          "von Hippel, Courtney"
        ],
        "title": [
          "To Apply or Not to Apply: A Survey Analysis of Grant Writing Costs and Benefits"
        ]
      }
    ]
  }
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/ads.rb).
