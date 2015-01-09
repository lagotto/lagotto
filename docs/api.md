---
layout: card_list
title: "API"
---

## Basic information

* Version 4 of the API (write/update/delete for admin users) was released January 22, 2014 (ALM 2.11).
* Version 5 of the API was released April 24, 2014 (ALM 2.14).
* Since the 3.10 release (December 18, 2014) Lagotto uses `works` instead of `articles` internally. The v4 and v5 API still use `articles` to not break existing integrations.

### Base URL
* API calls to the version 4 APIs start with `/api/v4/`
* API calls to the version 5 APIs start with `/api/v5/`

### Supported Media Types
* JSON

The media type is set in the header, e.g. "Accept: application/json", but defaults to this format anyway. Media type negotiation via file extension (e.g. ".json") is not supported. `JSONP` and `CORS` are supported.

### API Key
Almost all information regarding works (with the exception of sources that don't allow redistribution of data) is available without API keys since the Lagotto 3.12.7 release (January 9, 2015). An API key is required to add/update works, and to access some of the internal data of the application. A key can be obtained by registering as API user with the ALM application and this shouldn't take more than a few minutes. By default the ALM application uses [Mozilla Persona](http://www.mozilla.org/en-US/persona/), but it can also be configured to use other services usch as OAuth and CAS. For the PLOS ALM application you need to sign in with your [PLOS account](http://register.plos.org/ambra-registration/register.action).

For the v5 API the API key shoould be part of the URL in the format `?api_key=API_KEY`. The v4 API uses a username/password pair and HTTP Basic authentication. Only admin and staff users can use this API.

### Query for one or several works
Specify one or more works by a comma-separated list of DOIs in the `ids` parameter. These DOIs have to be URL-escaped, e.g. `%2F` for `/`:

```sh
/api/v5/articles?ids=10.1371%2Fjournal.pone.0036240
/api/v5/articles?ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413
```

Queries for up to 50 works at a time are supported.

### Metrics
The metrics for every source are returned as total number, and separated in categories, e.g. `html` and `pdf` views for usage data, `readers` for bookmarking services, and `likes` and `comments` for social media. The same 5 categories are always returned for every source to simplify parsing of API responses:

* **CiteULike**: readers

* **Mendeley**: readers

* **Twitter**: comments

* **Facebook**: likes, comments

* **Reddit**: likes, comments

* **Counter, PubMed Central**: html, pdf

### Search
Search is not supported by the API, users have to provide specific identifiers or retrieve batches of 50 documents, sorted by descending date or source event count.

### Signposts
Several metrics are aggregated and available in all API queries:

* Viewed: counter + pmc (PLOS only)
* Discussed: facebook (+ twitter at PLOS)
* Saved: mendeley + citeulike
* Cited: crossref (scopus at PLOS)

### Date and Time Format
All dates and times with the exception of publication dates are in ISO 8601 format, e.g. ``2003-10-13T07:00:00Z``. `date-parts` uses the Citeproc convention to allow incomplete dates (e.g. year only):

```json
"date-parts": [
    [
      2008,
      10,
      31
    ]
```
`date-parts` is a nested array of year, month, day, with only the year being required.

### Null
The API returns `null` if no query was made, and `0` if the external API returns 0 events.

## Additional Parameters

### type=doi|pmid|pmcid
The API supports queries for DOI, PubMed ID, PubMed Central ID, Scopus ID, Web of Science ID, and publisher URL. The default `doi` is used if no type is given in the query. The following queries are all for the same work:

```sh
/api/v5/articles?ids=10.1371%2Fjournal.pmed.1001361
/api/v5/articles?ids=23300388&type=pmid
/api/v5/articles?ids=PMC3531501&type=pmcid
/api/v5/articles?ids=84871667565&type=scp
/api/v5/articles?ids=000312934200011&type=wos
/api/v5/articles?ids=http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.1001361&type=url
```


### info=summary|detail
With the **summary** parameter no source information or metrics are provided, only work metadata such as DOI, other unique identifiers, URL, title or publication date. The only exception are summary statistics, aggregating metrics from several sources (views, shares, bookmarks and citations).

With the **detail** parameter all raw data sent by the source are provided. The **history** parameter has been depreciated with the ALM 3.0 release, you can use the `by day`, `by month` and `by year`response instead.

```sh
/api/v5/articles?ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&info=detail
```

### source_id=x
Only provide metrics for a given source, using the source name. Only one source name can be given. The response format is the same as the default response.

```sh
/api/v5/articles&ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&source_id=mendeley
```

### order=x

Results are sorted by descending event count when given the source name, e.g. `&order=wikipedia`. Otherwise (the default) results are sorted by date descending. When using `&source=x`, we can only sort by data or that source, not a different source.

### publisher_id=x
Only provide metrics for works by a given publisher, using the `publisher_id`. The response format is the same as the default response.

```sh
/api/v5/articles?publisher_id=340
```

### page|per_page

Results of the v5 API are paged with 50 results per page. Use `per_page` to pick a smaller number (1-50) of results per page, and use `page` to page through the results.

## Example Response

```json
{
  "total": 1,
  "total_pages": 1,
  "page": 1,
  "error": null,
  "data": [
    {
      "doi": "10.1371/journal.pcbi.1000204",
      "title": "Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web",
      "canonical_url": "http://www.ploscompbiol.org/article/info:doi/10.1371/journal.pcbi.1000204",
      "pmid": "18974831",
      "pmcid": "2568856",
      "scp": "55449101991",
      "wos": "000261480700019",
      "issued": {
        "date-parts": [
          [
            2008,
            10,
            31
          ]
        ]
      },
      "viewed": 80546,
      "saved": 2260,
      "discussed": 30,
      "cited": 51,
      "update_date": "2014-06-22T00:40:15Z",
      "sources": [
        {
          "name": "citeulike",
          "display_name": "CiteULike",
          "events_url": "http://www.citeulike.org/doi/10.1371%2Fjournal.pcbi.1000204",
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": 473,
            "comments": null,
            "likes": null,
            "total": 473
          },
          "update_date": "2014-06-20T09:25:36Z"
        },
        {
          "name": "crossref",
          "display_name": "CrossRef",
          "group_name": "cited",
          "events_url": null,
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": null,
            "comments": null,
            "likes": null,
            "total": 27
          },
          "by_day": [
          ],
          "by_month": [
            {
              "year": 2014,
              "month": 5,
              "total": 27
            },
            {
              "year": 2014,
              "month": 6,
              "total": 0
            }
          ],
          "by_year": [
            {
              "year": 2014,
              "total": 27
            }
          ],
          "update_date": "2014-06-22T00:40:15Z"
        },
        {
          "name": "nature",
          "display_name": "Nature",
          "events_url": null,
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": null,
            "comments": null,
            "likes": null,
            "total": 0
          },
          "update_date": "2014-06-01T20:17:33Z"
        },
        {
          "name": "pubmed",
          "display_name": "PubMed Central",
          "events_url": "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=18974831",
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": null,
            "comments": null,
            "likes": null,
            "total": 16
          },
          "update_date": "2014-06-18T08:01:51Z"
        },
        {
          "name": "scopus",
          "display_name": "Scopus",
          "events_url": "http://www.scopus.com/inward/citedby.url?partnerID=HzOxMe3b&scp=55449101991",
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": null,
            "comments": null,
            "likes": null,
            "total": 51
          },
          "update_date": "2014-06-01T15:02:52Z"
        },
        {
          "name": "counter",
          "display_name": "Counter",
          "events_url": null,
          "metrics": {
            "pdf": 7351,
            "html": 66069,
            "readers": null,
            "comments": null,
            "likes": null,
            "total": 73836
          },
          "update_date": "2014-06-21T12:04:49Z"
        },
        {
          "name": "researchblogging",
          "display_name": "Research Blogging",
          "events_url": "http://researchblogging.org/post-search/list?article=10.1371%2Fjournal.pcbi.1000204",
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": null,
            "comments": null,
            "likes": null,
            "total": 7
          },
          "update_date": "2014-05-06T14:07:07Z"
        },
        {
          "name": "pmc",
          "display_name": "PubMed Central Usage Stats",
          "events_url": "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2568856",
          "metrics": {
            "pdf": 1526,
            "html": 5184,
            "readers": null,
            "comments": null,
            "likes": null,
            "total": 6710
          },
          "update_date": "2014-06-09T13:38:43Z"
        },
        {
          "name": "facebook",
          "display_name": "Facebook",
          "events_url": null,
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": 17,
            "comments": 1,
            "likes": 0,
            "total": 18
          },
          "update_date": "2014-06-11T12:55:20Z"
        },
        {
          "name": "mendeley",
          "display_name": "Mendeley",
          "events_url": "http://www.mendeley.com/catalog/defrosting-digital-library-bibliographic-tools-next-generation-web/",
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": 1787,
            "comments": null,
            "likes": null,
            "total": 1787
          },
          "update_date": "2014-06-11T15:07:16Z"
        },
        {
          "name": "twitter",
          "display_name": "Twitter",
          "events_url": null,
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": null,
            "comments": 12,
            "likes": null,
            "total": 12
          },
          "update_date": "2014-06-17T13:21:56Z"
        },
        {
          "name": "wikipedia",
          "display_name": "Wikipedia",
          "events_url": "http://en.wikipedia.org/w/index.php?search=\"10.1371%2Fjournal.pcbi.1000204\"",
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": null,
            "comments": null,
            "likes": null,
            "total": 7
          },
          "update_date": "2014-06-17T21:21:05Z"
        },
        {
          "name": "scienceseeker",
          "display_name": "ScienceSeeker",
          "events_url": "http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=10.1371%2Fjournal.pcbi.1000204",
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": null,
            "comments": null,
            "likes": null,
            "total": 0
          },
          "update_date": "2014-06-03T13:32:39Z"
        },
        {
          "name": "f1000",
          "display_name": "F1000Prime",
          "events_url": null,
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": null,
            "comments": null,
            "likes": null,
            "total": 0
          },
          "update_date": "2014-04-15T08:06:14Z"
        },
        {
          "name": "figshare",
          "display_name": "Figshare",
          "events_url": null,
          "metrics": {
            "pdf": 0,
            "html": 3,
            "readers": null,
            "comments": null,
            "likes": 0,
            "total": 3
          },
          "update_date": "2014-06-20T05:03:53Z"
        },
        {
          "name": "pmceurope",
          "display_name": "PMC Europe Citations",
          "events_url": "http://europepmc.org/abstract/MED/18974831#fragment-related-citations",
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": null,
            "comments": null,
            "likes": null,
            "total": 17
          },
          "update_date": "2014-06-19T07:00:58Z"
        },
        {
          "name": "pmceuropedata",
          "display_name": "PMC Europe Database Citations",
          "events_url": "http://europepmc.org/abstract/MED/18974831#fragment-related-bioentities",
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": null,
            "comments": null,
            "likes": null,
            "total": 0
          },
          "update_date": "2014-05-31T05:00:14Z"
        },
        {
          "name": "wordpress",
          "display_name": "Wordpress.com",
          "events_url": "http://en.search.wordpress.com/?q=\"10.1371%2Fjournal.pcbi.1000204\"&t=post",
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": null,
            "comments": null,
            "likes": null,
            "total": 13
          },
          "update_date": "2014-06-20T06:37:38Z"
        },
        {
          "name": "reddit",
          "display_name": "Reddit",
          "events_url": "http://www.reddit.com/search?q=\"10.1371%2Fjournal.pcbi.1000204\"",
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": null,
            "comments": 0,
            "likes": 0,
            "total": 0
          },
          "update_date": "2014-06-19T02:10:13Z"
        },
        {
          "name": "datacite",
          "display_name": "DataCite",
          "events_url": "http://search.datacite.org/ui?q=relatedIdentifier:10.1371%2Fjournal.pcbi.1000204",
          "metrics": {
            "pdf": null,
            "html": null,
            "readers": null,
            "comments": null,
            "likes": null,
            "total": 0
          },
          "update_date": "2014-06-20T23:00:47Z"
        }
      ]
    }
  ]
}
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
<tr>
<td valign="top" width=30%>GET</td>
<td valign="top" width=40%>/api/v4/alerts</td>
<td valign="top" width=30%>index</td>
</tr>
</tbody>
</table>

The API response to get a list of works or a single work is the same as for the v5 API. You can also use one of the other supported identifiers instead of the DOI.

### Create work
A sample curl API call to create a new work would look like this:

```sh
curl -X POST -H "Content-Type: application/json" -u USERNAME:PASSWORD -d '{"article":{"doi":"10.1371/journal.pone.0036790","year":2012,"month":5,"day":15,"title":"Test title"}}' http://HOST/api/v4/articles
```

When a work has been created successfully, the server reponds with `Status 201 Created` and the following JSON (the `data` object will include all work attributes):

```sh
$ curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -u login:pwd -d '{"article":{"doi":"10.7554/eLife.09002","year":2013,"month":5,"day":21,"title":"Structure of a pore-blocking toxin in complex with a eukaryotic voltage-dependent K+ channel"}}' http://alm.example.org/api/v4/articles
HTTP/1.1 201 Created
Status: 201 Created
Content-Type: application/json; charset=utf-8

{"success":"Article created.","error":null,"data":{"doi":"10.7554/eLife.09002","title":"Structure of a pore-blocking toxin in complex with a eukaryotic voltage-dependent K+ channel","canonical_url":null,"mendeley_uuid":null,"pmid":null,"pmcid":null,"views":0,"shares":0,"bookmarks":0,"citations":0,"sources":[{"name":"pmc","display_name":"PubMed Central Usage Stats","events_url":null,"metrics":[]},{"name":"copernicus",
 ... more ...
```

When a work with the specified DOI already exists, the server returns HTTP 400 error with a JSON body indicating the work exists:

```sh
$ curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -u login:pwd -d '{"article":{"doi":"10.7554/eLife.09002","year":2013,"month":5,"day":21,"title":"Structure of a pore-blocking toxin in complex with a eukaryotic voltage-dependent K+ channel"}}' http://alm.example.org/api/v4/articles
HTTP/1.1 400 Bad Request
Status: 400 Bad Request
Content-Type: application/json; charset=utf-8

{"total":0,"total_pages":0,"page":0,"success":null,"error":{"doi":["has already been taken"]},
 "data":{"doi":"10.7554/eLife.99002","title":"Structure of a pore-blocking toxin in complex with a eukaryotic
 voltage-dependent K+ channel","canonical_url":null,"mendeley_uuid":null,"pmid":null,"pmcid":null,"views":0,
 "shares":0,"bookmarks":0,"citations":0,"sources":[]}}
```

In order to be accepted the following conditions must hold:

* The JSON must be valid, this means that string variables such as the DOI must be quoted in the request.
  The day, month and year are integers and can be left unquoted.

* The publication date can't be in the future (as understood by the server's date).

* The login details must be correct and at must be a local login, not a third-party login such as Persona.

* The login must have the 'Admin' role assigned.

* The DOI must not already exist in the database.


### Update work
A sample curl API call to update a work would look like this:

```sh
curl -X POST -H "Content-Type: application/json" -u USERNAME:PASSWORD -d '{"article":{"pmid":"22615813"}}' http://HOST/api/v4/articles/doi/10.1371/journal.pone.0036790
```

When a work has been updated successfully, the server reponds with `Status 200 Ok` and the following JSON (the `data` object will include all work attributes):

```sh
{"success":"Article updated.","error":null,"data":{ ... }
```

### Delete work
A sample curl API call to delete a work would look like this:

```sh
curl -X POST -H "Content-Type: application/json" -u USERNAME:PASSWORD -d '{"work":{"pmid":"22615813"}}' http://HOST/api/v4/articles/doi/10.1371/journal.pone.0036790
```

When a work has been deleted successfully, the server reponds with `Status 200 Ok` and the following JSON (the `data` object will include all work attributes):

```sh
{"success":"Article deleted.","error":null,"data":{ ... }
```

### Get alerts

The same query parameters as in the admin web interface are supported:

* source
* class_name
* level
* query (but using `q`)

By default the API returns all alerts, add `&unresolved=1` to only retrieve unresolved alerts, as in the admin web interface. An example API response would be:

```sh
{
  "total": 1,
  "total_pages": 1,
  "page": 1,
  "error": null,
  "data": [
    {
      "id": 228,
      "level": "ERROR",
      "class_name": "NoMethodError",
      "message": "undefined method `name' for nil:NilClass",
      "status": 422,
      "hostname": "example.org",
      "target_url": null,
      "source": null,
      "work": null,
      "unresolved": true,
      "create_date": "2014-08-19T20:23:05Z"
    }
  ]
}
```
