---
layout: page
title: "API"
---

Version 3 of the API was released October 30, 2012 (ALM 2.3).
Version 4 of the API (write/update/delete for admin users) was released January 22, 2014 (ALM 2.11). It extends v3.
Version 5 of the API (simplify, drop xml, queries) was released April 24, 2014 (ALM 2.14).

## Base URL
API calls to the version 3 APIs start with ``/api/v3/articles`` and
API calls to the version 4 APIs start with ``/api/v4/articles``.

## Supported Media Types
* JSON

The media type is set in the header, e.g. "Accept: application/json". Media type negotiation via file extension (e.g. ".json") is not supported. The API defaults to JSON if no media type is given, e.g. to test the API with a browser. Support for XML has been depreciated.

## API Key
All v3 API calls require an API key, use the format `?api_key=API_KEY`. A key can be obtained by registering as API user with the ALM application and this shouldn't take more than a few minutes. By default the ALM application uses [Mozilla Persona](http://www.mozilla.org/en-US/persona/), but it can also be configured to use other services usch as OAuth and CAS. For the PLOS ALM application you need to sign in with your [PLOS account](http://register.plos.org/ambra-registration/register.action).

The v4 API uses a username/password pair and HTTP Basic authentication for article create, update, and delete. You can GET article information from the v4 endpoint using an API key as for API v3.

## Query for one or several Articles
Specify one or more articles by a comma-separated list of DOIs in the `ids` parameter. These DOIs have to be URL-escaped, e.g. `%2F` for `/`:

```sh
/api/v3/articles?api_key=API_KEY&ids=10.1371%2Fjournal.pone.0036240
/api/v3/articles?api_key=API_KEY&ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413
```

Queries for up to 50 articles at a time are supported.

## Additional Parameters

### type=doi|pmid|pmcid|mendeley
The version 3 API supports queries for DOI, PubMed ID, PubMed Central ID and Mendeley UUID. The default `doi` is used if no type is given in the query. The following queries are all for the same article:

```sh
/api/v3/articles?api_key=API_KEY&ids=10.1371%2Fjournal.pmed.1001361
/api/v3/articles?api_key=API_KEY&ids=23300388&type=pmid
/api/v3/articles?api_key=API_KEY&ids=PMC3531501&type=pmcid
/api/v3/articles?api_key=API_KEY&ids=437b07d9-bc40-4c57-b60e-1f60fefe2300&type=mendeley
```

### info=summary|detail
With the **summary** parameter no source information or metrics are provided, only article metadata such as DOI, PubMed ID, title or publication date. The only exception are summary statistics, aggregating metrics from several sources (views, shares, bookmarks and citations).

With the **detail** parameter all raw data sent by the source are provided. This also includes metrics by day, month and year.

```sh
/api/v3/articles?api_key=API_KEY&ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&info=detail
```

### source=x
Only provide metrics for a given source, or a list of sources. The response format is the same as the default response.

```sh
/api/v3/articles?api_key=API_KEY&ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&source=mendeley,crossref
```

## Metrics
The metrics for every source are returned as total number, and separated in categories, e.g. `html` and `pdf` views for usage data, `shares` and `groups` for Mendeley, or `shares`, `likes` and `comments` for Facebook. The same seven categories are always returned for every source to simplify parsing of API responses:

* **CiteULike**: shares

* **Mendeley**: shares, groups

* **Twitter**: comments

* **Facebook**: shares, likes, comments

* **Reddit**: likes, comments

* **CrossRef, PubMed, Nature Blogs, ResearchBlogging, ScienceSeeker, Wordpress.com, Wikipedia, PMC Europe Citations, PMC Europe Database Citations, Scopus**: citations

* **Counter, PubMed Central**: html, pdf

## Search
Search is not supported by the v3 API, users have to provide specific identifiers or retrieve batches of 50 documents
sorted by descending date or event count.

## Signposts
Several metrics are aggregated and available in all API queries:

* Viewed: counter + pmc (PLOS only)
* Discussed: facebook (+ twitter at PLOS)
* Saved: mendeley + citeulike
* Cited: crossref (scopus at PLOS)

## Date and Time Format
All dates and times are in ISO 8601, e.g. ``2003-10-13T07:00:00Z``

## Null
The API returns `null` if no query was made, and `0` if the external API returns 0 events.

