Version 3 of the API was released October 30, 2012 (ALM 2.3). The old [API v2](API-v2) is still available, and will be supported at least until May 2013.

## Base URL
All API calls to the version 3 API start with ``/api/v3/articles``. 

## Supported Media Types
* JSON (default)
* XML

The media type is set in the header, e.g. "Accept: application/json". Media type negotiation via file extension (e.g. ".json") is not supported. The API defaults to json if no media type is given, e.g. to test the API with a browser.

## Query for one or several Articles
The default query format is the ``ids`` parameter, followed by a list of DOIs. These DOIs have to be URL-escaped, e.g. ``%2F`` for ``/``:
``/api/v3/articles?ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413``

Queries for up to 50 articles at a time are supported.

The query format of the previous API is still supported for single articles:
``/api/v3/articles/info:doi/10.1371%2Fjournal.pone.0036240``

## Additional Parameters

### type=doi|pmid|pmcid|mendeley
The version 3 API supports queries for DOI, PubMed ID, PubMed Central ID and Mendeley UUID. The default ``doi`` is used if no type is given in the query. 
``/api/v3/articles?ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&type=doi``

You can also use the old query format:
``/api/v3/articles/info:pmid/22590526``

### info=summary|detail|event|history
With the **summary** parameter no source information or metrics are provided, only article metadata such as DOI, PubMed ID, title or publication date. 

With the **detail** parameter all historical data and all raw data sent by the source are provided.
``/api/v3/articles?ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&info=detail``

With the **event** parameter all raw data sent by the source are provided.
``/api/v3/articles?ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&info=event``

With the **history** parameter all historical data are provided.
``/api/v3/articles?ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&info=history``

### days=x or months=x
With either of these parameters, the metrics are provided for a timepoint a given number of days or months after publiation. The response format is the same as the default response.
``/api/v3/articles?ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&days=30``

### year=x
The metrics are provided for a timepoint at the end of the given year. The response format is the same as the default response.
``/api/v3/articles?ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&year=2011``

### source=x
Only provide metrics for a given source, or a list of sources. The response format is the same as the default response.
``/api/v3/articles?ids=10.1371%2Fjournal.pone.0036240,10.1371%2Fjournal.pbio.0020413&source=mendeley,crossref``

## Metrics
The metrics for every source are returned as total number, and separated in categories, e.g. ``html`` and ``pdf`` views for usage data, ``shares`` and ``groups`` for Mendeley, or ``shares``, ``likes`` and ``comments`` for Facebook. The same seven categories are always returned for every source to simplify parsing of API responses:

* **CiteULike**: shares

* **Mendeley**: shares, groups

* **Twitter**: comments

* **Facebook**: shares, likes, comments

* **CrossRef, PubMed, Nature Blogs, ResearchBlogging, ScienceSeeker**: citations

* **Wikipedia**: shares, citations

* **Counter, PubMed Central**: html, pdf

## Search
Search is not supported by the v3 API, users have to provide specific identifiers.

## Date and Time Format
All dates and times are in ISO 8601, e.g. ``2003-10-13T07:00:00Z``

## Null
The version 3 API returns ``null`` if no query was made, and ``0`` if the external API returns 0 events.

