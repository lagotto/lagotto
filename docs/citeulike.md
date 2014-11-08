---
layout: card
title: "CiteULike"
---

[CiteULike](http://www.citeulike.org) is a social bookmarking service for scholarly content.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>citeulike</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>url<br/>contributor (as username)<br/>date (as post_time)</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>tag</td>
</tr>
<tr>
<td valign="top" width=30%><strong>Protocol</strong></td>
<td valign="top" width=70%>REST</td>
</tr>
<tr>
<td valign="top" width=30%><strong>Format</strong></td>
<td valign="top" width=70%>XML</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Rate-limiting</strong></td>
<td valign="top" width=80%>2,000/hour</td>
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
<td valign="top" width=80%>http://www.citeulike.org/api/posts/for/doi/DOI</td>
</tr>
</tbody>
</table>

## Example Response

```xml
<posts>
  <post username="Publicase" article_id="4051082">
    <link url="http://www.citeulike.org/user/Publicase/article/4051082"/>
    <post_time>2012-06-28 19:42:52</post_time>
    <tag>altmetrics</tag>
    <tag>scientometrics</tag>
    <linkout type="arXiv (abstract)" url="http://arxiv.org/abs/0902.2183"/>
    <linkout type="arXiv (PDF)" url="http://arxiv.org/pdf/0902.2183"/>
    <linkout type="DOI" url="http://dx.doi.org/10.1371/journal.pone.0006022"/>
  </post>

  <post username="mblind" article_id="4051082">
    <link url="http://www.citeulike.org/user/mblind/article/4051082"/>
    <post_time>2012-06-28 02:38:44</post_time>
    <tag>impact</tag>
    <tag>informetrics</tag>
    <linkout type="arXiv (abstract)" url="http://arxiv.org/abs/0902.2183"/>
    <linkout type="arXiv (PDF)" url="http://arxiv.org/pdf/0902.2183"/>
    <linkout type="DOI" url="http://dx.doi.org/10.1371/journal.pone.0006022"/>
  </post>
</posts>
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/citeulike.rb).
