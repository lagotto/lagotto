---
layout: card
title: "Research Blogging"
---

Research Blogging is a science blog aggregator.

## Required configuration fields

* **username** and **password**: plesae contact Research Blogging.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>researchblogging</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>staleness: [ 1.day, 1.day, 1.month, 1.month]</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>url (as post_URL)<br/>contributor (as blogger_name)<br/>date (as published_date)</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>post_title<br/>blog_name<br/>received_date</td>
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
<td valign="top" width=80%>unknown</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Authentication</strong></td>
<td valign="top" width=80%>username<br/>password</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Restriction by IP Address</strong></td>
<td valign="top" width=80%>no</td>
</tr>
<tr>
<td valign="top" width=20%><strong>API URL</strong></td>
<td valign="top" width=80%>http://researchbloggingconnect.com/blogposts?count=100&article=doi:DOI</td>
</tr>
</tbody>
</table>

## Example Response

```xml
<blogposts total_records_found="5" total_records_returned="5" offset="0">
  <post id="151451">
    <post_title>
      Bat blowjobs found to increase length of sex in Cynopterus sphinx
    </post_title>
    <blog_name>Just A Theory</blog_name>
    <blogger_name>Colin Stuart</blogger_name>
    <received_date>2009-10-30 12:32:43</received_date>
    <published_date>2009-10-30 11:45:52</published_date>
    <post_URL>
      http://feedproxy.google.com/~r/JustATheoryRSS/~3/1iN-ffWHmso/
    </post_URL>
    <citations>
      <citation>
        <title>Fellatio by Fruit Bats Prolongs Copulation Time</title>
        <journal>PLoS ONE</journal>
        <issn>1932-6203</issn>
        <publication_year>2009</publication_year>
        <volume>4</volume>
        <pages>217-225977-987439-4421467-472</pages>
        <doi>10.1371/journal.pone.0007595</doi>
        <authors>
          <author>Tan, M.</author>
          <author>Jones, G.</author>
          <author>Zhu, G.</author>
          <author>Ye, J.</author>
          <author>Hong, T.</author>
          <author>Zhou, S.</author>
          <author>Zhang, S.</author>
          <author>Zhang, L.</author>
        </authors>
      </citation>
    </citations>
  </post>
  <post id="150941">
    <post_title>Endless forms: Oral sex by fruit bats</post_title>
    <blog_name>Denim and Tweed</blog_name>
    <blogger_name>Jeremy Yoder</blogger_name>
    <received_date>2009-10-29 14:30:01</received_date>
    <published_date>2009-10-29 14:02:00</published_date>
    <post_URL>
      http://feedproxy.google.com/~r/DenimAndTweed/~3/lzbF-_Ho2uo/endless-forms-oral-sex-by-fruitbats.html
    </post_URL>
    <citations>
      <citation>
        <title>Fellatio by fruit bats prolongs copulation time</title>
        <journal>PLoS ONE</journal>
        <issn>1932-6203</issn>
        <publication_year>2009</publication_year>
        <volume>4</volume>
        <pages>217-225977-987439-4421467-472</pages>
        <doi>10.1371/journal.pone.0007595</doi>
        <authors>
          <author>Tan, M.</author>
          <author>Jones, G.</author>
          <author>Zhu, G.</author>
          <author>Ye, J.</author>
          <author>Hong, T.</author>
          <author>Zhou, S.</author>
          <author>Zhang, S.</author>
          <author>Zhang, L.</author>
        </authors>
      </citation>
    </citations>
  </post>
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/researchblogging.rb).

## Further Documentation
* [Research Blogging website](http://researchblogging.org)
