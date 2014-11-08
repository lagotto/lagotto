---
layout: card
title: "Nature"
---

Nature Blogs is a science blog aggregator. Since May 1st 2013 API keys are [no longer necessary](http://www.nature.com/developers/documentation/api-references/blogs-api/).

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>nature</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>staleness: [ 1.day, 1.month, 1.month, 1.month]<br/>requests_per_hour: 200</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>id<br/>url<br/>date (as published_at)</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>title<br/>blog title<br/>blog url</td>
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
<td valign="top" width=80%>2/sec<br/>5,000/day</td>
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
<td valign="top" width=80%>http://blogs.nature.com/posts.json?doi=DOI&api_key=API_KEY</td>
</tr>
<tr>
<td valign="top" width=20%><strong>License</strong></td>
<td valign="top" width=80%>CC-BY-NC</td>
</tr>
</tbody>
</table>

## Example Response

```json
[
  {
    post: {
      percent_complex_words: 12.9994,
      popularity: 0,
      created_at: "2009-02-05T17:12:41Z",
      title: "A new link in the chain of whale evolution",
      body: "Paleontologists have found a new fossil of a whale ancestor - and its announced just after I finish watching my preview DVD of Nat Geo's Morphed on whale evolution. I smell fate.Anyhow, the new whale predecessor was unveiled in a PLoS One article ...",
      updated_at: "2009-09-22T23:09:56Z",
      flesch: -21.5166,
      url: "feedproxy.google.com/~r/observationsofanerd/~3/aMcNB2CZW_Y/new-link-in-chain-of-whale-evolution.html",
      blog_id: 558,
      id: 29082,
      hashed_id: "a8b538120801f6735681c4ce346e3d27f4c1739f3bf349eec7f206d34cdba95b",
      blog: {
        percent_complex_words: 14.0934,
        popularity: 2,
        created_at: "2008-11-05T16:42:48Z",
        title: "Observations of a Nerd",
        niche_tag: "life_sciences",
        updated_at: "2012-07-28T01:13:27Z",
        flesch: -39.0166,
        feed_url: "scienceblogs.com/observations/index.xml",
        url: "http://scienceblogs.com/observations/",
        decided_on: "2008-11-06T19:34:40Z",
        rank: 426,
        num_posts_per_week: 1.754,
        id: 558,
        outgoing_bloglove: 2,
        num_words: 5852.28,
        ip: "bogus address",
        niche_rank: 141,
        header_title: "BLOGS",
        fog: 46.4802,
        description: "A blog about anything and everything that piques the interest of a biologist",
        status: "accepted"
      },
      links_to_doi: [
        "10.1371/journal.pone.0004366"
      ],
      num_words: 6708,
      published_at: "2009-02-05T17:12:41Z",
      fog: 40.0465
    }
  },
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/nature.rb).

## Further Documentation
* [Nature Blogs API Documentation](http://www.nature.com/developers/documentation/api-references/blogs-api/)
