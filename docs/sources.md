---
layout: card
title: "Sources"
---

The Lagotto software includes a number of sources. Most sources require a user account with the service (see table below).

### Viewed
* [PubMed Central Usage Stats](/docs/pmc)
* [Copernicus](/docs/copernicus)

### Discussed
* [Facebook](/docs/facebook)
* [Twitter](/docs/twitter_search)
* [Nature Blogs](/docs/nature)
* [Research Blogging](/docs/researchblogging)
* [ScienceSeeker](/docs/scienceseeker)
* [Wordpress.com](/docs/wordpress)
* [Wikipedia](/docs/wikipedia)
* [Reddit](/docs/reddit)
* [OpenEdition](/docs/openedition)

### Saved
* [CiteULike](/docs/citeulike)
* [Mendeley](/docs/mendeley)

### Cited
* [CrossRef](/docs/crossref)
* [PubMed Central Citations](/docs/pubmed)
* [Europe PMC Citations](/docs/pmceurope)
* [Scopus](/docs/scopus)
* [Web of Science](/docs/wos)
* [DataCite](/docs/datacite)
* [Europe PMC Database Citations](/docs/pmceuropedata)

### Recommended
* [F1000Prime](/docs/f1000)

### PLOS-specific Sources
* [PLOS Usage Stats](/docs/counter)
* [PLOS Figshare Usage Stats](/docs/figshare)
* [PLOS Comments](/docs/plos_comments)

### Retired Sources
* [Biod](/docs/biod)
* [Bloglines](/docs/bloglines)
* [Connotea](/docs/connotea)
* [Postgenomic](/docs/postgenomic)

Please use the [Issue Tracker](https://github.com/articlemetrics/alm/issues) for questions or feedback regarding sources.

<table>
<tbody>
<tr>
<td><strong>Name</strong></td>
<td><strong>Authentication</strong></td>
<td><strong>IP Restriction</strong></td>
<td><strong>Format</strong></td>
<td><strong>Protocol</strong></td>
<td><strong>Rate-limiting</strong></td>
</tr>
<tr>
<td>CiteULike</td>
<td>no</td>
<td>no</td>
<td>XML</td>
<td>REST</td>
<td>2,000/hour</td>
</tr>
<tr>
<td>CrossRef</td>
<td>username<br/>password</td>
<td>no</td>
<td>XML</td>
<td>REST</td>
<td>unknown</td>
</tr>
<tr>
<td>DataCite</td>
<td>no</td>
<td>no</td>
<td>JSON or XML</td>
<td>REST</td>
<td>unknown</td>
</tr>
<tr>
<td>Facebook</td>
<td>OAuth 2.0</td>
<td>no</td>
<td>JSON</td>
<td>REST</td>
<td>varies</td>
</tr>
<tr>
<td>Mendeley</td>
<td>OAuth 2.0</td>
<td>no</td>
<td>JSON</td>
<td>REST</td>
<td>150/hour</td>
</tr>
<tr>
<td>Nature Blogs</td>
<td>no</td>
<td>no</td>
<td>JSON</td>
<td>REST</td>
<td>2/sec<br/>5,000/day</td>
</tr>
<tr>
<td>PubMed Central Citations</td>
<td>no</td>
<td>no</td>
<td>XML</td>
<td>REST</td>
<td>unknown</td>
</tr>
<tr>
<td>PubMed Central Usage Stats</td>
<td>yes</td>
<td>no</td>
<td>XML</td>
<td>HTTP</td>
<td>unknown</td>
</tr>
<tr>
<td>Reddit</td>
<td>no</td>
<td>no</td>
<td>JSON</td>
<td>REST</td>
<td>1,800/hr</td>
</tr>
<tr>
<td>Research Blogging</td>
<td>username<br/>password</td>
<td>no</td>
<td>XML</td>
<td>REST</td>
<td>unknown</td>
</tr>
<tr>
<td>ScienceSeeker</td>
<td>no</td>
<td>no</td>
<td>XML</td>
<td>REST</td>
<td>unknown</td>
</tr>
<tr>
<td>Scopus</td>
<td>api_key<br/>insttoken</td>
<td>optional</td>
<td>XML or JSON</td>
<td>REST</td>
<td>unknown</td>
</tr>
<tr>
<td>Wikipedia</td>
<td>no</td>
<td>no</td>
<td>JSON</td>
<td>REST</td>
<td>unknown</td>
</tr>
</tbody>
</table>

## Event Information
Most sources return information about each individual event (citation, bookmark, etc.), and this information is summarized below. The exception are sources that don't return information about individual events because of privacy (all usage data, Facebook, Mendeley readers) or for licensing reasons (Scopus, Web of Science, F1000).

<table>
<tbody>
<tr>
<td><strong>Name</strong></td>
<td><strong>ID</strong></td>
<td><strong>URL</strong></td>
<td><strong>Datetime</strong></td>
<td><strong>Contributor</strong></td>
<td><strong>Title</strong></td>
<td><strong>Other</strong></td>
</tr>
<tr>
<td>CiteULike</td>
<td>&nbsp;</td>
<td>url</td>
<td>post_time</td>
<td>username</td>
<td>&nbsp;</td>
<td>tag</td>
</tr>
<tr>
<td>CrossRef</td>
<td>doi</td>
<td>doi</td>
<td>&nbsp;</td>
<td>contributor(s)</td>
<td>title</td>
<td>ISSN<br/>journal title<br/>journal abbreviation<br/>volume<br/>issue<br/>first page<br/>year<br/>publication type<br/>citation count</td>
</tr>
<tr>
<td>Mendeley Groups</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>date_added</td>
<td>profile_id</td>
<td>&nbsp;</td>
<td>group_id</td>
</tr>
<tr>
<td>Nature Blogs</td>
<td>id</td>
<td>url</td>
<td>published_at</td>
<td>&nbsp;</td>
<td>title</td>
<td>blog title<br/>blog url</td>
</tr>
<tr>
<td>PubMed Central Citations</td>
<td>pmcid</td>
<td>pmcid</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
</tr>
<tr>
<td>Research Blogging</td>
<td>&nbsp;</td>
<td>post_URL</td>
<td>published_date</td>
<td>blogger_name</td>
<td>post_title</td>
<td>blog_name<br/>received_date</td>
</tr>
<tr>
<td>ScienceSeeker</td>
<td>id</td>
<td>href</td>
<td>updated</td>
<td>author</td>
<td>title</td>
<td>summary<br/>category<br/>recommendations</td>
</tr>
<tr>
<td>Twitter</td>
<td>id</td>
<td>url</td>
<td>created_at</td>
<td>username</td>
<td>text</td>
<td>user_profile_image</td>
</tr>
<tr>
<td>Wikipedia</td>
<td>&nbsp;</td>
<td>url</td>
<td>datetime</td>
<td>&nbsp;</td>
<td>title</td>
<td>language<br/>namespace</td>
</tr>
</tbody>
</table>

## Creating a new source
Basically, each of the APIs that the ALM application is calling will be defined as a **source**. The ALM application provides a number of services to each source to help it get what it needs. Note the samples provided at [http://github.com/articlemetrics/alm/tree/master/app/models/sources](http://github.com/articlemetrics/alm/tree/master/app/models/sources).
