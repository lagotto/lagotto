RESTful API URLs generally correspond to HTML URLs; you can usually just add ".xml" or ".json" to the HTML (unsuffixed) URL and perform a GET request. Both XML and JSON formats are provided (CSV is also supported for the article index), though attribute arrangement might be different between formats (and might differ from the information included in the HTML presentation generated without the format suffix).

All ".json" requests can be made with JSONP support by including a querystring "callback" parameter; the result will be wrapped in a Javascript function call to that parameter's value, for ease of handling on the client side. For example:

`/articles/10.1371/bogus.json` would return something like this:

    {"article": {"doi": "10.1371/bogus", "pub_med": null, "pub_med_central": null, "updated_at": "2009-01-04T13:59:27-08:00", 
    "event_count": 0}}

`/articles/10.1371/bogus.json?callback=x would return something like:`

    x({"article": {"doi": "10.1371/bogus", "pub_med": null, "pub_med_central": null, "updated_at": "2009-01-04T13:59:27-08:00", 
    "event_count": 0}});

In XML requests, null values are returned as empty strings; in JSON requests, they're Javascript nulls.

Some requests aren't intended for high-volume use; they haven't been optimized and can currently take several seconds to execute.

In the examples, spaces have been removed for readability.

## Changes between ALM 1.0 and ALM 2.0

### Request Parameters

<table width="737" border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width="85"><strong> </strong></td>
<td valign="top" width="180"><strong>ALM 1.0</strong></td>
<td valign="top" width="76"><strong>ALM 2.0</strong></td>
<td valign="top" width="397"><strong>Comments</strong></td>
</tr>
<tr>
<td colspan="3" valign="top" width="340"><strong>General Options</strong><strong></strong></td>
<td valign="top" width="397"></td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="161">[json|xml|csv]</td>
<td valign="top" width="95">unchanged</td>
<td valign="top" width="397">Response format</td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="161">callback=x</td>
<td valign="top" width="95">unchanged</td>
<td valign="top" width="397">Will return JSONP</td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="161">api_key=API_KEY</td>
<td valign="top" width="95">unchanged</td>
<td valign="top" width="397">API key required for all requests</td>
</tr>
<tr>
<td colspan="3" valign="top" width="340"><strong>Information about a </strong><strong>collection of articles</strong></td>
<td valign="top" width="397"></td>
</tr>
<tr>
<td valign="top" width="85"><strong>Query</strong></td>
<td valign="top" width="161">/articles.[json|xml]?query=STRING&amp;api_key=API_KEY</td>
<td valign="top" width="95">unchanged</td>
<td valign="top" width="397">STRING is substring of DOI, useful to search for all articles in a particular journal. Example: "<strong>http://alm.plos.org/articles.json?query=journal.pmed
&amp;api_key=API_KEY"</strong></td>
</tr>
<tr>
<td valign="top" width="85"><strong>Options</strong></td>
<td valign="top" width="161">order=[doi|published_on]</td>
<td valign="top" width="95">unchanged</td>
<td valign="top" width="397">Order of results, options are <strong>order=doi</strong> (default) and <strong>order=published_on</strong></td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="161">cited=[0|1]</td>
<td valign="top" width="95">unchanged</td>
<td valign="top" width="397">Only include articles that have at least one citation (cited=1) or no citations (cited=0)</td>
</tr>
<tr>
<td colspan="3" valign="top" width="340"><strong>Information about a single article</strong></td>
<td valign="top" width="397"></td>
</tr>
<tr>
<td valign="top" width="76"><strong>Query</strong></td>
<td valign="top" width="170">/articles/DOI.[json|xml|csv]?api_key=API_KEY</td>
<td valign="top" width="95">unchanged</td>
<td valign="top" width="397">Example: "<strong>http://alm.plos.org/articles/10.1371/journal.pone.0006169.json?api_key=API_KEY"</strong></td>
</tr>
<tr>
<td valign="top" width="76"><strong>Options</strong></td>
<td valign="top" width="170">source=SOURCE</td>
<td valign="top" width="95">unchanged</td>
<td valign="top" width="397">Only return results for SOURCE. Ignored unless citations=1 and/or history=1</td>
</tr>
<tr>
<td valign="top" width="76"></td>
<td valign="top" width="170">citations=1</td>
<td valign="top" width="95">renamed</td>
<td valign="top" width="397">Renamed to events=1</td>
</tr>
<tr>
<td valign="top" width="76"></td>
<td valign="top" width="170">history=1</td>
<td valign="top" width="95">unchanged</td>
<td valign="top" width="397"></td>
</tr>
</tbody>
</table>

### Response Attributes