## Example Response
### JSON

```json
[
  {
    "doi": "10.1371/journal.pone.0036240",
    "title": "How Academic Biologists and Physicists View Science Outreach",
    "url": "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0036240",
    "mendeley": "88bfe7f0-9cb4-11e1-ac31-0024e8453de6",
    "pmid": "22590526",
    "pmcid": "3348938",
    "publication_date": "2012-05-09T07:00:00Z",
    "update_date": "2013-05-17T13:33:36Z",
    "views": 12987,
    "shares": 276,
    "bookmarks": 38,
    "citations": 3,
    "sources": [
      {
        "name": "bloglines",
        "display_name": "Bloglines",
        "events_url": null,
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": null,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": 0,
          "total": 0
        },
        "update_date": "2009-03-12T00:29:00Z"
      },
      {
        "name": "citeulike",
        "display_name": "CiteULike",
        "events_url": "http://www.citeulike.org/doi/10.1371/journal.pone.0036240",
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": 5,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": null,
          "total": 5
        },
        "update_date": "2013-05-12T21:20:14Z"
      },
      {
        "name": "connotea",
        "display_name": "Connotea",
        "events_url": null,
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": null,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": 0,
          "total": 0
        },
        "update_date": "2009-03-12T00:29:20Z"
      },
      {
        "name": "crossref",
        "display_name": "CrossRef",
        "events_url": null,
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": null,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": 3,
          "total": 3
        },
        "update_date": "2013-05-10T03:17:07Z"
      },
      {
        "name": "nature",
        "display_name": "Nature",
        "events_url": null,
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": null,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": 1,
          "total": 1
        },
        "update_date": "2013-05-15T16:04:54Z"
      },
      {
        "name": "postgenomic",
        "display_name": "Postgenomic",
        "events_url": null,
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": null,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": 0,
          "total": 0
        },
        "update_date": "2009-03-12T00:30:06Z"
      },
      {
        "name": "pubmed",
        "display_name": "PubMed Central",
        "events_url": "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=22590526",
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": null,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": 1,
          "total": 1
        },
        "update_date": "2013-05-10T16:55:43Z"
      },
      {
        "name": "scopus",
        "display_name": "Scopus",
        "events_url": null,
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": null,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": 0,
          "total": 0
        },
        "update_date": "2013-02-01T09:44:57Z"
      },
      {
        "name": "counter",
        "display_name": "Counter",
        "events_url": "http://www.plosreports.org/services/rest?method=usage.stats&doi=10.1371%2Fjournal.pone.0036240",
        "metrics": {
          "pdf": 814,
          "html": 12036,
          "shares": null,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": null,
          "total": 12886
        },
        "update_date": "2013-05-17T13:33:36Z"
      },
      {
        "name": "researchblogging",
        "display_name": "Research Blogging",
        "events_url": null,
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": null,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": 0,
          "total": 0
        },
        "update_date": "2013-05-17T07:59:35Z"
      },
      {
        "name": "biod",
        "display_name": "Biod",
        "events_url": null,
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": null,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": null,
          "total": 0
        },
        "update_date": "2013-05-17T12:52:04Z"
      },
      {
        "name": "wos",
        "display_name": "Web of Science®",
        "events_url": "http://gateway.webofknowledge.com/gateway/Gateway.cgi?GWVersion=2&SrcApp=PARTNER_APP&SrcAuth=PLoSCEL&KeyUT=000305336100022&DestLinkType=CitingArticles&DestApp=WOS_CPL&UsrCustomerID=c642dd6a62e245b029e19b27ca7f6b1c",
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": null,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": 1,
          "total": 1
        },
        "update_date": "2013-05-16T06:13:38Z"
      },
      {
        "name": "pmc",
        "display_name": "PubMed Central Usage Stats",
        "events_url": null,
        "metrics": {
          "pdf": 19,
          "html": 82,
          "shares": null,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": null,
          "total": 101
        },
        "update_date": "2013-05-17T02:06:31Z"
      },
      {
        "name": "facebook",
        "display_name": "Facebook",
        "events_url": null,
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": 58,
          "groups": null,
          "comments": 54,
          "likes": 47,
          "citations": null,
          "total": 159
        },
        "update_date": "2013-05-16T04:09:20Z"
      },
      {
        "name": "mendeley",
        "display_name": "Mendeley",
        "events_url": "http://api.mendeley.com/research/academic-biologists-physicists-view-science-outreach-1/",
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": 33,
          "groups": 0,
          "comments": null,
          "likes": null,
          "citations": null,
          "total": 33
        },
        "update_date": "2013-05-03T12:13:26Z"
      },
      {
        "name": "twitter",
        "display_name": "Twitter",
        "events_url": null,
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": null,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": 117,
          "total": 117
        },
        "update_date": "2013-05-10T19:21:40Z"
      },
      {
        "name": "wikipedia",
        "display_name": "Wikipedia",
        "events_url": null,
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": null,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": 0,
          "total": 0
        },
        "update_date": "2013-05-05T13:18:29Z"
      },
      {
        "name": "scienceseeker",
        "display_name": "ScienceSeeker",
        "events_url": null,
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": null,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": 0,
          "total": 0
        },
        "update_date": "2013-05-12T14:19:53Z"
      },
      {
        "name": "relativemetric",
        "display_name": "Relative Metric",
        "events_url": null,
        "metrics": {
          "pdf": null,
          "html": null,
          "shares": null,
          "groups": null,
          "comments": null,
          "likes": null,
          "citations": null,
          "total": 14031
        },
        "update_date": "2013-05-03T04:06:33Z"
      }
    ]
  }
]
```

