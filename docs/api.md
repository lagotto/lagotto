---
layout: card_list
title: "API"
---

## Basic Information

* a live version of the API (using [Swagger](http://swagger.io/)) is [here](/api)
* version 5 of the API was released April 24, 2014 (ALM 2.14).
* version 6 of the API was released April, 2015 (Lagotto 4.0).

### Base URL
* API calls start with `/api/`. API versioning is done via the request header, e.g. `Accept: application/vnd.lagotto+json; version=6`, and currently defaults to `version=6`.

### Supported Media Types
* application/vnd.lagotto+json

The default media type is JSON. The media type is set in the header, e.g. "Accept: application/vnd.lagotto+json", but defaults to this format anyway. Media type negotiation via file extension (e.g. ".json") is not supported. `JSONP` and `CORS` are supported.

### API Key
Almost all information regarding works (with the exception of sources that don't allow redistribution of data) is available without API keys since the Lagotto 3.12.7 release (January 9, 2015). An API key is required to add/update works, and to access some of the internal data of the application. A key can be obtained by registering as API user with the ALM application and this shouldn't take more than a few minutes. By default the ALM application uses [Mozilla Persona](http://www.mozilla.org/en-US/persona/), but it can also be configured to use other services usch as OAuth and CAS. For the PLOS ALM application you need to sign in with your [PLOS account](http://register.plos.org/ambra-registration/register.action).

For the v5 API the API key shoould be part of the URL in the format `?api_key=API_KEY`. The v6 API requires the API key in the header in the format `Authorization: Token token=API_KEY`.

### Meta
Every API response starts with a `meta` object that starts with basic information such as `message-type` and number of results (`total`).

```
"meta": {
  "status": "ok",
  "message-type": "work-list",
  "message-version": "6.0.0",
  "total": 1077,
  "total_pages": 2,
  "page": 1
}
```

### Query for one or several works
Specify one or more works by a comma-separated list of pids in the `ids` parameter. These DOIs have to be URL-escaped, e.g. `%2F` for `/`:

```sh
/api/v5/articles?ids=doi:10.1371%2Fjournal.pone.0036240
/api/v5/articles?ids=doi:10.1371%2Fjournal.pone.0036240,doi:10.1371%2Fjournal.pbio.0020413
```

Queries for up to 50 works at a time are supported. With many ids, in particular DOIs or URLs, the size limit of the query URL might be reached. It is therefore advisable to put the ids into the body of a POST, and include an `X-HTTP-Method-Override: GET` header:

```sh
curl -X POST -d "ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413" -H "Authorization: Token token=API_KEY" -H "X-HTTP-Method-Override: GET" "http://alm.plos.org/api/works"
```

### Events
The events for every source are returned as total number, and separated in categories, e.g. `html` and `pdf` views for usage data, `readers` for bookmarking services, and `likes` and `comments` for social media:

* **CiteULike**: readers

* **Mendeley**: readers

* **Twitter**: comments

* **Facebook**: likes, comments

* **Reddit**: likes, comments

* **Counter, PubMed Central**: html, pdf

Some events can only be obtained by substracting from `total`, e.g. `Counter` xml downloads: `total` - (`html` + `pdf`).

### Search
Search is not supported by the API, users have to provide specific identifiers or retrieve batches of 50 documents, sorted by descending date or source event count.

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

## Additional Parameters

### type=doi|pmid|pmcid|scp|wos|ark|url
The API supports queries for DOI, PubMed ID, PubMed Central ID, Scopus ID, Web of Science ID, ark, and publisher URL. The pid is used if no type is given in the query. The following queries are all for the same work:

```sh
/api/works?ids=doi:10.1371%2Fjournal.pmed.1001361
/api/works?ids=10.1371%2Fjournal.pmed.1001361&type=doi
/api/works?ids=23300388&type=pmid
/api/works?ids=PMC3531501&type=pmcid
/api/works?ids=84871667565&type=scp
/api/works?ids=000312934200011&type=wos
/api/works?ids=http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.1001361&type=url
```

### publisher_id=x
Only show works from a given publisher, using the publisher CrossRef ID. The response format is the same as the default response.

```sh
/api/works?publisher_id=340
```

### sort=x
Results are sorted by descending event count when given the source name, e.g. `&sort=wikipedia`. Otherwise (the default) results are sorted by descending publication date. When using `&source=x`, we can only sort by publication date or that source, not a different source.

### page|per_page

Results of the v6 API are paged with 1000 results per page. Use `per_page` to pick a smaller number (0-1000) of results per page, and use `page` to page through the results.

## Example Responses

#### /api/works/

```json
{
  "meta": {
    "status": "ok",
    "message-type": "work-list",
    "message-version": "6.0.0",
    "total": 1077,
    "total_pages": 2,
    "page": 1
  },
  "works": [
    {
      "id": "doi:10.1371/journal.pgen.1003182",
      "publisher_id": 340,
      "title": "Alternative Oxidase Expression in the Mouse Enables Bypassing Cytochrome <i>c</i> Oxidase Blockade and Limits Mitochondrial ROS Overproduction",
      "issued": {
        "date-parts": [
          [
            2013,
            1,
            3
          ]
        ]
      },
      "container-title": "PLOS Genetics",
      "volume": 9,
      "page": "e1003182",
      "issue": 1,
      "DOI": "10.1371/journal.pgen.1003182",
      "events": {
        "crossref": 16,
        "counter": 6702
      },
      "timestamp": "2015-04-16T06:14:07Z"
    },
    {
      "id": "doi:10.1371/journal.pgen.1003145",
      "publisher_id": 340,
      "title": "The Telomere Capping Complex CST Has an Unusual Stoichiometry, Makes Multipartite Interaction with G-Tails, and Unfolds Higher-Order G-Tail Structures",
      "issued": {
        "date-parts": [
          [
            2013,
            1,
            3
          ]
        ]
      },
      "container-title": "PLOS Genetics",
      "volume": 9,
      "page": "e1003145",
      "issue": 1,
      "DOI": "10.1371/journal.pgen.1003145",
      "events": {
        "crossref": 5,
        "counter": 5282
      },
      "timestamp": "2015-04-12T08:19:11Z"
    },
    {
      "id": "doi:10.1371/journal.pgen.1003147",
      "publisher_id": 340,
      "title": "A Genome-Wide Integrative Genomic Study Localizes Genetic Factors Influencing Antibodies against Epstein-Barr Virus Nuclear Antigen 1 (EBNA-1)",
      "issued": {
        "date-parts": [
          [
            2013,
            1,
            10
          ]
        ]
      },
      "container-title": "PLOS Genetics",
      "volume": 9,
      "page": "e1003147",
      "issue": 1,
      "DOI": "10.1371/journal.pgen.1003147",
      "PMID": "23326239",
      "PMCID": "3542101",
      "events": {
        "europe_pmc": 8,
        "crossref": 9,
        "counter": 6355
      },
      "timestamp": "2015-04-12T08:01:33Z"
    },
    {
      "id": "doi:10.1371/journal.pgen.1003144",
      "publisher_id": 340,
      "title": "Starvation, Together with the SOS Response, Mediates High Biofilm-Specific Tolerance to the Fluoroquinolone Ofloxacin",
      "issued": {
        "date-parts": [
          [
            2013,
            1,
            3
          ]
        ]
      },
      "container-title": "PLOS Genetics",
      "volume": 9,
      "page": "e1003144",
      "issue": 1,
      "DOI": "10.1371/journal.pgen.1003144",
      "events": {
        "crossref": 21,
        "counter": 6722
      },
      "timestamp": "2015-04-12T08:19:12Z"
    }
  ]
}
```

#### /api/works/doi:10.1371/journal.pgen.1003182

```json
{
  "meta": {
    "status": "ok",
    "message-type": "work",
    "message-version": "6.0.0"
  },
  "work": {
    "id": "doi:10.1371/journal.pgen.1003182",
    "publisher_id": 340,
    "title": "Alternative Oxidase Expression in the Mouse Enables Bypassing Cytochrome <i>c</i> Oxidase Blockade and Limits Mitochondrial ROS Overproduction",
    "issued": {
      "date-parts": [
        [
          2013,
          1,
          3
        ]
      ]
    },
    "container-title": "PLOS Genetics",
    "volume": 9,
    "page": "e1003182",
    "issue": 1,
    "DOI": "10.1371/journal.pgen.1003182",
    "events": {
      "crossref": 16,
      "counter": 6702
    },
    "timestamp": "2015-04-16T06:14:07Z"
  }
}
```

## Create/Update/Delete
These actions are limited to users with admin privileges, authenticated with the API key via HTTP header. The API supports the following REST actions:

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<th valign="top" width=30%>HTTP Verb</td>
<th valign="top" width=40%>Path</td>
<th valign="top" width=30%>Action</td>
</tr>
<tr>
<td valign="top" width=30%>GET</td>
<td valign="top" width=40%>/api/works</td>
<td valign="top" width=30%>index</td>
</tr>
<tr>
<td valign="top" width=30%>POST</td>
<td valign="top" width=40%>/api/works</td>
<td valign="top" width=30%>create</td>
</tr>
<tr>
<td valign="top" width=30%>GET</td>
<td valign="top" width=40%>/api/works/info:doi/DOI</td>
<td valign="top" width=30%>show</td>
</tr>
<tr>
<td valign="top" width=30%>PUT</td>
<td valign="top" width=40%>/api/works/info:doi/DOI</td>
<td valign="top" width=30%>update</td>
</tr>
<tr>
<td valign="top" width=30%>DELETE</td>
<td valign="top" width=40%>/api/works/info:doi/DOI</td>
<td valign="top" width=30%>delete</td>
</tr>
</tbody>
</table>

### Create work
A sample curl API call to create a new work would look like this:

```sh
curl -X POST -H "Content-Type: application/vnd.lagotto+json" -H "Authentication: Token token=API_KEY" -d '{"work":{"doi":"10.1371/journal.pone.0036790","year":2012,"month":5,"day":15,"title":"Test title"}}' http://HOST/api/works
```

When a work has been created successfully, the server reponds with `Status 201 Created` and the following JSON (the `data` object will include all work attributes):

```sh
$ curl -i -X POST -H "Content-Type: application/vnd.lagotto+json" -H "Authentication: Token token=API_KEY" -d '{"work":{"doi":"10.7554/eLife.09002","year":2013,"month":5,"day":21,"title":"Structure of a pore-blocking toxin in complex with a eukaryotic voltage-dependent K+ channel"}}' http://HOST/api/works
HTTP/1.1 201 Created
Status: 201 Created
Content-Type: application/json; charset=utf-8

{"success":"Work created.","error":null,"work":{"doi":"10.7554/eLife.09002","title":"Structure of a pore-blocking toxin in complex with a eukaryotic voltage-dependent K+ channel","canonical_url":null,"mendeley_uuid":null,"pmid":null,"pmcid":null,"views":0,"shares":0,"bookmarks":0,"citations":0,"sources":[{"name":"pmc","display_name":"PubMed Central Usage Stats","events_url":null,"metrics":[]},{"name":"copernicus",
 ... more ...
```

When a work with the specified DOI already exists, the server returns HTTP 400 error with a JSON body indicating the work exists:

```sh
$ curl -i -X POST -H "Content-Type: aapplication/vnd.lagotto+json" -H "Authentication: Token token=API_KEY" -d '{"work":{"doi":"10.7554/eLife.09002","year":2013,"month":5,"day":21,"title":"Structure of a pore-blocking toxin in complex with a eukaryotic voltage-dependent K+ channel"}}' http://HOST/api/works
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

* The API key must be valid, and for a user with role admin.


### Update work
A sample curl API call to update a work would look like this:

```sh
curl -X POST -H "Content-Type: application/vnd.lagotto+json" -H "Authentication: Token token=API_KEY" -d '{"work":{"pmid":"22615813"}}' http://HOST/api/works/doi:10.1371/journal.pone.0036790
```

When a work has been updated successfully, the server reponds with `Status 200 Ok` and the following JSON (the `data` object will include all work attributes):

```sh
{"success":"Work updated.","error":null,"data":{ ... }
```

### Delete work
A sample curl API call to delete a work would look like this:

```sh
curl -X POST -H "Content-Type: application/vnd.lagotto+json" -H "Authentication: Token token=API_KEY" -d '{"work":{"pmid":"22615813"}}' http://HOST/api/works/doi:10.1371/journal.pone.0036790
```

When a work has been deleted successfully, the server reponds with `Status 200 Ok` and the following JSON (the `data` object will include all work attributes):

```sh
{"success":"Work deleted.","error":null,"data":{ ... }
```

### Get alerts
The alerts API endpoint is only available to authenticated admin users. The same query parameters as in the admin web interface are supported:

* source
* class_name
* level
* query (but using `q`)

By default the API returns all alerts, add `&unresolved=1` to only retrieve unresolved alerts, as in the admin web interface. An example API response would be:

```sh
{
  "meta": {
    "status": "ok",
    "message-type": "alert-list",
    "message-version": "6.0.0",
    "total": 152,
    "total_pages": 4,
    "page": 1
  },
  "alerts": [
    {
      "id": "39586c14-8d3e-4f83-9636-d36ca2d6b958",
      "level": "FATAL",
      "class_name": "StandardError",
      "message": "No Sidekiq process running, Sidekiq process started at 2015-04-16T06:24:14Z.",
      "hostname": "lagotto-4-0-unstable.local",
      "unresolved": true,
      "timestamp": "2015-04-16T06:24:15Z"
    },
    {
      "id": "018a1fb6-60e3-4b63-b84f-f33204163917",
      "level": "ERROR",
      "class_name": "NameError",
      "message": "uninitialized constant DeleteEventJob::Relation",
      "hostname": "lagotto-4-0-unstable.local",
      "unresolved": true,
      "timestamp": "2015-04-16T06:21:51Z"
    },
    {
      "id": "ecccba25-4c11-4396-b1d1-5534ca60c27d",
      "level": "FATAL",
      "class_name": "StandardError",
      "message": "No Sidekiq process running, Sidekiq process started at 2015-04-16T06:14:24Z.",
      "hostname": "lagotto-4-0-unstable.local",
      "unresolved": true,
      "timestamp": "2015-04-16T06:14:24Z"
    },
    {
      "id": "12b40b31-e347-4ec7-ac26-545844be872a",
      "level": "ERROR",
      "class_name": "NoMethodError",
      "message": "undefined method `DOI' for #<Work:0x00000007f00008>",
      "status": 422,
      "hostname": "lagotto-4-0-unstable.local",
      "unresolved": false,
      "timestamp": "2015-04-16T05:01:30Z"
    }
  ]
}
```