<table width="737" border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width="85"><strong> </strong></td>
<td valign="top" width="180"><strong>ALM 1.0</strong></td>
<td valign="top" width="76"><strong>ALM 2.0</strong></td>
<td valign="top" width="397"><strong>Comments</strong></td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="180">title</td>
<td valign="top" width="76">unchanged</td>
<td valign="top" width="397"></td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="180">doi</td>
<td valign="top" width="76">unchanged</td>
<td valign="top" width="397"></td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="180">pub_med</td>
<td valign="top" width="76">unchanged</td>
<td valign="top" width="397">PubMed ID (PMID)</td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="180">pub_med_central</td>
<td valign="top" width="76">unchanged</td>
<td valign="top" width="397">PubMed Central ID (PMCID)</td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="180">published</td>
<td valign="top" width="76">unchanged</td>
<td valign="top" width="397">Publication date in datetime format. Example:<strong> "2009-07-08T00:00:00-07:00"</strong></td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="180">updated_at</td>
<td valign="top" width="76">removed</td>
<td valign="top" width="397">In ALM 2.0 sources are updated in different intervals, use <strong>updated_at</strong> parameter of individual sources.</td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="180">citations_count</td>
<td valign="top" width="76">renamed and changed</td>
<td valign="top" width="397">Renamed to events_count. The number is the sum of the <strong>count</strong> attribute of all individual sources. The <strong>count</strong> attribute of individual sources is calculated differently in ALM 2.0 (see below).</td>
</tr>
<tr>
<td colspan="4" valign="top" width="737"><strong>Source attributes for requests about a single article (for events=1 and/or history=1)</strong></td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="180">source</td>
<td valign="top" width="76">unchanged</td>
<td valign="top" width="397">SOURCE name</td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="180">count</td>
<td valign="top" width="76">changed</td>
<td valign="top" width="397">In ALM 1.0 this is the number of citation elements, for sources that don't collect individual citations (see below) this number is therefore 1 or 2. In ALM 2.0 it is the total sum of all the values we get from the sources, and therefore very different from ALM 1.0 for sources that don't collect individual events (counter, biod, pmc, facebook, mendeley).</td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="180">public_url</td>
<td valign="top" width="76">unchanged</td>
<td valign="top" width="397"></td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="180">search_url</td>
<td valign="top" width="76">removed</td>
<td valign="top" width="397"></td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="180">updated_at</td>
<td valign="top" width="76">format changed</td>
<td valign="top" width="397">Changed from timestamp (e.g. <strong>1341158683</strong>) to datetime (e.g. "<strong>2012-07-02T20:28:35Z"</strong>) format</td>
</tr>
<tr>
<td valign="top" width="85"><strong>events=1</strong></td>
<td valign="top" width="180">citations</td>
<td valign="top" width="76">renamed</td>
<td valign="top" width="397">Renamed to events. A collection of citations/events.</td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="180">citation (for source counter, biod, pmc, facebook, or mendeley)</td>
<td valign="top" width="76">renamed and changed</td>
<td valign="top" width="397">In ALM 1.0 sources that don't collect individual citations have 1 or 2 citations. Each citation can contain <strong>views</strong> (counter, biod, pmc) or other attributes (Facebook, Mendeley). In ALM 2.0 sources that don't collect individual events have an event for every time information was collected (e.g. daily or weekly).</td>
</tr>
<tr>
<td valign="top" width="85"></td>
<td valign="top" width="180">citation (for source citeulike, crossref, scopus, or twitter)</td>
<td valign="top" width="76">renamed and changed</td>
<td valign="top" width="397">In ALM 1.0 sources that collect individual citations have citation attributes depending on the source, the data structure is changed. In ALM 2.0 sources that collect individual events have an <strong>event</strong> and<strong> event_url</strong>. The event attributes depend on the source, the data structure is unchanged.</td>
</tr>
<tr>
<td valign="top" width="85"><strong>history=1</strong></td>
<td valign="top" width="180">histories</td>
<td valign="top" width="76">changed</td>
<td valign="top" width="397">In ALM 1.0 counts are rolled up every month. In ALM 2.0 counts are reported for every data point (e.g. daily or weekly), and therefore are not directly comparable to ALM 1.0 historic data.</td>
</tr>
</tbody>
</table>

## Collections of articles
Retreive an array of all articles, each of which has the following attributes:

* `title`: title of the article
* `pub_med`: the article's PubMed ID
* `pub_med_central`: the article's PubMedCentral ID
* `doi`: the article's DOI, without prefix
* `published`: when the article was published
* `events_count`: the total number of events from all sources for this article

Options:

* `cited=1` -- if 1, only include articles that have at least one event; if 0, only include articles that have no events.
* `query=journal.pbio` -- only include articles whose DOI includes the given substring; this turns into a "doi like '%journal.pbio%'" query.
* `order=doi` -- Sort the results; options include doi, published_on.
* Formats: .xml, .json, .csv

Examples:

