---
layout: card
title: "CrossRef"
---

[CrossRef](http://www.crossref.org) is a non-profit organization that enables cross-publisher citation linking of the scholarly literature via Digital Object Identifiers (DOIs). CrossRef member organizations can use the **Cited-by** Linking service that provides basic information about the scholarly literature citing a particular DOI that they have published. All other users can use the CrossRef **OpenURL** service which provides citation counts (the `fl_count' attribute), but no information about the citing literature. Lagotto handles both scenarios.

## Required configuration fields

### Cited-by

Add username and password provided by CrossRef in the `Publisher Configuration` tab of the CrossRef source. This setting is specific to a particular publisher associated with the user entering this information.

### OpenURL

For articles without a publisher the `openurl_username` in the `Configuration` tab of the CrossRef source will be used. You can register for a CrossRef Query Services account [here](http://www.crossref.org/requestaccount/).

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>crossref</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>id (as doi)<br/>url (as http://dx.doi.org/DOI)<br/>contributor(s)</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>ISSN<br/>journal title<br/>journal abbreviation<br/>title<br/>volume<br/>issue<br/>first page<br/>year<br/>publication type<br/>citation count</td>
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
<td valign="top" width=80%>username and password</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Restriction by IP Address</strong></td>
<td valign="top" width=80%>no</td>
</tr>
<tr>
<td valign="top" width=20%><strong>API URL Cited-By</strong></td>
<td valign="top" width=80%>http://doi.crossref.org/servlet/getForwardLinks?usr=USERNAME&pwd=PASSWORD&doi=DOI</td>
</tr>
<tr>
<td valign="top" width=20%><strong>API URL OpenURL</strong></td>
<td valign="top" width=80%>http://www.crossref.org/openurl/?pid=USERNAME&id=doi:DOI&noredirect=true</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Limitations</strong></td>
<td valign="top" width=80%>Publication date may be incomplete<br/>No unique identifiers for contributors</td>
</tr>
</tbody>
</table>

## Example Response Cited-By

```xml
<?xml version="1.0" encoding="UTF-8"?>
<crossref_result version="2.0" xmlns="http://www.crossref.org/qrschema/2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.crossref.org/qrschema/2.0 http://www.crossref.org/qrschema/crossref_query_output2.0.xsd">
  <query_result>
    <head>
      <doi_batch_id>none</doi_batch_id>
    </head>
    <body>
      <forward_link doi="10.1371/journal.pone.0006022">
        <journal_cite fl_count="17">
          <issn type="print">0028-0836</issn>
          <issn type="electronic">1476-4687</issn>
          <journal_title>Nature</journal_title>
          <journal_abbreviation>Nature</journal_abbreviation>
          <article_title>Metrics: A profusion of measures</article_title>
          <contributors>
            <contributor first-author="true">
              <given_name>Richard</given_name>
              <surname>Van Noorden</surname>
            </contributor>
          </contributors>
          <volume>465</volume>
          <issue>7300</issue>
          <first_page>864</first_page>
          <year>2010</year>
          <publication_type>full_text</publication_type>
          <doi type="journal_article">10.1038/465864a</doi>
        </journal_cite>
      </forward_link>
      <forward_link doi="10.1371/journal.pone.0006022">
        <journal_cite fl_count="1">
          <issn type="print">18788750</issn>
          <journal_title>World Neurosurgery</journal_title>
          <journal_abbreviation>World Neurosurgery</journal_abbreviation>
          <article_title>Finding a Way Through the Scientific Literature: Indexes and Measures</article_title>
          <contributors>
            <contributor first-author="true">
              <given_name>Thomas</given_name>
              <surname>Jones</surname>
            </contributor>
            <contributor first-author="false">
              <given_name>Sarah</given_name>
              <surname>Huggett</surname>
            </contributor>
            <contributor first-author="false">
              <given_name>Judith</given_name>
              <surname>Kamalski</surname>
            </contributor>
          </contributors>
          <volume>76</volume>
          <issue>1-2</issue>
          <first_page>36</first_page>
          <year>2011</year>
          <publication_type>full_text</publication_type>
          <doi type="journal_article">10.1016/j.wneu.2011.01.015</doi>
        </journal_cite>
      </forward_link>
    </body>
  </query_result>
</crossref_result>
```

## Example Response OpenURL

```xml
<?xml version="1.0" encoding="UTF-8"?>
<crossref_result xmlns="http://www.crossref.org/qrschema/2.0" version="2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.crossref.org/qrschema/2.0 http://www.crossref.org/schema/queryResultSchema/crossref_query_output2.0.xsd">
  <query_result>
    <head>
      <doi_batch_id>none</doi_batch_id>
    </head>
    <body>
      <query status="resolved" fl_count="49">
        <doi type="journal_article">10.1371/journal.pone.0006022</doi>
        <issn type="electronic">1932-6203</issn>
        <journal_title>PLoS ONE</journal_title>
        <contributors>
          <contributor sequence="first" contributor_role="editor">
            <given_name>Thomas</given_name>
            <surname>Mailund</surname>
          </contributor>
          <contributor sequence="first" contributor_role="author">
            <given_name>Johan</given_name>
            <surname>Bollen</surname>
          </contributor>
          <contributor sequence="additional" contributor_role="author">
            <given_name>Herbert</given_name>
            <surname>Van de Sompel</surname>
          </contributor>
          <contributor sequence="additional" contributor_role="author">
            <given_name>Aric</given_name>
            <surname>Hagberg</surname>
          </contributor>
          <contributor sequence="additional" contributor_role="author">
            <given_name>Ryan</given_name>
            <surname>Chute</surname>
          </contributor>
        </contributors>
        <volume>4</volume>
        <issue>6</issue>
        <first_page>e6022</first_page>
        <year media_type="online">2009</year>
        <publication_type>full_text</publication_type>
        <article_title>A Principal Component Analysis of 39 Scientific Impact Measures</article_title>
      </query>
    </body>
  </query_result>
</crossref_result>
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/cross_ref.rb).

## Further Documentation
* [CrossRef Cited-by Linking](http://www.crossref.org/citedby.html)
* [CrossRef OpenURL](http://help.crossref.org/#using_the_open_url_resolver)
* [Registration for CrossRef OpenURL account](http://www.crossref.org/requestaccount/)
