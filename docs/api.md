---
layout: card_list
title: "API"
---

## Basic Information

* version 7 of the API was released April 11, 2016 (Lagotto 5.0).

### Base URL
* API calls start with `/api/`. API versioning is done via the request header, e.g. `Accept: application/json; version=7`, and currently defaults to `version=7`. Previous API versions are no longer supported because of breaking changes in the data model.

### Supported Media Types
* application/json

The default media type is JSON. The media type is set in the header, e.g. "Accept: application/json", but defaults to this format anyway. Media type negotiation via file extension (e.g. ".json") is not supported. `JSONP` and `CORS` are supported.

### API Key
Almost all information regarding works (with the exception of sources that don't allow redistribution of data) is available without API keys since the Lagotto 3.12.7 release (January 9, 2015). An API key is required to add/update works, and to access some of the internal data of the application. A key can be obtained by registering as API user with the ALM application and this shouldn't take more than a few minutes. Lagotto supports OAuth authentication via Github and ORCID, as well as CAS and JWT. Authentication via username/password is not supported.

The v7 API requires the API key in the header in the format `Authorization: Token token=API_KEY`.

### API endpoints

All API endpoints are described in the [live API documentation](/api). The most important ones are:

* /works
* /api/works/doi.org/10.1371/JOURNAL.PONE.0148637
* /api/works/doi.org/10.1371/JOURNAL.PONE.0148637/relations
* /api/works/doi.org/10.1371/JOURNAL.PONE.0148637/results
* /api/works/doi.org/10.1371/JOURNAL.PONE.0148637/contributions

The last three API endpoints provide more detailed information associated with a work.

### Meta
Every API response starts with a `meta` object with basic information such as `message-type` and number of results (`total`).

```
"meta": {
  "status": "ok",
  "message-type": "work-list",
  "message-version": "v7",
  "total": 1077,
  "total_pages": 2,
  "page": 1
}
```

### Query for one or several works
Specify one or more works by a comma-separated list of pids in the `ids` parameter. These DOIs have to be URL-escaped, e.g. `%2F` for `/`:

```sh
/api/works?ids=http://doi.org/10.1371%2Fjournal.pone.0036240
/api/works?ids=http://doi.org/10.1371%2Fjournal.pone.0036240,http://doi.org/10.1371%2Fjournal.pbio.0020413
```

Alternatively you can specify the identifier with the `type` query parameter, e.g.

```sh
/api/works?ids=10.1371%2Fjournal.pone.0036240&type=doi
/api/works?ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&type=doi
```

Queries for up to 1,000 works at a time are supported. With many ids, in particular DOIs or URLs, the size limit of the query URL might be reached. It is therefore advisable to put the ids into the body of a POST, and include an `X-HTTP-Method-Override: GET` header:

```sh
curl -X POST -d "ids=http://doi.org/10.1371%2Fjournal.pone.0036240,http://doi.org/10.1371%2Fjournal.pbio.0020413" -H "Authorization: Token token=API_KEY" -H "X-HTTP-Method-Override: GET" "http://alm.plos.org/api/works"
```

### Search
Search is not supported by the API, users have to provide one or more specific identifiers (see above).

### Date and Time Format
All dates and times are in ISO 8601 format, e.g. ``2003-10-13T07:00:00Z`` or ``2014-10``, partial dates are supported.

## Additional Parameters

### type=doi|pmid|pmcid|arxiv|scp|wos|ark|url
The API supports queries for DOI, PubMed ID, PubMed Central ID, ArXiV ID, Scopus ID, Web of Science ID, ark, and publisher URL. The pid is used if no type is given in the query. The following queries are all for the same work:

```sh
/api/works?ids=http://doi.org/10.1371%2Fjournal.pmed.1001361
/api/works?ids=10.1371%2Fjournal.pmed.1001361&type=doi
/api/works?ids=23300388&type=pmid
/api/works?ids=PMC3531501&type=pmcid
/api/works?ids=84871667565&type=scp
/api/works?ids=000312934200011&type=wos
/api/works?ids=http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.1001361&type=url
```

### publisher_id=x
Only show works from a given publisher, using the CrossRef member ID (e.g. `340`) or DataCite data center symbol (e.g. `CERN.ZENODO`). The response format is the same as the default response.

```sh
/api/works?publisher_id=340
```

### sort=x
Results are sorted by descending result count when given the source name, e.g. `&sort=wikipedia`. Otherwise (the default) results are sorted by descending publication date. When using `&source=x`, we can only sort by publication date or that source, not a different source.

### page|per_page

Results of the v7 API are paged with 1000 results per page. Use `per_page` to pick a smaller number (0-1000) of results per page, and use `page` to page through the results.

### Metadata

All metadata are in Citation Style Language ([CSl](http://citationstyles.org/)) format where possible. We are adding additional values, and we are deviating from CSL by formatting dates using iso8601. The following metadata fields should be available for most works:

* title
* container-title
* author (one or more authors)
* issued (publication date)
* DOI
* URL
* volume
* issue
* pages
* work-type

## Example Responses

#### /api/works/

```json
{
  "meta": {
    "status": "ok",
    "message-type": "work-list",
    "message-version": "v7",
    "total": 203,
    "total_pages": 1,
    "page": 1
  },
  "works": [
    {
      "id": "http://doi.org/10.1371/JOURNAL.PONE.0148637",
      "publisher_id": "340",
      "author": [
        {
          "family": "Weber",
          "given": "Kirsten"
        },
        {
          "family": "Lau",
          "given": "Ellen F."
        },
        {
          "family": "Stillerman",
          "given": "Benjamin"
        },
        {
          "family": "Kuperberg",
          "given": "Gina R."
        }
      ],
      "title": "The Yin and the Yang of Prediction: An fMRI Study of Semantic Predictive Processing",
      "issued": "2016-03-24",
      "updated": "2016-04-07T08:46:18Z",
      "container-title": "PLOS ONE",
      "volume": "11",
      "page": "e0148637",
      "issue": "3",
      "DOI": "10.1371/journal.pone.0148637",
      "work_type_id": "article-journal",
      "results": {
        "datacite_related": 1
      }
    },
    {
      "id": "http://doi.org/10.1371/JOURNAL.PONE.0151763",
      "publisher_id": "340",
      "author": [
        {
          "family": "Murphy",
          "given": "Peter R."
        },
        {
          "family": "van Moort",
          "given": "Marianne L."
        },
        {
          "family": "Nieuwenhuis",
          "given": "Sander"
        }
      ],
      "title": "The Pupillary Orienting Response Predicts Adaptive Behavioral Adjustment after Errors",
      "issued": "2016-03-24",
      "updated": "2016-04-06T22:27:01Z",
      "container-title": "PLOS ONE",
      "volume": "11",
      "page": "e0151763",
      "issue": "3",
      "DOI": "10.1371/journal.pone.0151763",
      "work_type_id": "article-journal",
      "results": {
        "datacite_related": 1
      }
    }
  ]
}
```

#### /api/works/doi.org/10.1371/JOURNAL.PONE.0148637

```json
{
  "meta": {
    "status": "ok",
    "message-type": "work",
    "message-version": "v7"
  },
  "work": {
    "id": "http://doi.org/10.1371/JOURNAL.PONE.0148637",
    "publisher_id": "340",
    "author": [
      {
        "family": "Weber",
        "given": "Kirsten"
      },
      {
        "family": "Lau",
        "given": "Ellen F."
      },
      {
        "family": "Stillerman",
        "given": "Benjamin"
      },
      {
        "family": "Kuperberg",
        "given": "Gina R."
      }
    ],
    "title": "The Yin and the Yang of Prediction: An fMRI Study of Semantic Predictive Processing",
    "issued": "2016-03-24",
    "updated": "2016-04-07T08:46:18Z",
    "container-title": "PLOS ONE",
    "volume": "11",
    "page": "e0148637",
    "issue": "3",
    "DOI": "10.1371/journal.pone.0148637",
    "work_type_id": "article-journal",
    "results": {
      "datacite_related": 1
    }
  }
}
```

## Deposits

## Notifications
The notifications API endpoint is only available to authenticated admin users. The same query parameters as in the admin web interface are supported:

* source
* class_name
* level
* query (using `q`)

By default the API returns all notifications, add `&unresolved=1` to only retrieve unresolved notifications, as in the admin web interface. An example API response would be:

```sh
{
  "meta": {
    "status": "ok",
    "message-type": "notification-list",
    "message-version": "v7",
    "total": 152,
    "total_pages": 4,
    "page": 1
  },
  "notifications": [
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
