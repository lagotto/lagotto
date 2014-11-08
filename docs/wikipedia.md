---
layout: card
title: Wikipedia
---

Wikipedia is a free encyclopedia that everyone can edit.

We are collecting the number of Wikipedia articles (`namespace=0`) in the [25 most popular wikipedias](https://meta.wikimedia.org/wiki/List_of_Wikipedias#All_Wikipedias_ordered_by_number_of_articles) and Wikimedia Commons (`namespace=6`):

```sh
en nl de sv fr it ru es pl war ceb ja vi pt zh uk ca no fi fa id cs ko hu ar commons
```

We would for example use `en.wikipedia.org` as `HOST` in the `API URL` below.

Because of the extensive load-balancing on Wikipedia's servers, pagination (for more than 50 results) is not reliable and we therefore don't collect links to individual Wikipedia pages. We are not counting the number of hits in the user or file namespaces.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>wikipedia</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>job_batch_size: 100</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>url</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>language<br/>namespace</td>
</tr>
<tr>
<td valign="top" width=30%><strong>Protocol</strong></td>
<td valign="top" width=70%>REST</td>
</tr>
<tr>
<td valign="top" width=30%><strong>Format</strong></td>
<td valign="top" width=70%>JSON</td>
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
<td valign="top" width=80%>http://HOST/w/api.php?action=query&list=search&format=json&srsearch=%22DOI%22&srnamespace=NAMESPACE&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=1</td>
</tr>
</tbody>
</table>

## Example Response

```json
{
  "query-continue": {
    "search": {
      "sroffset": 1
    }
  },
  "query": {
    "searchinfo": {
      "totalhits": 685
    },
    "search": [
      {
        "ns": 0,
        "title": "Calliotropis tiara",
        "timestamp": "2013-04-14T14:52:39Z"
      }
    ]
  }
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/wikipedia.rb).

## Further Documentation
* [Mediawiki API Documentation](http://www.mediawiki.org/wiki/API:Main_page)
