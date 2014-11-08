---
layout: card
title: "OpenEdition"
---

[OpenEdition](http://www.openedition.org/) is the umbrella portal for OpenEdition Books, Revues.org, Hypotheses and Calenda, four platforms dedicated to electronic resources in the humanities and social sciences.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>openedition</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>rate-limit: 1000</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>url (as link)<br/>contributor (as creator)<br/>date</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>title<br/>description</td>
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
<td valign="top" width=80%>no</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Restriction by IP Address</strong></td>
<td valign="top" width=80%>no</td>
</tr>
<tr>
<td valign="top" width=20%><strong>API URL</strong></td>
<td valign="top" width=80%>"http://search.openedition.org/feed.php?op%5B%5D=AND&q%5B%5D=URL&field%5B%5D=All&pf=Hypotheses.org"</td>
</tr>
</tbody>
</table>

## Example Response

```xml
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://purl.org/rss/1.0/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/">
  <channel rdf:about="http%3A%2F%2Fsearch.openedition.org%2Ffeed.php%3Fop%255B%255D%3DAND%26q%255B%255D%3D10.2307%252F683422%26field%255B%255D%3DAll%26pf%3DHypotheses.org">
    <title>10.2307/683422 - Recherche OpenEdition</title>
    <description>Flux RSS de votre recherche: 10.2307/683422</description>
    <link>http://search.openedition.org</link>
    <items>
      <rdf:Seq>
        <rdf:li resource="http://ruedesfacs.hypotheses.org/?p=1666"/>
      </rdf:Seq>
    </items>
  </channel>
  <item rdf:about="http://ruedesfacs.hypotheses.org/?p=1666">
    <link>http://ruedesfacs.hypotheses.org/?p=1666</link>
    <title>Saartjie Baartman : la Vénus Hottentote</title>
    <dc:date>2013-05-27</dc:date>
    <dc:creator>ruedesfacs</dc:creator>
    <dcterms:isPartOf rdf:resource="http://ruedesfacs.hypotheses.org">Rue des facs</dcterms:isPartOf>
    <description>
      <![CDATA[
        ... , no 3 (1 septembre 2000): 606 607. doi:<em>10.2307</em>/<em>683422</em>. « The Hottentot Venus Is Going Home ». The Journal of Blacks in Higher Education no 35 (1 avril 2002): 63. doi:<em>10.2307</em>/3133845. Vous trouverez toutes ...
      ]]>
    </description>
  </item>
</rdf:RDF>
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/openedition.rb).
