Version 3 of the API was released October 30, 2012 (ALM 2.3).

## Base URL
All API calls to the version 3 API start with ``/api/v3/articles``.

## Supported Media Types
* JSON (default)
* XML

The media type is set in the header, e.g. "Accept: application/json". Media type negotiation via file extension (e.g. ".json") is not supported. The API defaults to JSON if no media type is given, e.g. to test the API with a browser.

## API Key
All API calls require an API key, use the format `?api_key=API_KEY`. A key can be obtained by registering as API user with the ALM application and this shouldn't take more than a few minutes. By default the ALM application uses [Mozilla Persona](http://www.mozilla.org/en-US/persona/), but it can also be configured to use other services usch as OAuth and CAS. For the PLOS ALM application you need to sign in with your [PLOS Journals account](http://register.plos.org/ambra-registration/register.action).

## Query for one or several Articles
Specify one or more articles by a comma-separated list of DOIs in the `ids` parameter. These DOIs have to be URL-escaped, e.g. `%2F` for `/`:

    /api/v3/articles?api_key=API_KEY&ids=10.1371%2Fjournal.pone.0036240
    /api/v3/articles?api_key=API_KEY&ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413

Queries for up to 50 articles at a time are supported.

## Additional Parameters

### type=doi|pmid|pmcid|mendeley
The version 3 API supports queries for DOI, PubMed ID, PubMed Central ID and Mendeley UUID. The default `doi` is used if no type is given in the query. The following queries are all for the same article:

    /api/v3/articles?api_key=API_KEY&ids=10.1371%2Fjournal.pmed.1001361
    /api/v3/articles?api_key=API_KEY&ids=23300388&type=pmid
    /api/v3/articles?api_key=API_KEY&ids=PMC3531501&type=pmcid
    /api/v3/articles?api_key=API_KEY&ids=437b07d9-bc40-4c57-b60e-1f60fefe2300&type=mendeley

### info=summary|detail|event|history
With the **summary** parameter no source information or metrics are provided, only article metadata such as DOI, PubMed ID, title or publication date. The only exception are summary statistics, aggregating metrics from several sources (views, shares, bookmarks and citations).

With the **event** parameter all raw data sent by the source are provided.

    /api/v3/articles?api_key=API_KEY&ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&info=event

With the **history** parameter all historical data are provided. This also includes metrics by day, month and year.

    /api/v3/articles?api_key=API_KEY&ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&info=history

With the **detail** parameter all historical data and all raw data sent by the source are provided. This also includes metrics by day, month and year.

    /api/v3/articles?api_key=API_KEY&ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&info=detail

### source=x
Only provide metrics for a given source, or a list of sources. The response format is the same as the default response.

    /api/v3/articles?api_key=API_KEY&ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&source=mendeley,crossref

### days=x or months=x
With either of these parameters, the metrics are provided for a timepoint a given number of days or months after publiation. The response format is the same as the default response.

    /api/v3/articles?api_key=API_KEY&ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&days=30

### year=x
The metrics are provided for a timepoint at the end of the given year. The response format is the same as the default response.

    /api/v3/articles?api_key=API_KEY&ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&year=2011

## Metrics
The metrics for every source are returned as total number, and separated in categories, e.g. `html` and `pdf` views for usage data, `shares` and `groups` for Mendeley, or `shares`, `likes` and `comments` for Facebook. The same seven categories are always returned for every source to simplify parsing of API responses:

* **CiteULike**: shares

* **Mendeley**: shares, groups

* **Twitter**: comments

* **Facebook**: shares, likes, comments

* **Reddit**: likes, comments

* **CrossRef, PubMed, Nature Blogs, ResearchBlogging, ScienceSeeker, Wordpress.com, Wikipedia, PMC Europe Citations, PMC Europe Database Citations**: citations

* **Counter, PubMed Central**: html, pdf

## Search
Search is not supported by the v3 API, users have to provide specific identifiers.

## Signposts
Several metrics are aggregated and available in all API queries:

* views: counter + pmc (PLOS only)
* shares: facebook (+ twitter at PLOS)
* bookmarks: mendeley + citeulike
* citations: crossref (scopus at PLOS)

## Date and Time Format
All dates and times are in ISO 8601, e.g. ``2003-10-13T07:00:00Z``

## Null
The API returns `null` if no query was made, and `0` if the external API returns 0 events.

## Example Response
### JSON

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

