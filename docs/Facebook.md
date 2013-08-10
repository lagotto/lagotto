Facebook is the largest social network.

Information about obtaining an app access token for this source can be found at http://developers.facebook.com/docs/howtos/login/login-as-app/

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>facebook</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>staleness: [ 1.day, 1.day, 1.month * 0.25, 1.month]<br/>batch_time_interval: 1.hour</td>
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
<td valign="top" width=80%>&nbsp;</td>
</tr>
</tbody>
</table>

## Example Response
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

## Source Code
The source code is available [here](https://github.com/articlemetrics/alm/blob/master/app/models/sources/facebook.rb). 

## Further Documentation
* [Facebook Developer Documentation](http://developers.facebook.com/docs/reference/fql/link_stat/)
