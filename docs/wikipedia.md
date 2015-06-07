---
layout: card
title: Wikipedia
---

Wikipedia is a free encyclopedia that everyone can edit.

We are collecting the number of Wikipedia articles (`namespace=0`) in the [25 most popular wikipedias](https://meta.wikimedia.org/wiki/List_of_Wikipedias#All_Wikipedias_ordered_by_number_of_articles) and Wikimedia Commons (`namespace=6`):

```sh
en nl de sv fr it ru es pl war ceb ja vi pt zh uk ca no fi fa id cs ko hu ar commons
```

We would for example use `en.wikipedia.org` as `HOST` in the `API URL` below. We are not counting the number of hits in the user or file namespaces.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>Lagotto Name</strong></td>
<td valign="top" width=70%>wikipedia</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Lagotto Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Lagotto Core Attributes</strong></td>
<td valign="top" width=80%>url</td>
</tr>
<td valign="top" width=20%><strong>Lagotto Other Attributes</strong></td>
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
<td valign="top" width=80%>http://HOST/w/api.php?action=query&list=search&format=json&srsearch=\"DOI\"+OR+\"URL\"&srnamespace=NAMESPACE&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=50&sroffset=%{sroffset}&continue=</td>
</tr>
</tbody>
</table>

## Example Response

```json
{
  "batchcomplete": "",
  "query": {
    "searchinfo": {
      "totalhits": 8
    },
    "search": [
      {
        "ns": 6,
        "title": "File:Cercopithecus lomamiensis Female.jpg",
        "timestamp": "2013-08-29T21:27:22Z"
      },
      {
        "ns": 6,
        "title": "File:Cercopithecus lomamiensis Juv.jpg",
        "timestamp": "2013-08-29T21:28:03Z"
      },
      {
        "ns": 6,
        "title": "File:Cercopithecus lomamiensis (Lesula).png",
        "timestamp": "2013-08-29T21:25:48Z"
      },
      {
        "ns": 6,
        "title": "File:Cercopithecus lomamiensis MaleP.jpg",
        "timestamp": "2013-08-29T21:29:00Z"
      },
      {
        "ns": 6,
        "title": "File:Cercopithecus lomamiensis Male.jpg",
        "timestamp": "2013-08-29T21:28:22Z"
      },
      {
        "ns": 6,
        "title": "File:Journal.pone.0044271.g001.png",
        "timestamp": "2013-08-29T21:14:47Z"
      },
      {
        "ns": 6,
        "title": "File:Cercopithecus hamlyni booms - journal.pone.0044271.s015.ogg",
        "timestamp": "2015-02-24T14:34:48Z"
      },
      {
        "ns": 6,
        "title": "File:Cercopithecus lomamiensis booms - journal.pone.0044271.s016.ogg",
        "timestamp": "2015-02-24T14:34:48Z"
      }
    ]
  }
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/wikipedia.rb).

## Further Documentation
* [Mediawiki API Documentation](http://www.mediawiki.org/wiki/API:Main_page)