### XML

    <?xml version="1.0" encoding="UTF-8"?>
    <articles>
      <article>
        <doi>10.1371/journal.pone.0036240</doi>
        <title>How Academic Biologists and Physicists View Science Outreach</title>
        <url>http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0036240</url>
        <mendeley>88bfe7f0-9cb4-11e1-ac31-0024e8453de6</mendeley>
        <pmid>22590526</pmid>
        <pmcid>3348938</pmcid>
        <publication_date>2012-05-09T07:00:00Z</publication_date>
        <update_date>2013-05-17T13:33:36Z</update_date>
        <views>12987</views>
        <shares>276</shares>
        <bookmarks>38</bookmarks>
        <citations>3</citations>
        <sources>
          <source>
            <name>bloglines</name>
            <display_name>Bloglines</display_name>
            <events_url nil="true"/>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations>0</citations>
              <total>0</total>
            </metrics>
            <update_date>2009-03-12T00:29:00Z</update_date>
          </source>
          <source>
            <name>citeulike</name>
            <display_name>CiteULike</display_name>
            <events_url>http://www.citeulike.org/doi/10.1371/journal.pone.0036240</events_url>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares>5</shares>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations nil="true"/>
              <total>5</total>
            </metrics>
            <update_date>2013-05-12T21:20:14Z</update_date>
          </source>
          <source>
            <name>connotea</name>
            <display_name>Connotea</display_name>
            <events_url nil="true"/>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations>0</citations>
              <total>0</total>
            </metrics>
            <update_date>2009-03-12T00:29:20Z</update_date>
          </source>
          <source>
            <name>crossref</name>
            <display_name>CrossRef</display_name>
            <events_url nil="true"/>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations>3</citations>
              <total>3</total>
            </metrics>
            <update_date>2013-05-10T03:17:07Z</update_date>
          </source>
          <source>
            <name>nature</name>
            <display_name>Nature</display_name>
            <events_url nil="true"/>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations>1</citations>
              <total>1</total>
            </metrics>
            <update_date>2013-05-15T16:04:54Z</update_date>
          </source>
          <source>
            <name>postgenomic</name>
            <display_name>Postgenomic</display_name>
            <events_url nil="true"/>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations>0</citations>
              <total>0</total>
            </metrics>
            <update_date>2009-03-12T00:30:06Z</update_date>
          </source>
          <source>
            <name>pubmed</name>
            <display_name>PubMed Central</display_name>
            <events_url>http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&amp;cmd=link&amp;LinkName=pubmed_pmc_refs&amp;from_uid=22590526</events_url>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations>1</citations>
              <total>1</total>
            </metrics>
            <update_date>2013-05-10T16:55:43Z</update_date>
          </source>
          <source>
            <name>scopus</name>
            <display_name>Scopus</display_name>
            <events_url nil="true"/>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations>0</citations>
              <total>0</total>
            </metrics>
            <update_date>2013-02-01T09:44:57Z</update_date>
          </source>
          <source>
            <name>counter</name>
            <display_name>Counter</display_name>
            <events_url>http://www.plosreports.org/services/rest?method=usage.stats&amp;doi=10.1371%2Fjournal.pone.0036240</events_url>
            <metrics>
              <pdf>814</pdf>
              <html>12036</html>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations nil="true"/>
              <total>12886</total>
            </metrics>
            <update_date>2013-05-17T13:33:36Z</update_date>
          </source>
          <source>
            <name>researchblogging</name>
            <display_name>Research Blogging</display_name>
            <events_url nil="true"/>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations>0</citations>
              <total>0</total>
            </metrics>
            <update_date>2013-05-17T07:59:35Z</update_date>
          </source>
          <source>
            <name>biod</name>
            <display_name>Biod</display_name>
            <events_url nil="true"/>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations nil="true"/>
              <total>0</total>
            </metrics>
            <update_date>2013-05-17T12:52:04Z</update_date>
          </source>
          <source>
            <name>wos</name>
            <display_name>Web of Science®</display_name>
            <events_url>http://gateway.webofknowledge.com/gateway/Gateway.cgi?GWVersion=2&amp;SrcApp=PARTNER_APP&amp;SrcAuth=PLoSCEL&amp;KeyUT=000305336100022&amp;DestLinkType=CitingArticles&amp;DestApp=WOS_CPL&amp;UsrCustomerID=c642dd6a62e245b029e19b27ca7f6b1c</events_url>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations>1</citations>
              <total>1</total>
            </metrics>
            <update_date>2013-05-16T06:13:38Z</update_date>
          </source>
          <source>
            <name>pmc</name>
            <display_name>PubMed Central Usage Stats</display_name>
            <events_url nil="true"/>
            <metrics>
              <pdf>19</pdf>
              <html>82</html>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations nil="true"/>
              <total>101</total>
            </metrics>
            <update_date>2013-05-17T02:06:31Z</update_date>
          </source>
          <source>
            <name>facebook</name>
            <display_name>Facebook</display_name>
            <events_url nil="true"/>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares>58</shares>
              <groups nil="true"/>
              <comments>54</comments>
              <likes>47</likes>
              <citations nil="true"/>
              <total>159</total>
            </metrics>
            <update_date>2013-05-16T04:09:20Z</update_date>
          </source>
          <source>
            <name>mendeley</name>
            <display_name>Mendeley</display_name>
            <events_url>http://api.mendeley.com/research/academic-biologists-physicists-view-science-outreach-1/</events_url>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares>33</shares>
              <groups>0</groups>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations nil="true"/>
              <total>33</total>
            </metrics>
            <update_date>2013-05-03T12:13:26Z</update_date>
          </source>
          <source>
            <name>twitter</name>
            <display_name>Twitter</display_name>
            <events_url nil="true"/>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations>117</citations>
              <total>117</total>
            </metrics>
            <update_date>2013-05-10T19:21:40Z</update_date>
          </source>
          <source>
            <name>wikipedia</name>
            <display_name>Wikipedia</display_name>
            <events_url nil="true"/>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations>0</citations>
              <total>0</total>
            </metrics>
            <update_date>2013-05-05T13:18:29Z</update_date>
          </source>
          <source>
            <name>scienceseeker</name>
            <display_name>ScienceSeeker</display_name>
            <events_url nil="true"/>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations>0</citations>
              <total>0</total>
            </metrics>
            <update_date>2013-05-12T14:19:53Z</update_date>
          </source>
          <source>
            <name>relativemetric</name>
            <display_name>Relative Metric</display_name>
            <events_url nil="true"/>
            <metrics>
              <pdf nil="true"/>
              <html nil="true"/>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations nil="true"/>
              <total>14031</total>
            </metrics>
            <update_date>2013-05-03T04:06:33Z</update_date>
          </source>
        </sources>
      </article>
    </articles>
