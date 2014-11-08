---
layout: card
title: "Facebook"
---

Facebook is the largest social network.

An **app_id** and **app_secret** are required for OAuth authentication and can be obtained from the Facebook [App Dashboard](https://developers.facebook.com/apps). Lagotto uses the following URL to get the access_token:

```sh
https://graph.facebook.com/oauth/access_token?client_id=%{client_id}&client_secret=%{client_secret}&grant_type=client_credentials
```

Since January 2013 Facebook aggregates the stats from DOIs (e.g. http://dx.doi.org/10.1371/journal.pone.0035869) with those from the journal landing page (e.g. http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0035869), so that multiple API calls per article are no longer necessary.

Facebook has problems with DOIs that require cookies during DOI resolution, and it then reports numbers for the journal site instead of the individual article. Check your article DOI in the Facebook [Debugger](https://developers.facebook.com/tools/debug) if you aren't sure that Facebook can reach your article pages correctly.

Since the release of the v2.1 API in August 2014 the **link_stat** API endpoint is depreciated. New user accounts have to use the v2.1 API and only get the total count of Facebook activity, whereas users will older API keys can still use the **link_stat** API and get the number of shares, comments and likes in addition to the total count. Please add the following link_stat URL to the Facebook configuration to use the **link_stat** API:

```sh
https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, share_count, like_count, comment_count, click_count, total_count from link_stat where url = '%{query_url}'
```

## Required configuration fields

* **client_id (app_id)**: can be obtained by registering your application in the Facebook [App Dashboard](https://developers.facebook.com/apps).
* **client_secret (app_secret)**: see above

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>facebook</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>staleness: [ 1.day, 1.day, 1.month * 0.25, 1.month]</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>&nbsp;</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>&nbsp;</td>
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
<td valign="top" width=80%>varies</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Authentication</strong></td>
<td valign="top" width=80%>OAuth 2.0</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Restriction by IP Address</strong></td>
<td valign="top" width=80%>no</td>
</tr>
<tr>
<td valign="top" width=20%><strong>API URL</strong></td>
<td valign="top" width=80%>https://graph.facebook.com/v2.1/?access_token=%{access_token}&id=DOI_AS_URL</td>
</tr>
<tr>
<td valign="top" width=20%><strong>License</strong></td>
<td valign="top" width=80%>unknown</td>
</tr>
</tbody>
</table>

## Example Response

```json
{
   "og_object": {
      "id": "119940294870426",
      "description": "PLOS Medicine is an open-access, peer-reviewed medical journal that publishes outstanding human studies that substantially enhance the understanding of human health and disease.",
      "title": "Why Most Published Research Findings Are False",
      "type": "article",
      "updated_time": "2014-10-24T15:34:04+0000",
      "url": "http://www.plosmedicine.org/article/info\u00253Adoi\u00252F10.1371\u00252Fjournal.pmed.0020124"
   },
   "share": {
      "comment_count": 0,
      "share_count": 9972
   },
   "id": "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124"
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/facebook.rb).

## Further Documentation
* [Facebook Graph API](https://developers.facebook.com/docs/graph-api/using-graph-api/v2.1)
