---
layout: card
title: "Agents"
---

The Lagotto software includes a number of agents. Most agents require a user account with the service. Agents collect information about works, contributors, publishers, and their relations to each other.

### Sources

In previous versions of the Lagotto software `agents` were called `sources`. Starting with version 5.0, `agents` collect information that is then stored in `sources`.

### Groups

Agents and sources are grouped based on what they add via the deposits API:

* relations
* results (relations where the subject is not specific, e.g. download counts)
* contributions
* publishers

### Relations
* [Twitter](/docs/twitter_search)
* [Nature Blogs](/docs/nature)
* [Research Blogging](/docs/researchblogging)
* [ScienceSeeker](/docs/scienceseeker)
* [Wordpress.com](/docs/wordpress)
* [Wikipedia](/docs/wikipedia)
* [Reddit](/docs/reddit)
* [OpenEdition](/docs/openedition)
* [CiteULike](/docs/citeulike)
* [CrossRef](/docs/crossref)
* [PubMed Central Citations](/docs/pubmed)
* [Europe PMC Citations](/docs/pmceurope)
* [DataCite](/docs/datacite)
* [Europe PMC Database Citations](/docs/pmceuropedata)
* [F1000Prime](/docs/f1000)
* [PLOS Comments](/docs/plos_comments)

### Results
* [PubMed Central Usage Stats](/docs/pmc)
* [Copernicus](/docs/copernicus)
* [Facebook](/docs/facebook)
* [Mendeley](/docs/mendeley)
* [Scopus](/docs/scopus)
* [Web of Science](/docs/wos)
* [PLOS Usage Stats](/docs/counter)
* [PLOS Figshare Usage Stats](/docs/figshare)

### Retired
* [Biod](/docs/biod)
* [Bloglines](/docs/bloglines)
* [Connotea](/docs/connotea)
* [Postgenomic](/docs/postgenomic)

Please use the [Issue Tracker](https://github.com/lagotto/lagotto/issues) for questions or feedback regarding agents.

## Creating a new agent
Basically, each of the APIs that Lagotto is calling will be defined as an **agent**. Lagotto provides a number of services to each agent to help it get what it needs. Note the samples provided at [http://github.com/lagotto/lagotto/tree/master/app/models/agents](http://github.com/lagotto/lagotto/tree/master/app/models/agents).
