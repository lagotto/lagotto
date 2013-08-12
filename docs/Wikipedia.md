Wikipedia is a free encyclopedia that everyone can edit.

We are collecting the number of Wikipedia articles (`namespace=0`) in the 20 most popular wikipedias and Wikimedia Commons:

    en de fr it pl es ru ja nl pt sv zh ca uk no fi vi cs hu ko commons

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
<td valign="top" width=80%>staleness: [ 1.day, 1.day, 1.month * 0.25, 1.month]<br/>batch_time_interval: 1.hour</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>url<br/>datetime<br/>title</td>
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
<td valign="top" width=80%>http://HOST/w/api.php?action=query&list=search&format=json&srsearch=%22DOI%22&srnamespace=0&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=1</td>
</tr>
</tbody>
</table>

## Example Response
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

## Source Code
The source code is available [here](https://github.com/articlemetrics/alm/blob/master/app/models/sources/wikipedia.rb).

## Further Documentation
* [Mediawiki API Documentation](http://www.mediawiki.org/wiki/API:Main_page)
