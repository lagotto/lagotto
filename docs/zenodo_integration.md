---
layout: card
title: "Zenodo"
---

Lagotto currently integrates with [Zenodo](http://www.zenodo.org) to upload monthly summary reports as well as API snapshots. This document describes building onto this integration in order to add additional files to Zenodo.

This document is targeted at developers or those interested in adding to the Zenodo integration.

### Exporting generic data to Zenodo with ZenodoDataExport

There is a `ZenodoDataExport` model which represents a grouping of files that are to be uploaded to Zenodo as a single [deposition](https://zenodo.org/dev#restapi-res-dep).

Here's an example pulled from `lib/tasks/report.rake`:

```
data_export = ZenodoDataExport.create!(
  name: "alm_combined_stats_report",
  files: [alm_combined_stats_zip_record.filepath],
  publication_date: publication_date,
  title: title,
  description: description,
  creators: [ ENV['CREATOR'] ],
  keywords: ZENODO_KEYWORDS,
  code_repository_url: ENV["GITHUB_URL"]
)

DataExportJob.perform_later(id: data_export.id)
```

There are two steps involved with uploading data to Zenodo:

* First, create the `ZenodoDataExport` which adds a record the `data_exports` table in the Lagotto database. _This will not perform the upload._
* Next, create a `DataExportJob` for the newly created ZenodoDataExport which will handle uploading the data to Zenodo in the background.

This is all there is to exporting new kinds of data to Zenodo: make sure the file(s) exist locally, create a `ZenodoDataExport`, and queue up a `DataExportJob`.

_Note: The `DataExportJob` that runs in the background requires that Redis and Sidekiq are both running. If they are not running then the upload to Zenodo will not start._


#### ZenodoDataExport Attributes

There are a number of attributes you can use to specify what information the resulting Zenodo deposition should have.

Let's take a moment to briefly walk thru the attributes from the above example:

* **name**: this is the internal name of the export used by Lagotto. It is not used to generate data for Zenodo, only so that you or another developer or sysadmin can make sense of the export. For example, there are many monthly reports and the name field is used to indicate the specific report this data export is for.

* **files**: a list of filepaths that exist on the local system that are to be uploaded to Zenodo. These will show up as individual [ files](https://zenodo.org/dev#restapi-res-files) on the deposition.

* **publication_date**: the publication_date to use for the Zenodo deposition

* **title**: the title to use for the Zenodo deposition

* **description**: the description to use for the Zenodo deposition

* **creators**: an array of names to be used as the creators for the Zenodo deposition

* **keywords**: the keywords to associate with the Zenodo deposition (used for searching in Zenodo)

* **code_repository_url**: the URL that is associated with the code-base that generated this data export. E.g. the Lagotto Github URL.

* **url**: this is set after the upload to Zenodo is complete. It will be the publicly accessible URL of the deposition on Zenodo.

#### When something goes wrong

If something goes wrong with the upload the following things will happen:

* the `failed_at` timestamp will be set on the ZenodoDataExport record
* an `Alert` record will be created which contains backtrace of any exceptions that have occurred
