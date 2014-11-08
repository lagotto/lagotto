---
layout: home
title: "Home"
---

## Article-Level Metrics

Traditionally, the impact of research articles has been measured by the publication journal. But a more informative view is one that examines the overall performance and reach of the articles themselves. Article-Level Metrics (ALM) capture the manifold ways in which research is disseminated and used, including:

* viewed
* shared
* discussed
* cited
* recommended.

Each of the metrics fall under one of these activities. But as an entire set, they paint a comprehensive portrait of the overall footprint of how the scholarly and public are engaging with the research.

![Usage](/images/usage.png)

*From: Fenner M, Lin J (2013). Altmetrics in Evolution: Defining & Redefining the Ontology of Article-Level Metrics. [http://dx.doi.org/10.3789/isqv25no2.2013.04](http://dx.doi.org/10.3789/isqv25no2.2013.04).*

ALM offer a dynamic and real-time view of the latest activity. Researchers can stay up-to-date with their published work and share information about the impact of their publications with collaborators, funders, institutions, and the research community at large. These metrics are also a powerful way to navigate and discover others’ work. They can be customized based on the unique needs of researchers, publishers, institutional decision-makers, and funders.

## Lagotto

The Lagotto application collects and aggregates the data from external sources where article activity is occurring. It was started in March 2009 by the Open Access publisher [Public Library of Science (PLOS)](http://www.plos.org/). To date, the community of [contributors to the application](/docs/contributors) has rapidly grown as more publishers and other providers are implementing the system.

The application retrieves data from a wide set of services ([sources](/docs/sources)). Some of these sources represent the actual channels where users are directly viewing, sharing, discussing, citing, recommending the articles (e.g., Twitter and Mendeley). Others are third-party vendors which provide this information (e.g., CrossRef for citations). All data is fetched via an API from the sources. Each source has a unique set of specifications for query volume, frequency, and speed. In order to ensure that the metrics reflect the latest activity, we queue each article for every source to be refreshed based upon its publication date and the upper thresholds for each source. The system then programmatically harvests data for each article and each source at its appointed time.

The platform contains a default set of public sources, available for all with a user account. Publishers and providers have also implemented additional private sources either because the sources either use an internal application, which is not available via public API (journal usage stats, figshare usage, journal comments, etc.) or require a contract with the provider (Scopus, Web of Science, F1000). Additional sources (public or private) can be easily configured to extend the collection of article activity.

Lagotto automatically monitors the harvest of successfully returned data, query errors, elevated counts that are flagged as suspicious. The system surfaces potential issues for investigation on the administrative dashboard as well as through email notifications. It also contains a basic set of reporting tools for article statistics, source status, errors, etc.

The following organizations are using Lagotto:

* [Public Library of Science (PLOS)](http://article-level-metrics.plos.org/)
* [Copernicus Publications](http://publications.copernicus.org/services/article_level_metrics.html)
* [Public Knowledge Project (PKP)](http://pkp.sfu.ca/pkp-launches-article-level-metrics-for-ojs-journals/)
* [CrossRef Labs](http://crosstech.crossref.org/2014/02/many-metrics-such-data-wow.html)
* [eLife](http://lagotto.svr.elifesciences.org/)
* [Pensoft](http://alm.pensoft.net:81/)

Live status information for the publicly available Lagotto instances is [here](http://articlemetrics.github.io/status/).

## For Publishers and Providers
To facilitate the dissemination of Article-Level Metrics, PLOS has made this application available as Open Source software under a [MIT License](https://github.com/articlemetrics/lagotto/blob/master/LICENSE.md). Detailed instructions on how to [install](/docs/installation) and [setup](/docs/setup) Lagotto are available in the documentation, and the installation and setup can be done in under an hour.

## For Users
As a user you will typically see Article-Level Metrics displayed on journal pages or in specialized web applications. You can sign up with your [Mozilla Persona](http://www.mozilla.org/en-US/persona/) account here if you want direct access to the underlying data - this will give you an API key for [API access](/docs/api) and will alert you when the monthly summary stats are available for download. The online documentation gives detailed instructions on how data from external [sources](/docs/sources) are collected.

## For Developers
We always welcome feedback and code contributions, and we have a growing list of [contributors](/docs/contributors). For questions or comments regarding Lagotto, visit the [Lagotto support forum](http://discuss.lagotto.io) or use the [Github issue tracker](https://github.com/articlemetrics/lagotto/issues).