[http://alm.plos.org/articles.xml](http://alm.plos.org/articles.xml)

    <?xml version="1.0" encoding="UTF-8"?>
    <articles type="array">
      <article doi="10.1002/bies.200900043" title="Making the right connections: biological networks in the light of evolution" pub_med="19722181" pub_med_central="2962804" events_count="13" published="2009-10-01 00:00:00 -0700">
      </article>
      <article doi="10.1002/bies.20599" title="Evolution of size and pattern in the social amoebas" pub_med="17563079" pub_med_central="3045520" events_count="22" published="2007-07-01 00:00:00 -0700">
      </article>
      ...
    </articles>

[http://alm.plos.org/articles.json](http://alm.plos.org/articles.json)

    [
      {
        "article" :
          {
            "title" : "Making the right connections: biological networks in the light of evolution",
            "pub_med_central" : "2962804",
            "doi" : "10.1002/bies.200900043",
            "published" : "1969-12-31T00:00:00-08:00",
            "events_count" : 7,
            "pub_med" : "19722181"
          }
      },
      ...
    ]

## Information about a single article
Shows information about one article, with options to include additional information:

* `title`: title of the article
* `pub_med`: the article's PubMed ID
* `pub_med_central`: the article's PubMedCentral ID
* `doi`: the article's DOI, without prefix
* `published`: when the article was published
* `events_count`: the total number of events from all sources for this article

Options:

* events=1 -- Also include the individual citing document URIs, grouped by source.
* history=1 -- Also include a historical record of event counts per month (cumulative), grouped by source.

Examples:

[http://alm.plos.org/articles/info:doi%2F10.1371%2Fjournal.pcbi.0010052.xml?events=1](http://alm.plos.org/articles/info:doi%2F10.1371%2Fjournal.pcbi.0010052.xml?events=1)

    <?xml version="1.0" encoding="UTF-8"?>
    <article doi="10.1371/journal.pcbi.0010052" title="Bioinformatics Education—Perspectives and Challenges" pub_med="16322761" pub_med_central="1289384" events_count="26" published="2005-11-25 00:00:00 -0800">
      <source source="Bloglines" updated_at="2009-03-30 14:05:17 UTC" count="0">
      </source>
      <source source="CiteULike" updated_at="2012-07-15 06:39:05 UTC" count="4" public_url="http://www.citeulike.org/doi/10.1371/journal.pcbi.0010052">
      <events>
        <event>
          <event>
            <post-time>2012-05-16 18:07:21</post-time>
            <articleid>3496747</articleid>
            <username>heathervincent</username>
            <tags>teaching</tags>
            <link>
              <url>http://www.citeulike.org/user/heathervincent/article/3496747</url>
            </link>
          </event>
          <event-url>http://www.citeulike.org/user/heathervincent/article/3496747</event-url>
        </event>
        <event>
          <event>
            <post-time>2008-12-03 06:33:47</post-time>
            <articleid>3739250</articleid>
            <username>mlangill</username>
            <tags>bioinformatics, connotea, education</tags>
            <link>
              <url>http://www.citeulike.org/user/mlangill/article/3739250</url>
            </link>
          </event>
          <event-url>http://www.citeulike.org/user/mlangill/article/3739250</event-url>
        </event>
        ...
      </article>
      ...
    </articles>

[http://alm.plos.org/articles/info:doi%2F10.1371%2Fjournal.pcbi.0010052.xml?citations=1&source=Citeulike](http://alm.plos.org/articles/info:doi%2F10.1371%2Fjournal.pcbi.0010052.xml?citations=1&source=Citeulike)

    <?xml version="1.0" encoding="UTF-8"?>
    <article doi="10.1371/journal.pcbi.0010052" title="Bioinformatics Education—Perspectives and Challenges" pub_med="16322761" pub_med_central="1289384" events_count="26" published="2005-11-25 00:00:00 -0800">
      <source source="Bloglines" updated_at="2009-03-30 14:05:17 UTC" count="0">
      </source>
      <source source="CiteULike" updated_at="2012-07-15 06:39:05 UTC" count="4" public_url="http://www.citeulike.org/doi/10.1371/journal.pcbi.0010052">
      <events>
        <event>
          <event>
            <post-time>2012-05-16 18:07:21</post-time>
            <articleid>3496747</articleid>
            <username>heathervincent</username>
            <tags>teaching</tags>
            <link>
              <url>http://www.citeulike.org/user/heathervincent/article/3496747</url>
            </link>
          </event>
          <event-url>http://www.citeulike.org/user/heathervincent/article/3496747</event-url>
        </event>
        ...
      </article>
      ...
    </articles>

## Example users of the ALM API

A number of applications using the ALM API participated in the [PLOS/Mendeley Binary Battle](http://api.plos.org/2011/11/30/winners-of-the-mendeleyplos-api-binary-battle/).

* [ImpactStory](http://impactstory.org) aggregates altmetrics diverse impacts from your articles, datasets, blog posts, and more.
* [rplos](https://github.com/ropensci/rplos) from the rOpenSci project uses the PLOS Search and PLOS ALM API.