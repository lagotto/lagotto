---
layout: card
title: "ADS Fulltext"
---

Search the fulltext content of the Astrophysics Data System (ADS) for scholarly works.

## Required configuration fields

* **access_token**: can be obtained by creating an account [here](http://hourly.adslabs.org/).

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>ads_fulltext</td>
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
<td valign="top" width=80%>http://adsws-staging.elasticbeanstalk.com/v1/search/query?fl=title%2Cauthor%2Ccitation%2Cpubdate%2Cdoi%2Cidentifier&q=body%3ADOI&access_token=ACCESS_TOKEN&rows=100&start=0</td>
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
    "QTime": 988,
    "params": {
      "fl": "title,author,citation,pubdate,doi,identifier",
      "sort": "date desc",
      "start": "0",
      "q": "body:10.1371/journal.pmed.0020124",
      "wt": "json",
      "access_token": "12345",
      "rows": "100"
    }
  },
  "response": {
    "numFound": 3,
    "start": 0,
    "docs": [
      {
        "identifier": [
          "arXiv:1311.3611",
          "2013arXiv1311.3611W"
        ],
        "pubdate": "2013-11-00",
        "author": [
          "Wenmackers, Sylvia",
          "Vanpoucke, Danny E. P."
        ],
        "title": [
          "Models and Simulations in Material Science: Two Cases Without Error Bars"
        ]
      },
      {
        "identifier": [
          "arXiv:1306.1059",
          "2013arXiv1306.1059B"
        ],
        "pubdate": "2013-06-00",
        "author": [
          "Berk, Richard",
          "Brown, Lawrence",
          "Buja, Andreas",
          "Zhang, Kai",
          "Zhao, Linda"
        ],
        "title": [
          "Valid post-selection inference"
        ]
      },
      {
        "identifier": [
          "arXiv:1007.2876",
          "2010arXiv1007.2876L"
        ],
        "pubdate": "2010-07-00",
        "citation": [
          "2010arXiv1004.4704R",
          "2011arXiv1109.5235C",
          "2012arXiv1207.6839F"
        ],
        "author": [
          "Lyons, Russell"
        ],
        "title": [
          "The Spread of Evidence-Poor Medicine via Flawed Social-Network Analysis"
        ]
      }
    ]
  }
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/ads_fulltext.rb).
