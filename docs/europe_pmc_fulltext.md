---
layout: card
title: "Europe PMC Fulltext"
---

Search the Europe PMC fulltext corpus for scholarly works.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>europe_pmc_fulltext</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>&nbsp;</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>&nbsp;</td>
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
<td valign="top" width=80%>no</td>
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
<td valign="top" width=80%>http://www.ebi.ac.uk/europepmc/webservices/rest/search/query="DOI"+OR+"URL"&dataset=fulltext&format=json&resultType=lite</td>
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
  "version": "3.0.1",
  "hitCount": 13,
  "request": {
    "dataSet": "fulltext",
    "resultType": "lite",
    "synonym": true,
    "query": "\"https://github.com/lh3/seqtk\"",
    "page": 1
  },
  "resultList": {
    "result": [
      {
        "id": "25104065",
        "source": "MED",
        "pmid": "25104065",
        "pmcid": "PMC4125989",
        "title": "Genetic evidence of African slavery at the beginning of the trans-Atlantic slave trade.",
        "authorString": "Martiniano R, Coelho C, Ferreira MT, Neves MJ, Pinhasi R, Bradley DG.",
        "journalTitle": "Sci Rep",
        "journalVolume": "4",
        "pubYear": "2014",
        "journalIssn": "2045-2322",
        "pageInfo": "5994",
        "pubType": "journal article; research support, non-u.s. gov't",
        "isOpenAccess": "Y",
        "inEPMC": "Y",
        "inPMC": "Y",
        "citedByCount": 0,
        "hasReferences": "Y",
        "hasTextMinedTerms": "Y",
        "hasDbCrossReferences": "N",
        "hasLabsLinks": "N",
        "hasTMAccessionNumbers": "N",
        "luceneScore": "140.30156",
        "doi": "10.1038/srep05994"
      }
    ]
  }
}

```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/europe_pmc_fulltext.rb).

## Further Documentation
* [Europe PMC RESTful Web Service](http://europepmc.org/RestfulWebService)
