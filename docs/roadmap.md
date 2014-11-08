---
layout: card_list
title: "Roadmap"
---

## 4.0 Data-Push Model (November 2014)

In order for the Lagotto application to scale to millions of articles - e.g. the more than 10 million in the [CrossRef Labs DET Server](http://det.labs.crossref.org/) - it makes more sense that third-parties are pushing data into the application (**push**) rather than Lagotto collecting data from external sources (**pull**). We have identified the following architecture and implementation steps:

### Add push API endpoint

Add an API that takes push requests in a standardized format that describe events around articles. The API has the following features:

* HTTP REST (POST and possibly GET)
* allow to push events for a single or multiple articles
* include at least the following information in the payload: article ID (DOI), source, timestamp, event information, depending on source (e.g. event_count, event_url, information about individual events)
* authentication via API token

### Separate out agent functionality from source model

We want to separate out the agent functionality from our sources, so that agents can be part of the Lagotto software, or run somewhere else and deposit their data via the new push API. Sources should become generic enough that we hopefully don't need to subclass the Source class anymore, but move all that functionality into a new **Agent** model. In the beginning all sources will have a corresponding agent, but that can change over time.

### Push all API responses through push API

All API responses from external sources should go through the new push API to make the workflow consistent. We can modify the [perform_get_data method](https://github.com/articlemetrics/lagotto/blob/master/app/models/retrieval_status.rb#L41-L46) to achieve this.

### Rewrite F1000 source as internal agent

Once we have separated out the agent functionality from sources in we can start rewriting our existing sources to more efficiently collect events from external sources. The [F1000 source](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/f1000.rb) is a good starting point, and the new agent should parse the F1000 XML file and then deposit the payload in the new push API. We can consider packaging the internal agent as Ruby gem if the functionality is decoupled enough.

### Add generic webmention endpoint

Use the [standard webmention format](http://webmention.io/), feed in data around events.

## 4.1 Data-Level Metrics (December 2014)

To fully support data-level metrics, the following changes need to be done in the Lagotto software:

* renaming of pages that use article-specific language
* support for any unique identifier, and for different unique identiifiers in the same database
* support for relationships between resources (*isNewVersionOf*, *isPartOf*, etc.)
* support for resource type (e.g. DataCite *resourceTypeGeneral*: *dataset*, *software*, *text*)
* support for (some of) the functionality we have in the CrossRef integration (e.g. resources by publisher, automatic import)
* configuration changes to some sources, e.g. Europe PMC database links
* additional sources (e.g. usage stats for data)

### Support for any unique identifier

Lagotto supports multiple identifiers, but all resources in the service have to use the same identifier, e.g. DOI or PMCID. For datasets we need more generic functionality: a standardized identifier for all records to allow listing of resources and opening up a page for a resource. We can use URLs for this, and keep the support for multiple identifiers per resource that we have now.

### Support for relationships between resources

This is an important feature for data because of versioning and subsets of data (*isPartOf*). This functionality is also needed for journal articles, allowing us to describe the relationship between different versions of an article, and related content such as corrections, as well as component DOIs for figures and tables.

### Automatic import of dataset metadata

There are several options, ideally this should use a standard protocol and allow the bulk import of data.

### Rename articles to works

We want to make the software more flexible in that we should be able to track all scholarly outputs including datasets. We should therefore rename the **Article** model to **Work**, and use **works** in the web interface and API. Only [75% of CrossRef DOIs are of type *journal-article*](http://search.crossref.org/help/status), and they also use the term *works* in their API.

## 4.2 Server-to-Server Replication (January 2015)

As the number of Lagotto installations increases, we need to start thinking about server-to-server replication, so that multiple Lagotto servers are not all collecting the same information from external data sources.

To make this replication performant, we ideally want to use a native database replication tool. Part of the implementation should therefore be a re-evaluation of MySQL and CouchDB as databases used in Lagotto.

## 4.3 Archiving and Auditing of Raw Data (February 2015)

We want to make all data collected by Lagotto available publicly. While monthly reports can be generated as CSV files and [uploaded to a data repository such as figshare](http://figshare.com/articles/Cumulative_PLOS_ALM_Report_February_2014/1189396), we need a different mechanism to include the raw data collected from external sources. A database is not the best place for this kind of data and we need to look at other services to handle this, e.g. [fluentd](http://www.fluentd.org/) and [Amazon Glacier](http://aws.amazon.com/glacier/).
