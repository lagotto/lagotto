---
layout: card_list
title: "Roadmap"
---

## 4.3 Archiving and Auditing of Raw Data (July 2015)

We want to make all data collected by Lagotto available publicly. While monthly reports can be generated as CSV files and [uploaded to a data repository such as figshare](http://figshare.com/articles/Cumulative_PLOS_ALM_Report_February_2014/1189396), we need a different mechanism to include the raw data collected from external sources. A database is not the best place for this kind of data and we need to look at other services to handle this, e.g. [fluentd](http://www.fluentd.org/) and [Amazon Glacier](http://aws.amazon.com/glacier/).

After this release we will have the following export formats:

* API (currently at version 6)
* monthly export of summary stats in CSV format
* monthly export of detailed data in JSON format

## 4.4 Data-Push Model (August 2015)

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

All API responses from external sources should go through the new push API to make the workflow consistent. We can modify the [perform_get_data method](https://github.com/lagotto/lagotto/blob/master/app/models/event.rb#L41-L46) to achieve this.

### Rewrite F1000 source as internal agent

Once we have separated out the agent functionality from sources in we can start rewriting our existing sources to more efficiently collect events from external sources. The [F1000 source](https://github.com/lagotto/lagotto/blob/master/app/models/sources/f1000.rb) is a good starting point, and the new agent should parse the F1000 XML file and then deposit the payload in the new push API. We can consider packaging the internal agent as Ruby gem if the functionality is decoupled enough.

### Add generic webmention endpoint

Use the [standard webmention format](http://webmention.io/), feed in data around events.
