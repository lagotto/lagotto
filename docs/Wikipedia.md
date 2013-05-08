Wikipedia is a free encyclopedia that everyone can edit. 

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>wikipedia</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>staleness: 7.days<br/>batch_time_interval: 1.hour</td>
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
<td valign="top" width=80%>http://HOST/w/api.php?action=query&list=search&format=json&srsearch=DOI&srwhat=text&srinfo=totalhits&srprop=timestamp&sroffset=OFFSET</td>
</tr>
</tbody>
</table>

## Example Response
    {
      query: {
        searchinfo: {
        totalhits: 7
      },
      search: [
        {
        ns: 0,
        title: "Yurgovuchia",
        timestamp: "2012-07-12T10:37:53Z"
        },
        {
        ns: 0,
        title: "Dromaeosauridae",
        timestamp: "2012-08-06T04:22:15Z"
        },
        {
        ns: 0,
        title: "Compsognathidae",
        timestamp: "2012-06-23T07:06:54Z"
        },
        {
        ns: 0,
        title: "Xiaotingia",
        timestamp: "2012-07-15T05:58:38Z"
        },
        {
        ns: 0,
        title: "Eudromaeosauria",
        timestamp: "2012-07-15T12:36:04Z"
        },
        {
        ns: 0,
        title: "2012 in paleontology",
        timestamp: "2012-08-07T00:47:31Z"
        },
        {
        ns: 0,
        title: "Microraptoria",
        timestamp: "2012-07-15T02:13:21Z"
        }
      ]
      }
    }

## Source Code
The source code is available [here](https://github.com/articlemetrics/alm/blob/master/app/models/sources/wikipedia.rb). 

## Further Documentation
* [Mediawiki API Documentation](http://www.mediawiki.org/wiki/API:Main_page)