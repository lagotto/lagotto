---
layout: card
title: Scopus
---

[Scopus](http://www.scopus.com) is an abstract and citation database of peer-reviewed literature. Information about access to the Scopus API can be found [here](http://www.developers.elsevier.com/cms/restful-api-authentication-new).

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>scopus</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>id (as doi)<br/>url (as http://dx.doi.org/DOI)<br/>contributor(s)</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>ISSN<br/>journal title<br/>journal abbreviation<br/>title<br/>volume<br/>issue<br/>first page<br/>year<br/>publication type<br/>citation count<br/>Scopus ID</td>
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
<td valign="top" width=80%>API key and institutional token</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Restriction by IP Address</strong></td>
<td valign="top" width=80%>no</td>
</tr>
<tr>
<td valign="top" width=20%><strong>API URL Cited-By</strong></td>
<td valign="top" width=80%>https://api.elsevier.com/content/search/index:SCOPUS?query=DOI(DOI)</td>
</tr>
</tbody>
</table>

## Example Response

```json
{
  "search-results": {
    "opensearch:totalResults": "1",
    "opensearch:startIndex": "0",
    "opensearch:itemsPerPage": "1",
    "opensearch:Query": {
      "@role": "request",
      "@searchTerms": "DOI%2810.1371%2Fjournal.pmed.0030442%29",
      "@startPage": "0"
    },
    "link": [
      {
        "@_fa": "true",
        "@ref": "self",
        "@href": "http://api.elsevier.com:80/content/search/index:scopus?start=0&count=25&query=DOI(10.1371/journal.pmed.0030442)",
        "@type": "application/json"
      },
      {
        "@_fa": "true",
        "@ref": "first",
        "@href": "http://api.elsevier.com:80/content/search/index:scopus?start=0&count=25&query=DOI(10.1371/journal.pmed.0030442)",
        "@type": "application/json"
      }
    ],
    "entry": [
      {
        "@_fa": "true",
        "link": [
          {
            "@_fa": "true",
            "@ref": "self",
            "@href": "http://api.elsevier.com/content/abstract/scopus_id:33845338724"
          },
          {
            "@_fa": "true",
            "@ref": "scopus",
            "@href": "http://www.scopus.com/inward/record.url?partnerID=HzOxMe3b&scp=33845338724"
          },
          {
            "@_fa": "true",
            "@ref": "scopus-citedby",
            "@href": "http://www.scopus.com/inward/citedby.url?partnerID=HzOxMe3b&scp=33845338724"
          }
        ],
        "prism:url": "http://api.elsevier.com/content/abstract/scopus_id:33845338724",
        "dc:identifier": "SCOPUS_ID:33845338724",
        "eid": "2-s2.0-33845338724",
        "dc:title": "Projections of global mortality and burden of disease from 2002 to 2030",
        "dc:creator": "Mathers, C.D.",
        "prism:publicationName": "PLoS Medicine",
        "prism:issn": "15491277",
        "prism:eIssn": "15491676",
        "prism:volume": "3",
        "prism:issueIdentifier": "11",
        "prism:pageRange": "2011-2030",
        "prism:coverDate": "2006-11-01",
        "prism:coverDisplayDate": "November 2006",
        "prism:doi": "10.1371/journal.pmed.0030442",
        "citedby-count": "1814",
        "affiliation": [
          {
            "@_fa": "true",
            "affilname": "Organisation Mondiale de la Santé",
            "affiliation-city": "Geneve",
            "affiliation-country": "Switzerland"
          }
        ],
        "pubmed-id": "17132052",
        "prism:aggregationType": "Journal",
        "subtype": "ar",
        "subtypeDescription": "Article"
      }
    ]
  }
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/scopus.rb).

## Further Documentation
* [Scopus Cited-by Linking](http://www.developers.elsevier.com/cms/scopus-citedby-retrieval)
* [Scopus API Authentication - Institutional Token](http://www.developers.elsevier.com/cms/restful-api-authentication-new#toc_RESTful_APIs_Authentication_-_Institutional_Token)
