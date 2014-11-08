---
layout: card
title: "Europe PubMed Central Database Links"
---

Europe PubMed Central ([Europe PMC](http://europepmc.org/)) is an archive of life sciences journal literature. Europe PubMed Central tracks the database entries that cite a given publication.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=20%><strong>ALM Name</strong></td>
<td valign="top" width=80%>pmceurope</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>count</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>database name</td>
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
<td valign="top" width=80%>http://www.ebi.ac.uk/europepmc/webservices/rest/MED/PMID/databaseLinks//1/json</td>
</tr>
</tbody>
</table>

## Example

```json
{
  "version": "3.0.1",
  "hitCount": 21710,
  "request": {
    "id": "14624247",
    "source": "MED",
    "page": 1,
    "database": ""
  },
  "dbCountList": {
    "db": [
      {
        "dbName": "EMBL",
        "count": 10
      },
      {
        "dbName": "UNIPROT",
        "count": 21700
      }
    ]
  },
  "dbCrossReferenceList": {
    "dbCrossReference": [
      {
        "dbName": "EMBL",
        "dbCount": 10,
        "dbCrossReferenceInfo": [
          {
            "info1": "CAAC03002334",
            "info2": "Caenorhabditis briggsae AF16 WGS project CAAC03000000 data, contig c006500825.Contig1",
            "info3": "12075",
            "info4": "5986"
          },
          {
            "info1": "CAAC03000373",
            "info2": "Caenorhabditis briggsae AF16 WGS project CAAC03000000 data, contig c005201237.Contig1",
            "info3": "1058",
            "info4": "5986"
          },
          {
            "info1": "CAAC03004734",
            "info2": "Caenorhabditis briggsae AF16 WGS project CAAC03000000 data, contig c009200843.Contig2",
            "info3": "13671",
            "info4": "5986"
          },
          {
            "info1": "CAAC03002721",
            "info2": "Caenorhabditis briggsae AF16 WGS project CAAC03000000 data, contig c012100886.Contig2",
            "info3": "21731",
            "info4": "5986"
          },
          {
            "info1": "CAAC03002803",
            "info2": "Caenorhabditis briggsae AF16 WGS project CAAC03000000 data, contig c014200791.Contig3",
            "info3": "71933",
            "info4": "5986"
          },
          {
            "info1": "CAAC03004802",
            "info2": "Caenorhabditis briggsae AF16 WGS project CAAC03000000 data, contig c011201737.Contig1",
            "info3": "53037",
            "info4": "5986"
          },
          {
            "info1": "CAAC03002909",
            "info2": "Caenorhabditis briggsae AF16 WGS project CAAC03000000 data, contig c001100957.Contig4",
            "info3": "9402",
            "info4": "5986"
          },
          {
            "info1": "CAAC03005031",
            "info2": "Caenorhabditis briggsae AF16 WGS project CAAC03000000 data, contig c011500956.Contig1",
            "info3": "1982",
            "info4": "5986"
          },
          {
            "info1": "CAAC03005104",
            "info2": "Caenorhabditis briggsae AF16 WGS project CAAC03000000 data, contig c006201238.Contig1",
            "info3": "2545",
            "info4": "5986"
          },
          {
            "info1": "CAAC03001174",
            "info2": "Caenorhabditis briggsae AF16 WGS project CAAC03000000 data, contig c004001611.Contig1",
            "info3": "36929",
            "info4": "5986"
          }
        ]
      },
      {
        "dbName": "UNIPROT",
        "dbCount": 21700,
        "dbCrossReferenceInfo": [
          {
            "info1": "Q04456",
            "info2": "Gut esterase 1",
            "info3": "Caenorhabditis briggsae",
            "info4": "UniProt"
          },
          {
            "info1": "Q61C05",
            "info2": "CTD nuclear envelope phosphatase 1 homolog",
            "info3": "Caenorhabditis briggsae",
            "info4": "UniProt"
          },
          {
            "info1": "A8WYI3",
            "info2": "Protein CBG04805",
            "info3": "Caenorhabditis briggsae",
            "info4": "UniProt"
          },
          {
            "info1": "A8WYI9",
            "info2": "Protein CBG04811",
            "info3": "Caenorhabditis briggsae",
            "info4": "UniProt"
          },
          {
            "info1": "A8WYJ8",
            "info2": "Protein CBG04821",
            "info3": "Caenorhabditis briggsae",
            "info4": "UniProt"
          },
          {
            "info1": "A8WYK6",
            "info2": "Protein CBG04829",
            "info3": "Caenorhabditis briggsae",
            "info4": "UniProt"
          },
          {
            "info1": "A8WYL0",
            "info2": "Protein CBG04834",
            "info3": "Caenorhabditis briggsae",
            "info4": "UniProt"
          },
          {
            "info1": "A8WYL3",
            "info2": "Protein CBG04839",
            "info3": "Caenorhabditis briggsae",
            "info4": "UniProt"
          },
          {
            "info1": "A8WYM7",
            "info2": "Protein CBG04855",
            "info3": "Caenorhabditis briggsae",
            "info4": "UniProt"
          },
          {
            "info1": "A8WYP2",
            "info2": "Protein CBG04872",
            "info3": "Caenorhabditis briggsae",
            "info4": "UniProt"
          },
          {
            "info1": "A8WYP9",
            "info2": "Protein CBG04880",
            "info3": "Caenorhabditis briggsae",
            "info4": "UniProt"
          },
          {
            "info1": "A8WYR4",
            "info2": "Protein CBG04898",
            "info3": "Caenorhabditis briggsae",
            "info4": "UniProt"
          },
          {
            "info1": "A8WYS0",
            "info2": "Protein CBG04905",
            "info3": "Caenorhabditis briggsae",
            "info4": "UniProt"
          },
          {
            "info1": "A8WSU0",
            "info2": "Protein CBG03086",
            "info3": "Caenorhabditis briggsae",
            "info4": "UniProt"
          },
          {
            "info1": "A8WSU3",
            "info2": "Protein CBG03082",
            "info3": "Caenorhabditis briggsae",
            "info4": "UniProt"
          }
        ]
      }
    ]
  }
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/pmc_europe_data.rb).

## API Documentation
* [PMC Europe RESTful Web Service](http://europepmc.org/RestfulWebService)
