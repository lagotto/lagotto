---
layout: card
title: "Mendeley"
---

[Mendeley](http://www.mendeley.com) is a reference manager and social bookmarking tool.

Mendeley uses OAuth2 authentification, we automatically obtain the access token using the **client_id** and **secret**.

## Required configuration fields

* **client_id** and **client_secret (secret)**: register your OAuth2 application at https://mix.mendeley.com/portal#/register

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>mendeley</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes<br/>(for groups only)</strong></td>
<td valign="top" width=80%>date (as date_added)<br/>contributor (as profile_id)</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>group_id</td>
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
<td valign="top" width=80%>150/hour</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Authentication</strong></td>
<td valign="top" width=80%>OAuth 2.0</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Restriction by IP Address</strong></td>
<td valign="top" width=80%>no</td>
</tr>
<tr>
<td valign="top" width=20%><strong>API URL</strong></td>
<td valign="top" width=80%>https://api.mendeley.com/catalog?doi=DOI&view=stats</td>
</tr>
</tbody>
</table>

## Example Response

```json
[
  {
    "id": "0f9144ee-87c1-3295-b317-dd32957ebaed",
    "title": "The \"island rule\" and deep-sea gastropods: Re-examining the evidence",
    "type": "journal",
    "authors": [
      {
        "first_name": "John J.",
        "last_name": "Welch"
      }
    ],
    "year": 2010,
    "source": "PLoS ONE",
    "identifiers": {
      "doi": "10.1371/journal.pone.0008776",
      "scopus": "2-s2.0-77649287097",
      "isbn": "1932-6203",
      "issn": "19326203",
      "pmid": "20098740"
    },
    "link": "http://www.mendeley.com/research/island-rule-deepsea-gastropods-reexamining-evidence",
    "reader_count": 34,
    "reader_count_by_academic_status": {
      "Professor": 2,
      "Associate Professor": 1,
      "Post Doc": 3,
      "Ph.D. Student": 8,
      "Researcher (at an Academic Institution)": 5,
      "Researcher (at a non-Academic Institution)": 2,
      "Student (Postgraduate)": 1,
      "Student (Master)": 6,
      "Student (Bachelor)": 5,
      "Doctoral Student": 1
    },
    "reader_count_by_subdiscipline": {
      "Environmental Sciences": {
        "Ecology": 3,
        "Miscellaneous": 1
      },
      "Earth Sciences": {
        "Miscellaneous": 1,
        "Paleontology": 1
      },
      "Biological Sciences": {
        "Zoology and Animal Science": 2,
        "Miscellaneous": 22,
        "Marine Biology": 3,
        "Ornithology": 1
      }
    },
    "reader_count_by_country": {
      "Portugal": 2,
      "United States": 3,
      "Mexico": 1,
      "Brazil": 2,
      "United Kingdom": 1
    },
    "group_count": 0,
    "abstract": "BACKGROUND: One of the most intriguing patterns in mammalian biogeography is the \"island rule\", which states that colonising species have a tendency to converge in body size, with larger species evolving decreased sizes and smaller species increased sizes. It has recently been suggested that an analogous pattern holds for the colonisation of the deep-sea benthos by marine Gastropoda. In particular, a pioneering study showed that gastropods from the Western Atlantic showed the same graded trend from dwarfism to gigantism that is evident in island endemic mammals. However, subsequent to the publication of the gastropod study, the standard tests of the island rule have been shown to yield false positives at a very high rate, leaving the result open to doubt. METHODOLOGY/PRINCIPAL FINDINGS: The evolution of gastropod body size in the deep sea is reexamined. Using an extended and updated data set, and improved statistical methods, it is shown that some results of the previous study may have been artifactual, but that its central conclusion is robust. It is further shown that the effect is not restricted to a single gastropod clade, that its strength increases markedly with depth, but that it applies even in the mesopelagic zone. CONCLUSIONS/SIGNIFICANCE: The replication of the island rule in a distant taxonomic group and a partially analogous ecological situation could help to uncover the causes of the patterns observed--which are currently much disputed. The gastropod pattern is evident at intermediate depths, and so cannot be attributed to the unique features of abyssal ecology."
  }
]
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/mendeley.rb).

## Further Documentation
* [Mendeley API Documentation](http://dev.mendeley.com/methods/)
* [Mendeley Open API Developers Google Group](https://groups.google.com/forum/?fromgroups#!forum/mendeley-open-api-developers)
