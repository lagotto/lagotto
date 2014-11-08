---
layout: card
title: "Reddit"
---

[Reddit](http://www.reddit.com/) provides user-generated news links. We can collect the number of posts and comments to them, but most interesting is the score, which is calculated from upvotes and downvotes.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>reddit</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>id<br/>url<br/>date (as created)</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>title<br/>score<br/>num_comments</td>
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
<td valign="top" width=80%>1,800/hr</td>
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
<td valign="top" width=80%>"http://www.reddit.com/search?q=\"DOI\""</td>
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
  "kind": "Listing",
  "data": {
    "modhash": "",
    "children": [
      {
        "kind": "t3",
        "data": {
          "domain": "self.askscience",
          "banned_by": null,
          "media_embed": {
          },
          "subreddit": "askscience",
          "selftext_html": "&lt;!-- SC_OFF --&gt;&lt;div class=\"md\"&gt;&lt;p&gt;&lt;strong&gt;Message from Graham and Peter: Thanks everyone for all of your great questions. We&amp;#39;ll answer some of the pending questions, as of 1pm PT May 16th, but won&amp;#39;t be answering new ones.  Thanks!&lt;/strong&gt;&lt;/p&gt;\n\n&lt;p&gt;We are the authors, Peter Ralph (&lt;a href=\"/u/petrelharp\"&gt;/u/petrelharp&lt;/a&gt;) and Graham Coop\n(&lt;a href=\"/u/grahamcoop\"&gt;/u/grahamcoop&lt;/a&gt;), of a recent paper on\n&lt;a href=\"http://www.plosbiology.org/article/info%3Adoi%2F10.1371%2Fjournal.pbio.1001555\"&gt;The Geography of Recent Genetic Ancestry across Europe&lt;/a&gt;.&lt;/p&gt;\n\n&lt;p&gt;The article made some news in\n&lt;a href=\"http://www.latimes.com/news/science/la-sci-european-dna-20130508,0,6298389.story\"&gt;a&lt;/a&gt;\n&lt;a href=\"http://phenomena.nationalgeographic.com/2013/05/07/charlemagnes-dna-and-our-universal-royalty/\"&gt;number&lt;/a&gt;\n&lt;a href=\"http://www.slate.fr/life/72217/ancetres-communs-europeens-moins-de-1000-ans\"&gt;of&lt;/a&gt;\n&lt;a href=\"http://www.nature.com/news/most-europeans-share-recent-ancestors-1.12950\"&gt;places&lt;/a&gt;\nwith the headline that &amp;quot;Europeans are all related&amp;quot;.  What does that\nmean? Didn&amp;#39;t we already know that?  And how can you show that the\nSpanish and the Polish have the same ancestors only 1,000 years ago,\nbut also see different effects of events from 1,500 years ago in their\ngenomes?  We&amp;#39;re ready to talk about genetics, genealogy, and even a\nlittle bit of European history (Although note that we&amp;#39;re not historians).&lt;/p&gt;\n\n&lt;p&gt;Here&amp;#39;s a quick intro; there&amp;#39;s more detail &lt;a href=\"http://gcbias.org/european-genealogy-faq/\"&gt;here&lt;/a&gt;.&lt;/p&gt;\n\n&lt;p&gt;Few of us know our family histories more than a few generations back. It is therefore\neasy to overlook the fact that we are all distant cousins, related to\none another via a vast network of relationships. &lt;/p&gt;\n\n&lt;p&gt;In the paper we use\ngenome-wide data from European individuals to investigate these\nrelationships over the past 3,000 years, by looking for long stretches\nof genome that are shared between pairs of individuals through their\ninheritance from common genetic ancestors. We find evidence of\nubiquitous recent common ancestry, showing for instance that even\npairs of individuals from opposite ends of Europe share hundreds of\ngenetic common ancestors over this time period. &lt;/p&gt;\n\n&lt;p&gt;Since the vast\nmajority of genealogical ancestors from 1,000 years ago are not\ngenetic ancestors, this implies that all of the Europeans in our\nsample share nearly all of their genealogical ancestors only 1000\nyears ago (albeit to differing extents). Despite this degree of\ncommonality, there are also regional differences. Southeastern\nEuropeans, for example, share relatively more common ancestors that\ndate roughly to the era of the Slavic and Hunnic expansions around\n1,500 years ago, while most common genetic ancestors that Italians\nshare with other populations lived longer than 2,500 years ago. The study of long stretches of shared genetic material promises to uncover\nrich information about many aspects of recent population history.&lt;/p&gt;\n\n&lt;p&gt;&lt;strong&gt;Ask us\nanything about our paper!&lt;/strong&gt;&lt;/p&gt;\n&lt;/div&gt;&lt;!-- SC_ON --&gt;",
          "selftext": "**Message from Graham and Peter: Thanks everyone for all of your great questions. We'll answer some of the pending questions, as of 1pm PT May 16th, but won't be answering new ones.  Thanks!**\n\nWe are the authors, Peter Ralph (/u/petrelharp) and Graham Coop\n(/u/grahamcoop), of a recent paper on\n[The Geography of Recent Genetic Ancestry across Europe](http://www.plosbiology.org/article/info%3Adoi%2F10.1371%2Fjournal.pbio.1001555).\n\nThe article made some news in\n[a](http://www.latimes.com/news/science/la-sci-european-dna-20130508,0,6298389.story)\n[number](http://phenomena.nationalgeographic.com/2013/05/07/charlemagnes-dna-and-our-universal-royalty/)\n[of](http://www.slate.fr/life/72217/ancetres-communs-europeens-moins-de-1000-ans)\n[places](http://www.nature.com/news/most-europeans-share-recent-ancestors-1.12950)\nwith the headline that \"Europeans are all related\".  What does that\nmean? Didn't we already know that?  And how can you show that the\nSpanish and the Polish have the same ancestors only 1,000 years ago,\nbut also see different effects of events from 1,500 years ago in their\ngenomes?  We're ready to talk about genetics, genealogy, and even a\nlittle bit of European history (Although note that we're not historians).\n\nHere's a quick intro; there's more detail [here](http://gcbias.org/european-genealogy-faq/).\n\nFew of us know our family histories more than a few generations back. It is therefore\neasy to overlook the fact that we are all distant cousins, related to\none another via a vast network of relationships. \n\nIn the paper we use\ngenome-wide data from European individuals to investigate these\nrelationships over the past 3,000 years, by looking for long stretches\nof genome that are shared between pairs of individuals through their\ninheritance from common genetic ancestors. We find evidence of\nubiquitous recent common ancestry, showing for instance that even\npairs of individuals from opposite ends of Europe share hundreds of\ngenetic common ancestors over this time period. \n\nSince the vast\nmajority of genealogical ancestors from 1,000 years ago are not\ngenetic ancestors, this implies that all of the Europeans in our\nsample share nearly all of their genealogical ancestors only 1000\nyears ago (albeit to differing extents). Despite this degree of\ncommonality, there are also regional differences. Southeastern\nEuropeans, for example, share relatively more common ancestors that\ndate roughly to the era of the Slavic and Hunnic expansions around\n1,500 years ago, while most common genetic ancestors that Italians\nshare with other populations lived longer than 2,500 years ago. The study of long stretches of shared genetic material promises to uncover\nrich information about many aspects of recent population history.\n\n**Ask us\nanything about our paper!**",
          "likes": null,
          "secure_media": null,
          "saved": false,
          "id": "1ee560",
          "secure_media_embed": {
          },
          "clicked": false,
          "stickied": false,
          "author": "jjberg2",
          "media": null,
          "score": 975,
          "approved_by": null,
          "over_18": false,
          "hidden": false,
          "thumbnail": "",
          "subreddit_id": "t5_2qm4e",
          "edited": 1368736452,
          "link_flair_css_class": "bio",
          "author_flair_css_class": "bio",
          "downs": 461,
          "is_self": true,
          "permalink": "/r/askscience/comments/1ee560/askscience_ama_we_are_the_authors_of_a_recent/",
          "name": "t3_1ee560",
          "created": 1368641184,
          "url": "http://www.reddit.com/r/askscience/comments/1ee560/askscience_ama_we_are_the_authors_of_a_recent/",
          "author_flair_text": "Evolution | Population Genomics | Adaptation | Modeling",
          "title": "AskScience AMA: We are the authors of a recent paper on genetic genealogy and relatedness among the people of Europe. Ask us anything about our paper!",
          "created_utc": 1368637584,
          "link_flair_text": "Biology",
          "ups": 1436,
          "num_comments": 147,
          "num_reports": null,
          "distinguished": null
        }
      },
      {
        "kind": "t3",
        "data": {
          "domain": "self.Genealogy",
          "banned_by": null,
          "media_embed": {
          },
          "subreddit": "Genealogy",
          "selftext_html": "&lt;!-- SC_OFF --&gt;&lt;div class=\"md\"&gt;&lt;p&gt;Hi all. I&amp;#39;m a PhD student in a population genetics lab at UC Davis, and also an &lt;a href=\"/r/genealogy\"&gt;/r/genealogy&lt;/a&gt; lurker.&lt;/p&gt;\n\n&lt;p&gt;One topic studied in my lab is how to use population genomic data to infer distant relationships among individuals, in a similar way to what personal genomic companies like 23andme and AncestryDNA do when they identify possible cousins. &lt;/p&gt;\n\n&lt;p&gt;While I&amp;#39;m not personally involved in this work, my advisor and a former post-doc in the lab just had a paper published today regarding recent common ancestry, and what population genomic data can tell us about genealogical relationships on deeper time scales (i.e. hundreds to thousands of years).&lt;/p&gt;\n\n&lt;p&gt;This may not be typical fare for this subreddit, but I thought you folks might be interested, so here are links to a really fantastic &lt;a href=\"http://phenomena.nationalgeographic.com/2013/05/07/charlemagnes-dna-and-our-universal-royalty/\"&gt;Carl Zimmer article&lt;/a&gt;, &lt;a href=\"http://www.plosbiology.org/article/info%3Adoi%2F10.1371%2Fjournal.pbio.1001555\"&gt;the actual paper at PLoS Biology&lt;/a&gt;, &lt;a href=\"http://www.plosbiology.org/article/info%3Adoi%2F10.1371%2Fjournal.pbio.1001556\"&gt;a PLoS Biology synopsis&lt;/a&gt;, and &lt;a href=\"http://gcbias.org/european-genealogy-faq/\"&gt;an FAQ&lt;/a&gt; written by the authors.&lt;/p&gt;\n&lt;/div&gt;&lt;!-- SC_ON --&gt;",
          "selftext": "Hi all. I'm a PhD student in a population genetics lab at UC Davis, and also an /r/genealogy lurker.\n\nOne topic studied in my lab is how to use population genomic data to infer distant relationships among individuals, in a similar way to what personal genomic companies like 23andme and AncestryDNA do when they identify possible cousins. \n\nWhile I'm not personally involved in this work, my advisor and a former post-doc in the lab just had a paper published today regarding recent common ancestry, and what population genomic data can tell us about genealogical relationships on deeper time scales (i.e. hundreds to thousands of years).\n\nThis may not be typical fare for this subreddit, but I thought you folks might be interested, so here are links to a really fantastic [Carl Zimmer article](http://phenomena.nationalgeographic.com/2013/05/07/charlemagnes-dna-and-our-universal-royalty/), [the actual paper at PLoS Biology](http://www.plosbiology.org/article/info%3Adoi%2F10.1371%2Fjournal.pbio.1001555), [a PLoS Biology synopsis](http://www.plosbiology.org/article/info%3Adoi%2F10.1371%2Fjournal.pbio.1001556), and [an FAQ](http://gcbias.org/european-genealogy-faq/) written by the authors.",
          "likes": null,
          "secure_media": null,
          "saved": false,
          "id": "1dw0uy",
          "secure_media_embed": {
          },
          "clicked": false,
          "stickied": false,
          "author": "jjberg2",
          "media": null,
          "score": 24,
          "approved_by": null,
          "over_18": false,
          "hidden": false,
          "thumbnail": "",
          "subreddit_id": "t5_2qmdf",
          "edited": false,
          "link_flair_css_class": null,
          "author_flair_css_class": null,
          "downs": 2,
          "is_self": true,
          "permalink": "/r/Genealogy/comments/1dw0uy/a_population_genomic_look_at_genealogical/",
          "name": "t3_1dw0uy",
          "created": 1367966500,
          "url": "http://www.reddit.com/r/Genealogy/comments/1dw0uy/a_population_genomic_look_at_genealogical/",
          "author_flair_text": null,
          "title": "A population genomic look at genealogical patterns in Europe",
          "created_utc": 1367962900,
          "link_flair_text": null,
          "ups": 26,
          "num_comments": 6,
          "num_reports": null,
          "distinguished": null
        }
      },
      {
        "kind": "t3",
        "data": {
          "domain": "self.asatru",
          "banned_by": null,
          "media_embed": {
          },
          "subreddit": "asatru",
          "selftext_html": "&lt;!-- SC_OFF --&gt;&lt;div class=\"md\"&gt;&lt;p&gt;...you might be interested in &lt;a href=\"http://phenomena.nationalgeographic.com/2013/05/07/charlemagnes-dna-and-our-universal-royalty/\"&gt;this.  This particular article&lt;/a&gt;  does a lot of derping about some cat named Charlemagne, but the relevant portion for out purposes is here:&lt;/p&gt;\n\n&lt;blockquote&gt;\n&lt;p&gt;Even within the past thousand years, Ralph and Coop found, people on opposite sides of the continent share a lot of segments in common – so many, in fact, that it’s statistically impossible for them to have gotten them all from a single ancestor. Instead, someone in Turkey and someone in England have to share a lot of ancestors. In fact, as Chang suspected, the only way to explain the DNA is to conclude that [every European] who lived a thousand years ago who has any descendants today is an ancestor of every European.&lt;/p&gt;\n&lt;/blockquote&gt;\n\n&lt;p&gt;This arises largely from the fact that if you go back 30 or 40 generations, mathematically you would have orders of magnitude more ancestors than there were people in Europe at the time.  Obviously, you&amp;#39;re looking at a lot of common ancestry at that point.  There&amp;#39;s more to it, but you can find the paper itself &lt;a href=\"http://www.plosbiology.org/article/info%3Adoi%2F10.1371%2Fjournal.pbio.1001555\"&gt;here.&lt;/a&gt;&lt;/p&gt;\n&lt;/div&gt;&lt;!-- SC_ON --&gt;",
          "selftext": "...you might be interested in [this.  This particular article](http://phenomena.nationalgeographic.com/2013/05/07/charlemagnes-dna-and-our-universal-royalty/)  does a lot of derping about some cat named Charlemagne, but the relevant portion for out purposes is here:\n\n&gt;Even within the past thousand years, Ralph and Coop found, people on opposite sides of the continent share a lot of segments in common – so many, in fact, that it’s statistically impossible for them to have gotten them all from a single ancestor. Instead, someone in Turkey and someone in England have to share a lot of ancestors. In fact, as Chang suspected, the only way to explain the DNA is to conclude that [every European] who lived a thousand years ago who has any descendants today is an ancestor of every European.\n\nThis arises largely from the fact that if you go back 30 or 40 generations, mathematically you would have orders of magnitude more ancestors than there were people in Europe at the time.  Obviously, you're looking at a lot of common ancestry at that point.  There's more to it, but you can find the paper itself [here.](http://www.plosbiology.org/article/info%3Adoi%2F10.1371%2Fjournal.pbio.1001555)",
          "likes": null,
          "secure_media": null,
          "saved": false,
          "id": "1guo7v",
          "secure_media_embed": {
          },
          "clicked": false,
          "stickied": false,
          "author": "YetAnotherBadAlias",
          "media": null,
          "score": 14,
          "approved_by": null,
          "over_18": false,
          "hidden": false,
          "thumbnail": "self",
          "subreddit_id": "t5_2r5lh",
          "edited": false,
          "link_flair_css_class": null,
          "author_flair_css_class": null,
          "downs": 2,
          "is_self": true,
          "permalink": "/r/asatru/comments/1guo7v/if_youve_ever_wondered_whether_you_have_viking/",
          "name": "t3_1guo7v",
          "created": 1371904975,
          "url": "http://www.reddit.com/r/asatru/comments/1guo7v/if_youve_ever_wondered_whether_you_have_viking/",
          "author_flair_text": null,
          "title": "If you've ever wondered whether you have viking ancestors...",
          "created_utc": 1371901375,
          "link_flair_text": null,
          "ups": 16,
          "num_comments": 5,
          "num_reports": null,
          "distinguished": null
        }
      }
    ],
    "after": null,
    "before": null
  }
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/reddit.rb).

## Further Documentation
* [Reddit API Documentation](http://www.reddit.com/dev/api)
