Facebook is the largest social network.

Information about obtaining an app access token for this source can be found at http://developers.facebook.com/docs/howtos/login/login-as-app/. Since January 2013 Facebook aggregates the stats from DOIs (e.g. http://dx.doi.org/10.1371/journal.pone.0035869) with those from the journal landing page (e.g. http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0035869), so that multiple API calls per article are no longer necessary. Since URLs with query parameters (e.g. `?pid=S1415-47572009000400031&lng=en&nrm=iso&tlng=en`) can cause problems, we use the DOI.

Facebook has problems with DOIs that require cookies during DOI resolution. We talk to Facebook via the [Graph API](https://developers.facebook.com/docs/reference/api/), the old REST API will return the same results via http://api.facebook.com/restserver.php?method=links.getStats&urls=URL, but has been depreciated.

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
<td valign="top" width=80%>https://graph.facebook.com/fql?access_token=ACCESS_TOKEN&q=select url, normalized_url, share_count, like_count, comment_count, total_count, click_count, comments_fbid, commentsbox_count from link_stat where url = 'URL'</td>
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
  "commentsbox_count": 0,
  "like_count": 0,
  "normalized_url": "http://www.plosbiology.org/article/info:doi/10.1371/journal.pbio.0000002",
  "comments_fbid": 10150608377818440,
  "total_count": 3,
  "comment_count": 0,
  "url": "plosbiology.org/article/info:doi/10.1371/journal.pbio.0000002",
  "share_count": 3,
  "click_count": 0
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/alm/blob/master/app/models/sources/facebook.rb).

## Further Documentation
* [Facebook Developer Documentation](http://developers.facebook.com/docs/reference/fql/link_stat/)