## Example Response
### JSON

    [
      {
        "doi": "10.1371/journal.pone.0036240",
        "mendeley": "88bfe7f0-9cb4-11e1-ac31-0024e8453de6",
        "pmcid": "3348938",
        "pmid": "22590526",
        "publication_date": "2012-05-09T07:00:00Z",
        "sources": [
          {
            "events_url": null,
            "metrics": {
              "citations": 0,
              "comments": null,
              "groups": null,
              "html": null,
              "likes": null,
              "pdf": null,
              "shares": null,
              "total": 0
            },
            "name": "bloglines",
            "update_date": "2009-03-12T00:29:00Z"
          },
          {
            "events_url": "http://www.citeulike.org/doi/10.1371/journal.pone.0036240",
            "metrics": {
              "citations": null,
              "comments": null,
              "groups": null,
              "html": null,
              "likes": null,
              "pdf": null,
              "shares": 5,
              "total": 5
            },
            "name": "citeulike",
            "update_date": "2013-05-04T10:11:14Z"
          },
          {
            "events_url": null,
            "metrics": {
              "citations": 0,
              "comments": null,
              "groups": null,
              "html": null,
              "likes": null,
              "pdf": null,
              "shares": null,
              "total": 0
            },
            "name": "connotea",
            "update_date": "2009-03-12T00:29:20Z"
          },
          {
            "events_url": null,
            "metrics": {
              "citations": 3,
              "comments": null,
              "groups": null,
              "html": null,
              "likes": null,
              "pdf": null,
              "shares": null,
              "total": 3
            },
            "name": "crossref",
            "update_date": "2013-05-01T20:09:59Z"
          },
          {
            "events_url": null,
            "metrics": {
              "citations": 1,
              "comments": null,
              "groups": null,
              "html": null,
              "likes": null,
              "pdf": null,
              "shares": null,
              "total": 1
            },
            "name": "nature",
            "update_date": "2013-05-05T03:01:40Z"
          },
          {
            "events_url": null,
            "metrics": {
              "citations": 0,
              "comments": null,
              "groups": null,
              "html": null,
              "likes": null,
              "pdf": null,
              "shares": null,
              "total": 0
            },
            "name": "postgenomic",
            "update_date": "2009-03-12T00:30:06Z"
          },
          {
            "events_url": "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=22590526",
            "metrics": {
              "citations": 1,
              "comments": null,
              "groups": null,
              "html": null,
              "likes": null,
              "pdf": null,
              "shares": null,
              "total": 1
            },
            "name": "pubmed",
            "update_date": "2013-05-02T12:10:20Z"
          },
          {
            "events_url": null,
            "metrics": {
              "citations": 0,
              "comments": null,
              "groups": null,
              "html": null,
              "likes": null,
              "pdf": null,
              "shares": null,
              "total": 0
            },
            "name": "scopus",
            "update_date": "2013-02-01T09:44:57Z"
          },
          {
            "events_url": "http://www.plosreports.org/services/rest?method=usage.stats&doi=10.1371%2Fjournal.pone.0036240",
            "metrics": {
              "citations": null,
              "comments": null,
              "groups": null,
              "html": 0,
              "likes": null,
              "pdf": 0,
              "shares": null,
              "total": 12743
            },
            "name": "counter",
            "update_date": "2013-05-04T13:20:58Z"
          },
          {
            "events_url": null,
            "metrics": {
              "citations": 0,
              "comments": null,
              "groups": null,
              "html": null,
              "likes": null,
              "pdf": null,
              "shares": null,
              "total": 0
            },
            "name": "researchblogging",
            "update_date": "2013-05-05T03:02:57Z"
          },
          {
            "events_url": null,
            "metrics": {
              "citations": null,
              "comments": null,
              "groups": null,
              "html": null,
              "likes": null,
              "pdf": null,
              "shares": null,
              "total": 0
            },
            "name": "biod",
            "update_date": "2013-05-04T12:54:00Z"
          },
          {
            "events_url": "http://gateway.webofknowledge.com/gateway/Gateway.cgi?GWVersion=2&SrcApp=PARTNER_APP&SrcAuth=PLoSCEL&KeyUT=000305336100022&DestLinkType=CitingArticles&DestApp=WOS_CPL&UsrCustomerID=c642dd6a62e245b029e19b27ca7f6b1c",
            "metrics": {
              "citations": 1,
              "comments": null,
              "groups": null,
              "html": null,
              "likes": null,
              "pdf": null,
              "shares": null,
              "total": 1
            },
            "name": "wos",
            "update_date": "2013-04-29T18:08:24Z"
          },
          {
            "events_url": null,
            "metrics": {
              "citations": null,
              "comments": null,
              "groups": null,
              "html": 70,
              "likes": null,
              "pdf": 18,
              "shares": null,
              "total": 88
            },
            "name": "pmc",
            "update_date": "2013-04-03T23:14:40Z"
          },
          {
            "events_url": null,
            "metrics": {
              "citations": null,
              "comments": 54,
              "groups": null,
              "html": null,
              "likes": 47,
              "pdf": null,
              "shares": 58,
              "total": 159
            },
            "name": "facebook",
            "update_date": "2013-05-04T16:17:56Z"
          },
          {
            "events_url": "http://api.mendeley.com/research/academic-biologists-physicists-view-science-outreach-1/",
            "metrics": {
              "citations": null,
              "comments": null,
              "groups": 0,
              "html": null,
              "likes": null,
              "pdf": null,
              "shares": 33,
              "total": 33
            },
            "name": "mendeley",
            "update_date": "2013-05-03T12:13:26Z"
          },
          {
            "events_url": null,
            "metrics": {
              "citations": 117,
              "comments": null,
              "groups": null,
              "html": null,
              "likes": null,
              "pdf": null,
              "shares": null,
              "total": 117
            },
            "name": "twitter",
            "update_date": "2013-05-02T10:16:25Z"
          },
          {
            "events_url": null,
            "metrics": {
              "citations": 0,
              "comments": null,
              "groups": null,
              "html": null,
              "likes": null,
              "pdf": null,
              "shares": null,
              "total": 0
            },
            "name": "wikipedia",
            "update_date": "2013-04-27T14:30:35Z"
          },
          {
            "events_url": null,
            "metrics": {
              "citations": 0,
              "comments": null,
              "groups": null,
              "html": null,
              "likes": null,
              "pdf": null,
              "shares": null,
              "total": 0
            },
            "name": "scienceseeker",
            "update_date": "2013-05-04T03:13:45Z"
          },
          {
            "events_url": null,
            "metrics": {
              "citations": null,
              "comments": null,
              "groups": null,
              "html": null,
              "likes": null,
              "pdf": null,
              "shares": null,
              "total": 14031
            },
            "name": "relativemetric",
            "update_date": "2013-05-03T04:06:33Z"
          }
        ],
        "title": "How Academic Biologists and Physicists View Science Outreach",
        "update_date": "2013-05-05T03:02:57Z",
        "url": "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0036240"
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
        <update_date>2013-05-05T03:02:57Z</update_date>
        <sources>
          <source>
            <name>bloglines</name>
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
            <update_date>2013-05-04T10:11:14Z</update_date>
          </source>
          <source>
            <name>connotea</name>
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
            <update_date>2013-05-01T20:09:59Z</update_date>
          </source>
          <source>
            <name>nature</name>
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
            <update_date>2013-05-05T03:01:40Z</update_date>
          </source>
          <source>
            <name>postgenomic</name>
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
            <update_date>2013-05-02T12:10:20Z</update_date>
          </source>
          <source>
            <name>scopus</name>
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
            <events_url>http://www.plosreports.org/services/rest?method=usage.stats&amp;doi=10.1371%2Fjournal.pone.0036240</events_url>
            <metrics>
              <pdf>0</pdf>
              <html>0</html>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations nil="true"/>
              <total>12743</total>
            </metrics>
            <update_date>2013-05-04T13:20:58Z</update_date>
          </source>
          <source>
            <name>researchblogging</name>
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
            <update_date>2013-05-05T03:02:57Z</update_date>
          </source>
          <source>
            <name>biod</name>
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
            <update_date>2013-05-04T12:54:00Z</update_date>
          </source>
          <source>
            <name>wos</name>
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
            <update_date>2013-04-29T18:08:24Z</update_date>
          </source>
          <source>
            <name>pmc</name>
            <events_url nil="true"/>
            <metrics>
              <pdf>18</pdf>
              <html>70</html>
              <shares nil="true"/>
              <groups nil="true"/>
              <comments nil="true"/>
              <likes nil="true"/>
              <citations nil="true"/>
              <total>88</total>
            </metrics>
            <update_date>2013-04-03T23:14:40Z</update_date>
          </source>
          <source>
            <name>facebook</name>
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
            <update_date>2013-05-04T16:17:56Z</update_date>
          </source>
          <source>
            <name>mendeley</name>
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
            <update_date>2013-05-02T10:16:25Z</update_date>
          </source>
          <source>
            <name>wikipedia</name>
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
            <update_date>2013-04-27T14:30:35Z</update_date>
          </source>
          <source>
            <name>scienceseeker</name>
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
            <update_date>2013-05-04T03:13:45Z</update_date>
          </source>
          <source>
            <name>relativemetric</name>
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