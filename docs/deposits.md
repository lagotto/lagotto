---
layout: card
title: Deposits API
---

The deposits API provides a common way to import data into Lagotto. It was introduced in Lagotto 5.0. Import of data via rake task, as in previous Lagotto versions, is no longer supported in Lagotto 5.0.

## Message envelope

* message action
* message type
* source_token
* API key

### Message action

Either `create` (default) or `update`. The `create` action does an update if the

### Message type

Describes target for the deposit, either `relation`, `contribution` or `publisher`. Defaults to `relation`.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=25%><strong>Message type</strong></td>
<td valign="top" width=25%><strong>Message action</strong></td>
<td valign="top" width=50%><strong>Description</strong></td>
</tr>
<tr>
<td valign="top" width=25%>relation</td>
<td valign="top" width=25%>create</td>
<td valign="top" width=50%>Add or update relation</td>
</tr>
<tr>
<td valign="top" width=25%>relation</td>
<td valign="top" width=25%>delete</td>
<td valign="top" width=50%>Delete relation</td>
</tr>
<tr>
<td valign="top" width=25%>contribution</td>
<td valign="top" width=25%>create</td>
<td valign="top" width=50%>Add or update contribution</td>
</tr>
<tr>
<td valign="top" width=25%>contribution</td>
<td valign="top" width=25%>delete</td>
<td valign="top" width=50%>Delete contribution</td>
</tr>
<tr>
<td valign="top" width=25%>publisher</td>
<td valign="top" width=25%>create</td>
<td valign="top" width=50%>Add or update publisher</td>
</tr>
<tr>
<td valign="top" width=25%>publisher</td>
<td valign="top" width=25%>delete</td>
<td valign="top" width=50%>Delete publisher</td>
</tr>
</tbody>
</table>

### Source token

Unique identifier (usually a UUID) for the agent responsible for the deposit. Required.

### API key

A valid Lagotto API key – associated with a `contributor` or `admin` role – is required. The API key is used as for other API calls: in the header using the format `Authorization: Token token=API_KEY`.

## Message body

### Required attributes

* subj_id
* source_id

`subj_id` is a persistent identifier in one of the formats Lagotto understands, e.g. a DOI expressed as URL: `http://doi.org/10.15468/DL.CBBVCT`.

`source_id` is the ID of one of the sources activated in the Lagotto instance, e.g. `facebook` or `datacite_github`, and can be retrieved via [API call](/api/sources).

These additional attributes are required for message type `relation`:

* obj_id
* relation_type_id

`obj_id` is in the same format as `subj_id`.

`relation_type_id` is the ID of one of relation_types supported by the Lagotto application, e.g. `cites`. The list of supported relation types is based on the DataCite Metadata Schema, and can be retrieved via [API call](/api/relation_types).

### Optional attributes

* subj
* obj
* publisher_id
* total
* occurred_at

`subj` provides metadata for `subj_id`, in the same format also used in the rest of the Lagotto API, and based on [Citation Style Language](http://citationstyles.org/).

`obj` uses the same format as `subj`.

`publisher_id` is the ID of one of the publishers activated in the Lagotto instance, and can be retrieved via [API call](/api/publishers). Use this attribute to describe the provenance of a `relation`.

`total` is the number of results associated with a relation. Defaults to `1`.

`occurred_at` describes the date and time when a relation was described.

## Examples

### relation/create

```sh
{
  "message_type": "relation",
  "message_action": "create",
  "source_token": "ddf4f2ef-9b90-43ae-9ae5-2ac85cf50b3d",
  "prefix": "10.15468",
  "subj_id": "http://doi.org/10.15468/DL.CBBVCT",
  "obj_id": "http://doi.org/10.15468/EAQV44",
  "relation_type_id": "references",
  "source_id": "datacite_related",
  "publisher_id": "DK.GBIF",
  "occurred_at": "2016-04-09T22:29:07Z",
  "subj": {
    "pid": "http://doi.org/10.15468/DL.CBBVCT",
    "DOI": "10.15468/DL.CBBVCT",
    "author": [
      {
        "family": "gbif.org"
      }
    ],
    "title": "GBIF Occurrence Download",
    "container-title": "The Global Biodiversity Information Facility",
    "issued": "2015",
    "publisher_id": "DK.GBIF",
    "registration_agency": "datacite",
    "tracked": true,
    "type": "dataset"
  },
  "obj": {
  }
}
```

### publisher/create

```sh
{
  "source_token": "492d8924-05ae-4d18-8c85-a02fa8fe873d",
  "subj_id": "2436",
  "source_id": "crossref_publisher",
  "subj": {
    "name": "2436",
    "title": "Korean Society for Microbiology and Biotechnology",
    "other_names": [
      "Korean Society for Microbiology and Biotechnology"
    ],
    "prefixes": [
      "10.4014"
    ],
    "issued": "2016-04-08T05:03:17Z",
    "registration_agency": "crossref",
    "active": true
  },
  "obj": {
  }
}
```

