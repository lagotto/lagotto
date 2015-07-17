---
layout: card
title: "DataCONE Counter"
---

[DataONE](http://www.dataone.org) is a network of repositories for ecological and environmental data. The DataONE Counter source tracks the number of downloads of these datasets, and implements the recommendations from the [COUNTER code of practice](http://www.projectcounter.org/r4/APPD.pdf).

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>Lagotto Name</strong></td>
<td valign="top" width=70%>dataone_counter</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Lagotto Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Lagotto Core Attributes</strong></td>
<td valign="top" width=80%>total</td>
</tr>
<td valign="top" width=20%><strong>Lagotto Other Attributes</strong></td>
<td valign="top" width=80%>none</td>
</tr>
<tr>
<td valign="top" width=30%><strong>Protocol</strong></td>
<td valign="top" width=70%>REST</td>
</tr>
<tr>
<td valign="top" width=30%><strong>Format</strong></td>
<td valign="top" width=70%>JSON or XML</td>
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
<td valign="top" width=80%>https://cn.dataone.org/cn/v1/query/logsolr/select?facet=true&facet.range=dateLogged&facet.range.end=2015-07-17T23:59:59Z&facet.range.gap=%2B1MONTH&facet.range.start=2011-07-07T00:00:00Z&fq=event:read&q=pid:PID%20AND%20isRepeatVisit:false%20AND%20inFullRobotList:false&wt=json</td>
</tr>
</tbody>
</table>

## Example Response

```json
{
  "responseHeader": {
    "status": 0,
    "QTime": 828,
    "params": {
      "facet": "true",
      "q": "pid:doi\\:10.5063/F1PC3085",
      "facet.range.start": "2014-09-01T01:01:01Z",
      "facet.range": "dateLogged",
      "facet.range.gap": "+1MONTH",
      "facet.range.end": "2015-07-17T24:59:59Z",
      "wt": "json",
      "fq": "event:read"
    }
  },
  "response": {
    "numFound": 74,
    "start": 0,
    "docs": [
    ]
  },
  "facet_counts": {
    "facet_queries": {
    },
    "facet_fields": {
    },
    "facet_dates": {
    },
    "facet_ranges": {
      "dateLogged": {
        "counts": [
          "2014-09-01T01:01:01Z",
          13,
          "2014-10-01T01:01:01Z",
          20,
          "2014-11-01T01:01:01Z",
          10,
          "2014-12-01T01:01:01Z",
          4,
          "2015-01-01T01:01:01Z",
          12,
          "2015-02-01T01:01:01Z",
          5,
          "2015-03-01T01:01:01Z",
          4,
          "2015-04-01T01:01:01Z",
          4,
          "2015-05-01T01:01:01Z",
          2,
          "2015-06-01T01:01:01Z",
          0,
          "2015-07-01T01:01:01Z",
          0
        ],
        "gap": "+1MONTH",
        "start": "2014-09-01T01:01:01Z",
        "end": "2015-08-01T01:01:01Z"
      }
    }
  }
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/dataone_counter.rb).

## Further Documentation
* [DataONE usage stats](http://articlemetrics.github.io/MDC/dataone-usage-stats/)
