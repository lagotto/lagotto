---
layout: card
title: "Bitbucket"
---

Number of forks and followers for Bitbucket repos.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>Lagotto Name</strong></td>
<td valign="top" width=70%>bitbucket</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Lagotto Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Lagotto Core Attributes</strong></td>
<td valign="top" width=80%>&nbsp;</td>
</tr>
<td valign="top" width=20%><strong>Lagotto Other Attributes</strong></td>
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
<td valign="top" width=80%>no</td>
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
<td valign="top" width=80%>https://api.bitbucket.org/1.0/repositories/OWNER/REPO</td>
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
  "scm": "hg",
  "has_wiki": true,
  "last_updated": "2015-02-18T21:32:59.172",
  "no_forks": false,
  "forks_count": 272,
  "created_on": "2009-02-23T02:15:29.546",
  "owner": "galaxy",
  "logo": "https://d3oaxc4q5k2d6q.cloudfront.net/m/7cb54ff512e6/img/language-avatars/python_16.png",
  "email_mailinglist": "",
  "is_mq": false,
  "size": 296529948,
  "read_only": false,
  "fork_of": null,
  "mq_of": null,
  "followers_count": 162,
  "state": "available",
  "utc_created_on": "2009-02-23 01:15:29+00:00",
  "website": "http://galaxyproject.org/",
  "description": "Main development repository for Galaxy. \r\nActive development happens here, and this repository is thus intended for those working on Galaxy development. See http://bitbucket.org/galaxy/galaxy-dist/ for a more stable repository intended for end-users.  The project homepage is http://galaxyproject.org and the wiki is http://galaxyproject.org/wiki",
  "has_issues": true,
  "is_fork": false,
  "slug": "galaxy-central",
  "is_private": false,
  "name": "galaxy-central",
  "language": "python",
  "utc_last_updated": "2015-02-18 20:32:59+00:00",
  "email_writers": true,
  "no_public_forks": false,
  "creator": null,
  "resource_uri": "/1.0/repositories/galaxy/galaxy-central"
}
```

## Source Code
The source code is available [here](https://github.com/lagotto/lagotto/blob/master/app/models/sources/bitbucket.rb).
