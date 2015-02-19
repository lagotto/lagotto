---
layout: card
title: "Github"
---

Number of forks and stars for Github repos.

## Required configuration fields

* **personal access token **: more info at https://github.com/blog/1509-personal-api-tokens

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>github</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>default</td>
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
<td valign="top" width=80%>no</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Authentication</strong></td>
<td valign="top" width=80%>yes</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Restriction by IP Address</strong></td>
<td valign="top" width=80%>no</td>
</tr>
<tr>
<td valign="top" width=20%><strong>API URL</strong></td>
<td valign="top" width=80%>https://api.github.com/repos/OWNER/REPO</td>
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
  "id": 9681032,
  "name": "alm",
  "full_name": "ropensci/alm",
  "owner": {
    "login": "ropensci",
    "id": 1200269,
    "avatar_url": "https://avatars.githubusercontent.com/u/1200269?v=3",
    "gravatar_id": "",
    "url": "https://api.github.com/users/ropensci",
    "html_url": "https://github.com/ropensci",
    "followers_url": "https://api.github.com/users/ropensci/followers",
    "following_url": "https://api.github.com/users/ropensci/following{/other_user}",
    "gists_url": "https://api.github.com/users/ropensci/gists{/gist_id}",
    "starred_url": "https://api.github.com/users/ropensci/starred{/owner}{/repo}",
    "subscriptions_url": "https://api.github.com/users/ropensci/subscriptions",
    "organizations_url": "https://api.github.com/users/ropensci/orgs",
    "repos_url": "https://api.github.com/users/ropensci/repos",
    "events_url": "https://api.github.com/users/ropensci/events{/privacy}",
    "received_events_url": "https://api.github.com/users/ropensci/received_events",
    "type": "Organization",
    "site_admin": false
  },
  "private": false,
  "html_url": "https://github.com/ropensci/alm",
  "description": "R client for the Lagotto almetrics API platform",
  "fork": false,
  "url": "https://api.github.com/repos/ropensci/alm",
  "forks_url": "https://api.github.com/repos/ropensci/alm/forks",
  "keys_url": "https://api.github.com/repos/ropensci/alm/keys{/key_id}",
  "collaborators_url": "https://api.github.com/repos/ropensci/alm/collaborators{/collaborator}",
  "teams_url": "https://api.github.com/repos/ropensci/alm/teams",
  "hooks_url": "https://api.github.com/repos/ropensci/alm/hooks",
  "issue_events_url": "https://api.github.com/repos/ropensci/alm/issues/events{/number}",
  "events_url": "https://api.github.com/repos/ropensci/alm/events",
  "assignees_url": "https://api.github.com/repos/ropensci/alm/assignees{/user}",
  "branches_url": "https://api.github.com/repos/ropensci/alm/branches{/branch}",
  "tags_url": "https://api.github.com/repos/ropensci/alm/tags",
  "blobs_url": "https://api.github.com/repos/ropensci/alm/git/blobs{/sha}",
  "git_tags_url": "https://api.github.com/repos/ropensci/alm/git/tags{/sha}",
  "git_refs_url": "https://api.github.com/repos/ropensci/alm/git/refs{/sha}",
  "trees_url": "https://api.github.com/repos/ropensci/alm/git/trees{/sha}",
  "statuses_url": "https://api.github.com/repos/ropensci/alm/statuses/{sha}",
  "languages_url": "https://api.github.com/repos/ropensci/alm/languages",
  "stargazers_url": "https://api.github.com/repos/ropensci/alm/stargazers",
  "contributors_url": "https://api.github.com/repos/ropensci/alm/contributors",
  "subscribers_url": "https://api.github.com/repos/ropensci/alm/subscribers",
  "subscription_url": "https://api.github.com/repos/ropensci/alm/subscription",
  "commits_url": "https://api.github.com/repos/ropensci/alm/commits{/sha}",
  "git_commits_url": "https://api.github.com/repos/ropensci/alm/git/commits{/sha}",
  "comments_url": "https://api.github.com/repos/ropensci/alm/comments{/number}",
  "issue_comment_url": "https://api.github.com/repos/ropensci/alm/issues/comments/{number}",
  "contents_url": "https://api.github.com/repos/ropensci/alm/contents/{+path}",
  "compare_url": "https://api.github.com/repos/ropensci/alm/compare/{base}...{head}",
  "merges_url": "https://api.github.com/repos/ropensci/alm/merges",
  "archive_url": "https://api.github.com/repos/ropensci/alm/{archive_format}{/ref}",
  "downloads_url": "https://api.github.com/repos/ropensci/alm/downloads",
  "issues_url": "https://api.github.com/repos/ropensci/alm/issues{/number}",
  "pulls_url": "https://api.github.com/repos/ropensci/alm/pulls{/number}",
  "milestones_url": "https://api.github.com/repos/ropensci/alm/milestones{/number}",
  "notifications_url": "https://api.github.com/repos/ropensci/alm/notifications{?since,all,participating}",
  "labels_url": "https://api.github.com/repos/ropensci/alm/labels{/name}",
  "releases_url": "https://api.github.com/repos/ropensci/alm/releases{/id}",
  "created_at": "2013-04-25T20:47:13Z",
  "updated_at": "2014-10-29T19:17:02Z",
  "pushed_at": "2014-11-13T01:52:00Z",
  "git_url": "git://github.com/ropensci/alm.git",
  "ssh_url": "git@github.com:ropensci/alm.git",
  "clone_url": "https://github.com/ropensci/alm.git",
  "svn_url": "https://github.com/ropensci/alm",
  "homepage": "http://cran.r-project.org/web/packages/alm/index.html",
  "size": 3410,
  "stargazers_count": 5,
  "watchers_count": 5,
  "language": "R",
  "has_issues": true,
  "has_downloads": true,
  "has_wiki": true,
  "has_pages": false,
  "forks_count": 2,
  "mirror_url": null,
  "open_issues_count": 5,
  "forks": 2,
  "open_issues": 5,
  "watchers": 5,
  "default_branch": "master",
  "organization": {
    "login": "ropensci",
    "id": 1200269,
    "avatar_url": "https://avatars.githubusercontent.com/u/1200269?v=3",
    "gravatar_id": "",
    "url": "https://api.github.com/users/ropensci",
    "html_url": "https://github.com/ropensci",
    "followers_url": "https://api.github.com/users/ropensci/followers",
    "following_url": "https://api.github.com/users/ropensci/following{/other_user}",
    "gists_url": "https://api.github.com/users/ropensci/gists{/gist_id}",
    "starred_url": "https://api.github.com/users/ropensci/starred{/owner}{/repo}",
    "subscriptions_url": "https://api.github.com/users/ropensci/subscriptions",
    "organizations_url": "https://api.github.com/users/ropensci/orgs",
    "repos_url": "https://api.github.com/users/ropensci/repos",
    "events_url": "https://api.github.com/users/ropensci/events{/privacy}",
    "received_events_url": "https://api.github.com/users/ropensci/received_events",
    "type": "Organization",
    "site_admin": false
  },
  "network_count": 2,
  "subscribers_count": 4
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/github.rb).
