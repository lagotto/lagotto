---
layout: card
title: "ScienceSeeker"
---

[ScienceSeeker](http://scienceseeker.org) is a science blog aggregator.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>scienceseeker</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>staleness: [ 1.day, 1.day, 1.month, 1.month]</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>url (as href)<br/>contributor (as author)<br/>date (as updated)</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>title<br/>summary<br/>recommendations</td>
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
<td valign="top" width=80%>http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=DOI</td>
</tr>
</tbody>
</table>

## Example Response

```xml
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en"
      xmlns:ss="http://scienceseeker.org/ns/1">
  <title type="text">ScienceSeeker</title>
  <subtitle type="text">Recent Posts</subtitle>
  <link href="http://scienceseeker.org/subjectseeker/ss-search.php" rel="self"
    type="application/atom+xml" />
  <link href="http://scienceseeker.org" rel="alternate" type="text/html" />
  <id>http://scienceseeker.org/subjectseeker/ss-search.php</id>
  <updated>2012-10-29T19:36:20-04:00</updated>
  <rights>No copyright asserted over individual posts; see original
    posts for copyright and/or licensing.</rights>
  <generator>ScienceSeeker Atom serializer</generator>
  <entry xml:lang="en">
    <title type="html">Web analytics: Numbers speak louder than words</title>
    <id>http://scienceseeker.org/post/125861</id>
    <link href="http://duncan.hull.name/2012/05/18/two-ton/" rel="alternate" />
    <updated>2012-05-18T03:58:34-04:00</updated>
    <author>
      <name>Duncan</name>
    </author>
    <summary type="html">According to the software which runs this site, this is the 200th post here at O&amp;#8217;Really?  To mark the occasion, here are some stats via WordPress with thoughts and general navel-gazing analysis paralysis [1] on web analytics. It all started just over six years ago at nodalpoint with help from Greg Tyrelle, the last four years have been WordPressed with help from Matt [...]</summary>
    <ss:citations>
      <ss:citation>
        <ss:citationId type="scienceseeker">1086</ss:citationId>
        <ss:citationId type="doi">10.1371/journal.pone.0035869</ss:citationId>
        <ss:citationText>&lt;span class=&quot;Z3988&quot; title=&quot;ctx_ver=Z39.88-2004&amp;amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;amp;rft.jtitle=PLoS+ONE&amp;amp;rfr_id=info%3Asid%2Fresearchblogging.org&amp;amp;rft.atitle=Research+Blogs+and+the+Discussion+of+Scholarly+Information&amp;amp;rft.issn=1932-6203&amp;amp;rft.date=2012&amp;amp;rft.volume=7&amp;amp;rft.issue=5&amp;amp;rft.spage=0&amp;amp;rft.epage=&amp;amp;rft.artnum=http%3A%2F%2Fdx.plos.org%2F10.1371%2Fjournal.pone.0035869&amp;amp;rft_id=info%3Adoi%2F10.1371%2Fjournal.pone.0035869&amp;amp;rft.au=Shema%2C+H.&amp;amp;rft.au=Bar-Ilan%2C+J.&amp;amp;rft.au=Thelwall%2C+M.&amp;rfs_dat=ss.included=1&amp;rfe_dat=bpr3.included=1&quot;&gt;Shema, H., Bar-Ilan, J. &amp; Thelwall, M. (2012). Research Blogs and the Discussion of Scholarly Information, &lt;span style=&quot;font-style:italic;&quot;&gt;PLoS ONE, 7&lt;/span&gt; (5)  DOI: &lt;a rev=&quot;review&quot; href=&quot;http://dx.doi.org/10.1371%2Fjournal.pone.0035869&quot;&gt;10.1371/journal.pone.0035869&lt;/a&gt;&lt;/span&gt;</ss:citationText>
      </ss:citation>
    </ss:citations>
    <ss:community>
      <ss:recommendations userlevel="user" count="0"/>
      <ss:recommendations userlevel="editor" count="0"/>
      <ss:comments count="0" />
    </ss:community>
    <category term="Mathematics" />
    <category term="Publishing" />
    <category term="200" />
    <category term="akismet" />
    <category term="analysis paralysis" />
    <category term="friendfeed" />
    <category term="greg tyrelle" />
    <category term="impact factor" />
    <category term="impact factor boxing" />
    <category term="jawohl" />
    <category term="journal citation reports" />
    <category term="matt mullenweg" />
    <category term="mike thelwall" />
    <category term="navel gazing" />
    <category term="nodalpoint" />
    <category term="performance metrics" />
    <category term="plos biology" />
    <category term="researchblogging" />
    <category term="social media" />
    <category term="solo" />
    <category term="statistics" />
    <category term="thomson-reuters" />
    <category term="traffic" />
    <category term="underworld" />
    <category term="wall street journal" />
    <category term="web analytics" />
    <category term="wordpress" />
    <category term="wsj" />
    <category term="research" />
    <category term="scholarship" />
    <category term="blogging" />
    <source>
      <title type="text">O'Really?</title>
      <link href="http://feeds.feedburner.com/oreally" rel="self" />
      <link href="http://duncan.hull.name" rel="alternate" type="text/html" />
      <category term="Biology" />
      <category term="Computer Science" />
    </source>
  </entry>
  <entry xml:lang="en">
    <title type="html">An Orgy of Self-Referential Blogging...</title>
    <id>http://scienceseeker.org/post/124437</id>
    <link href="http://feedproxy.google.com/~r/TheNeurocritic/~3/93yLg0gGe2g/orgy-of-self-referential-blogging.html" rel="alternate" />
    <updated>2012-05-12T17:24:00-04:00</updated>
    <author>
      <name>The Neurocritic</name>
    </author>
    <summary type="html">&lt;br />&lt;br />...may follow from a new PLoS ONE paper on bloggers whose posts are aggregated at ResearchBlogging.org (Shema et al., 2012):&lt;br />The average RB blogger in our sample is male, either a graduate student or has been awarded a PhD and blogs under his own name.&lt;br />The Neurocritic has never been one for meta-blogging.1  I don't like to draw attention to my existence as an actual person, and I don't have time to discuss things like the pros/cons of blogging, scientific outreach, gender imbalances, scientist […]</summary>
    <ss:citations>
      <ss:citation>
        <ss:citationId type="scienceseeker">1086</ss:citationId>
        <ss:citationId type="doi">10.1371/journal.pone.0035869</ss:citationId>
        <ss:citationText>&lt;span class=&quot;Z3988&quot; title=&quot;ctx_ver=Z39.88-2004&amp;amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;amp;rft.jtitle=PLoS+ONE&amp;amp;rfr_id=info%3Asid%2Fresearchblogging.org&amp;amp;rft.atitle=Research+Blogs+and+the+Discussion+of+Scholarly+Information&amp;amp;rft.issn=1932-6203&amp;amp;rft.date=2012&amp;amp;rft.volume=7&amp;amp;rft.issue=5&amp;amp;rft.spage=0&amp;amp;rft.epage=&amp;amp;rft.artnum=http%3A%2F%2Fdx.plos.org%2F10.1371%2Fjournal.pone.0035869&amp;amp;rft_id=info%3Adoi%2F10.1371%2Fjournal.pone.0035869&amp;amp;rft.au=Shema%2C+H.&amp;amp;rft.au=Bar-Ilan%2C+J.&amp;amp;rft.au=Thelwall%2C+M.&amp;rfs_dat=ss.included=1&amp;rfe_dat=bpr3.included=1&quot;&gt;Shema, H., Bar-Ilan, J. &amp; Thelwall, M. (2012). Research Blogs and the Discussion of Scholarly Information, &lt;span style=&quot;font-style:italic;&quot;&gt;PLoS ONE, 7&lt;/span&gt; (5)  DOI: &lt;a rev=&quot;review&quot; href=&quot;http://dx.doi.org/10.1371%2Fjournal.pone.0035869&quot;&gt;10.1371/journal.pone.0035869&lt;/a&gt;&lt;/span&gt;</ss:citationText>
      </ss:citation>
    </ss:citations>
    <ss:community>
      <ss:recommendations userlevel="user" count="0"/>
      <ss:recommendations userlevel="editor" count="0"/>
      <ss:comments count="0" />
    </ss:community>
    <category term="research" />
    <category term="scholarship" />
    <category term="Publishing" />
    <category term="Science Communication" />
    <source>
      <title type="text">The Neurocritic</title>
      <link href="http://feeds.feedburner.com/TheNeurocritic" rel="self" />
      <link href="http://neurocritic.blogspot.com/" rel="alternate" type="text/html" />
      <category term="Neuroscience" />
      <category term="Psychology" />
    </source>
  </entry>
  <entry xml:lang="en">
    <title type="html">Journal Fire: Bonfire of the Vanity Journals?</title>
    <id>http://scienceseeker.org/post/124078</id>
    <link href="http://duncan.hull.name/2012/05/11/journal-fire/" rel="alternate" />
    <updated>2012-05-11T08:15:56-04:00</updated>
    <author>
      <name>Duncan</name>
    </author>
    <summary type="html">When I first heard about Journal Fire, I thought, Great! someone is going to take all the closed-access scientific journals and make a big bonfire of them! At the top of this bonfire is the burning effigy of a wicker man, representing the very worst of the vanity journals [1,2]. Unfortunately Journal Fire aren&amp;#8217;t burning anything just yet, but what [...]</summary>
    <ss:citations>
      <ss:citation>
        <ss:citationId type="scienceseeker">1077</ss:citationId>
        <ss:citationId type="doi">10.1016/j.tree.2011.11.007</ss:citationId>
        <ss:citationText>&lt;span class=&quot;Z3988&quot; title=&quot;ctx_ver=Z39.88-2004&amp;amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;amp;rft.atitle=Time+to+change+how+we+describe+biodiversity&amp;amp;rft.jtitle=Trends+in+Ecology+%26+Evolution&amp;amp;rft.artnum=http%3A%2F%2Flinkinghub.elsevier.com%2Fretrieve%2Fpii%2FS0169534711003302&amp;amp;rft.volume=27&amp;amp;rft.issue=2&amp;amp;rft.issn=01695347&amp;amp;rft.spage=84&amp;amp;rft.date=2012&amp;amp;rfr_id=info%3Asid%2Fscienceseeker.org&amp;amp;rft_id=info%3Adoi%2F10.1016%2Fj.tree.2011.11.007&amp;amp;rft.au=Deans+Andrew+R.&amp;amp;rft.aulast=Deans&amp;amp;rft.aufirst=Andrew+R.&amp;amp;rft.au=Yoder+Matthew+J.&amp;amp;rft.aulast=Yoder&amp;amp;rft.aufirst=Matthew+J.&amp;amp;rft.au=Balhoff+James+P.&amp;amp;rft.aulast=Balhoff&amp;amp;rft.aufirst=James+P.&amp;rfs_dat=ss.included=1&amp;rfe_dat=bpr3.included=1&quot;&gt;Deans, A.R., Yoder, M.J. &amp; Balhoff, J.P. (2012). Time to change how we describe biodiversity, &lt;span style=&quot;font-style:italic;&quot;&gt;Trends in Ecology &amp; Evolution, 27&lt;/span&gt; (2) 84. DOI: &lt;a rev=&quot;review&quot; href=&quot;http://dx.doi.org/10.1016%2Fj.tree.2011.11.007&quot;&gt;10.1016/j.tree.2011.11.007&lt;/a&gt;&lt;/span&gt;</ss:citationText>
      </ss:citation>
      <ss:citation>
        <ss:citationId type="scienceseeker">1086</ss:citationId>
        <ss:citationId type="doi">10.1371/journal.pone.0035869</ss:citationId>
        <ss:citationText>&lt;span class=&quot;Z3988&quot; title=&quot;ctx_ver=Z39.88-2004&amp;amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;amp;rft.jtitle=PLoS+ONE&amp;amp;rfr_id=info%3Asid%2Fresearchblogging.org&amp;amp;rft.atitle=Research+Blogs+and+the+Discussion+of+Scholarly+Information&amp;amp;rft.issn=1932-6203&amp;amp;rft.date=2012&amp;amp;rft.volume=7&amp;amp;rft.issue=5&amp;amp;rft.spage=0&amp;amp;rft.epage=&amp;amp;rft.artnum=http%3A%2F%2Fdx.plos.org%2F10.1371%2Fjournal.pone.0035869&amp;amp;rft_id=info%3Adoi%2F10.1371%2Fjournal.pone.0035869&amp;amp;rft.au=Shema%2C+H.&amp;amp;rft.au=Bar-Ilan%2C+J.&amp;amp;rft.au=Thelwall%2C+M.&amp;rfs_dat=ss.included=1&amp;rfe_dat=bpr3.included=1&quot;&gt;Shema, H., Bar-Ilan, J. &amp; Thelwall, M. (2012). Research Blogs and the Discussion of Scholarly Information, &lt;span style=&quot;font-style:italic;&quot;&gt;PLoS ONE, 7&lt;/span&gt; (5)  DOI: &lt;a rev=&quot;review&quot; href=&quot;http://dx.doi.org/10.1371%2Fjournal.pone.0035869&quot;&gt;10.1371/journal.pone.0035869&lt;/a&gt;&lt;/span&gt;</ss:citationText>
      </ss:citation>
    </ss:citations>
    <ss:community>
      <ss:recommendations userlevel="user" count="0"/>
      <ss:recommendations userlevel="editor" count="0"/>
      <ss:comments count="0" />
    </ss:community>
    <category term="Engineering" />
    <category term="informatics" />
    <category term="Publishing" />
    <category term="science" />
    <category term="andrew deans" />
    <category term="arxiv" />
    <category term="biodiversity" />
    <category term="bonfire" />
    <category term="california" />
    <category term="citeulike" />
    <category term="coins" />
    <category term="doi" />
    <category term="james balhoff" />
    <category term="jeremy cherfas" />
    <category term="journal club" />
    <category term="journal fire" />
    <category term="juan carlos lopez" />
    <category term="matthew yoder" />
    <category term="mendeley" />
    <category term="open access" />
    <category term="open data" />
    <category term="openurl" />
    <category term="pasadena" />
    <category term="pubmed" />
    <category term="researchblogging" />
    <category term="scienceseeker" />
    <category term="utopia" />
    <category term="vanity journal" />
    <category term="vanity press" />
    <category term="wicker man" />
    <category term="Computer Science" />
    <category term="Ecology" />
    <category term="Conservation" />
    <category term="research" />
    <category term="scholarship" />
    <category term="twitter" />
    <source>
      <title type="text">O'Really?</title>
      <link href="http://feeds.feedburner.com/oreally" rel="self" />
      <link href="http://duncan.hull.name" rel="alternate" type="text/html" />
      <category term="Biology" />
      <category term="Computer Science" />
    </source>
  </entry>
</feed>
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/science_seeker.rb).

## Further Documentation
* [ScienceSeeker API](http://scienceseeker.org/api)
