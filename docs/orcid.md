---
layout: card
title: "ORCID"
---

ORCID is a persistent author identifier for connecting research and researchers.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>orcid</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>url</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>various</td>
</tr>
<tr>
<td valign="top" width=30%><strong>Protocol</strong></td>
<td valign="top" width=70%>REST</td>
</tr>
<tr>
<td valign="top" width=30%><strong>Format</strong></td>
<td valign="top" width=70%>JSON and XML</td>
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
<td valign="top" width=80%>http://pub.orcid.org/v1.1/search/orcid-bio/?q=digital-object-ids:"DOI"</td>
</tr>
<tr>
<td valign="top" width=20%><strong>License</strong></td>
<td valign="top" width=80%>CC0</td>
</tr>
</tbody>
</table>

## Example Response

```json
{
  "message-version": "1.1",
  "orcid-search-results": {
    "orcid-search-result": [
      {
        "relevancy-score": {
          "value": 0.7290998
        },
        "orcid-profile": {
          "orcid": null,
          "orcid-identifier": {
            "value": null,
            "uri": "http://orcid.org/0000-0002-0159-2197",
            "path": "0000-0002-0159-2197",
            "host": "orcid.org"
          },
          "orcid-bio": {
            "personal-details": {
              "given-names": {
                "value": "Jonathan A."
              },
              "family-name": {
                "value": "Eisen"
              }
            },
            "biography": {
              "value": "",
              "visibility": null
            },
            "researcher-urls": {
              "researcher-url": [
                {
                  "url-name": {
                    "value": "microBEnet"
                  },
                  "url": {
                    "value": "http://microBE.net"
                  }
                },
                {
                  "url-name": {
                    "value": "Tree of Life Blog"
                  },
                  "url": {
                    "value": "http://phylogenomics.blogspot.com"
                  }
                },
                {
                  "url-name": {
                    "value": "Lab Page"
                  },
                  "url": {
                    "value": "http://phylogenomics.wordpress.com"
                  }
                },
                {
                  "url-name": {
                    "value": "Twitter"
                  },
                  "url": {
                    "value": "http://twitter.com/phylogenomics"
                  }
                }
              ],
              "visibility": null
            },
            "keywords": {
              "keyword": [
                {
                  "value": "evolution, genomics, microbiology, ecology, microbial diversity, citizen science, "
                }
              ],
              "visibility": null
            },
            "external-identifiers": {
              "external-identifier": [
                {
                  "external-id-common-name": {
                    "value": "Scopus Author ID"
                  },
                  "external-id-reference": {
                    "value": "35247902700"
                  },
                  "external-id-url": {
                    "value": "http://www.scopus.com/inward/authorDetails.url?authorID=35247902700&partnerID=MN8TOARS"
                  },
                  "external-id-source": {
                    "value": null,
                    "uri": "http://orcid.org/0000-0002-5982-8983",
                    "path": "0000-0002-5982-8983",
                    "host": "orcid.org"
                  }
                }
              ],
              "visibility": null
            },
            "delegation": null,
            "applications": null,
            "scope": null
          },
          "type": null,
          "group-type": null,
          "client-type": null
        }
      }
    ],
    "num-found": 1
  }
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/orcid.rb).

## Further Documentation
* [Searching with the ORCID API](http://support.orcid.org/knowledgebase/articles/132354-searching-with-the-public-api)