## v4 API
The v4 API is only available to users with admin prileges and uses basic authentication with username and password instead of an API key. The API supports the following REST actions:

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<th valign="top" width=30%>HTTP Verb</td>
<th valign="top" width=40%>Path</td>
<th valign="top" width=30%>Action</td>
</tr>
<tr>
<td valign="top" width=30%>GET</td>
<td valign="top" width=40%>/api/v4/articles</td>
<td valign="top" width=30%>index</td>
</tr>
<tr>
<td valign="top" width=30%>POST</td>
<td valign="top" width=40%>/api/v4/articles</td>
<td valign="top" width=30%>create</td>
</tr>
<tr>
<td valign="top" width=30%>GET</td>
<td valign="top" width=40%>/api/v4/articles/info:doi/DOI</td>
<td valign="top" width=30%>show</td>
</tr>
<tr>
<td valign="top" width=30%>PUT</td>
<td valign="top" width=40%>/api/v4/articles/info:doi/DOI</td>
<td valign="top" width=30%>update</td>
</tr>
<tr>
<td valign="top" width=30%>DELETE</td>
<td valign="top" width=40%>/api/v4/articles/info:doi/DOI</td>
<td valign="top" width=30%>delete</td>
</tr>
</tbody>
</table>

The API response to get a list of articles or a single article is the same as for the v3 API. You can also use one of the other supported identifiers (pmid or pmcid) instead of the DOI.

### Create article
A sample curl API call to create a new article would look like this:

```sh
curl -X POST -H "Content-Type: application/json" -u USERNAME:PASSWORD -d '{"article":{"doi":"10.1371/journal.pone.0036790","year":2012,"month":5,"day":15,"title":"Test title"}}' http://HOST/api/v4/articles
```

When an article has been created successfully, the server reponds with `Status 201 Created` and the following JSON (the `data` object will include all article attributes):

```sh
{"success":"Article created.","error":null,"data":{ ... }
```

### Update article
A sample curl API call to update an article would look like this:

```sh
curl -X POST -H "Content-Type: application/json" -u USERNAME:PASSWORD -d '{"article":{"pmid":"22615813"}}' http://HOST/api/v4/articles/info:doi/10.1371/journal.pone.0036790
```

When an article has been updated successfully, the server reponds with `Status 200 Ok` and the following JSON (the `data` object will include all article attributes):

```sh
{"success":"Article updated.","error":null,"data":{ ... }
```

### Delete article
A sample curl API call to delete an article would look like this:

```sh
curl -X POST -H "Content-Type: application/json" -u USERNAME:PASSWORD -d '{"article":{"pmid":"22615813"}}' http://HOST/api/v4/articles/info:doi/10.1371/journal.pone.0036790
```

When an article has been deleted successfully, the server reponds with `Status 200 Ok` and the following JSON (the `data` object will include all article attributes):

```sh
{"success":"Article deleted.","error":null,"data":{ ... }
```
