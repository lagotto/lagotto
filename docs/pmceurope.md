---
layout: card
title: "Europe PubMed Central"
---

Europe PubMed Central ([Europe PMC](http://europepmc.org/)) is an archive of life sciences journal literature. Europe PubMed Central tracks the citations for a given publication.

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
<td valign="top" width=80%>none</td>
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
<td valign="top" width=80%>http://www.ebi.ac.uk/europepmc/webservices/rest/MED/PMID/citations/1/json</td>
</tr>
</tbody>
</table>

## Example

```json
{
  "version": "3.0.1",
  "hitCount": 23,
  "request": {
    "id": "17183631",
    "source": "MED",
    "page": 1
  },
  "citationList": {
    "citation": [
      {
        "id": "19749171",
        "source": "MED",
        "title": "The transient receptor potential vanilloid-1 channel in thermoregulation: a thermosensor it is not.",
        "authorString": "Romanovsky AA, Almeida MC, Garami A, Steiner AA, Norman MH, Morrison SF, Nakamura K, Burmeister JJ, Nucci TB.",
        "journalAbbreviation": "Pharmacol. Rev.",
        "pubYear": 2009,
        "volume": "61",
        "issue": "3",
        "pageInfo": "228-261",
        "citedByCount": 31
      },
      {
        "id": "19776281",
        "source": "MED",
        "title": "Parallel preoptic pathways for thermoregulation.",
        "authorString": "Yoshida K, Li X, Cano G, Lazarus M, Saper CB.",
        "journalAbbreviation": "J. Neurosci.",
        "pubYear": 2009,
        "volume": "29",
        "issue": "38",
        "pageInfo": "11954-11964",
        "citedByCount": 26
      },
      {
        "id": "19308318",
        "source": "MED",
        "title": "A dynamic reinfection hypothesis of latent tuberculosis infection.",
        "authorString": "Cardona PJ.",
        "journalAbbreviation": "Infection",
        "pubYear": 2009,
        "volume": "37",
        "issue": "2",
        "pageInfo": "80-86",
        "citedByCount": 23
      },
      {
        "id": "21196160",
        "source": "MED",
        "title": "Central neural pathways for thermoregulation.",
        "authorString": "Morrison SF, Nakamura K.",
        "journalAbbreviation": "Front Biosci (Landmark Ed)",
        "pubYear": 2011,
        "volume": "16",
        "pageInfo": "74-104",
        "citedByCount": 22
      },
      {
        "id": "20107070",
        "source": "MED",
        "title": "Contributions of different modes of TRPV1 activation to TRPV1 antagonist-induced hyperthermia.",
        "authorString": "Garami A, Shimansky YP, Pakai E, Oliveira DL, Gavva NR, Romanovsky AA.",
        "journalAbbreviation": "J. Neurosci.",
        "pubYear": 2010,
        "volume": "30",
        "issue": "4",
        "pageInfo": "1435-1440",
        "citedByCount": 19
      },
      {
        "id": "17275915",
        "source": "MED",
        "title": "Leptin: at the crossroads of energy balance and systemic inflammation.",
        "authorString": "Steiner AA, Romanovsky AA.",
        "journalAbbreviation": "Prog. Lipid Res.",
        "pubYear": 2007,
        "volume": "46",
        "issue": "2",
        "pageInfo": "89-107",
        "citedByCount": 16
      },
      {
        "id": "21270352",
        "source": "MED",
        "title": "2010 Carl Ludwig Distinguished Lectureship of the APS Neural Control and Autonomic Regulation Section: Central neural pathways for thermoregulatory cold defense.",
        "authorString": "Morrison SF.",
        "journalAbbreviation": "J. Appl. Physiol.",
        "pubYear": 2011,
        "volume": "110",
        "issue": "5",
        "pageInfo": "1137-1149",
        "citedByCount": 14
      },
      {
        "id": "21116297",
        "source": "MED",
        "title": "Stress responses: the contribution of prostaglandin E(2) and its receptors.",
        "authorString": "Furuyashiki T, Narumiya S.",
        "journalAbbreviation": "Nat Rev Endocrinol",
        "pubYear": 2011,
        "volume": "7",
        "issue": "3",
        "pageInfo": "163-175",
        "citedByCount": 10
      },
      {
        "id": "17927775",
        "source": "MED",
        "title": "Stress- and lipopolysaccharide-induced c-fos expression and nNOS in hypothalamic neurons projecting to medullary raphe in rats: a triple immunofluorescent labeling study.",
        "authorString": "Sarkar S, Zaretskaia MV, Zaretsky DV, Moreno M, DiMicco JA.",
        "journalAbbreviation": "Eur. J. Neurosci.",
        "pubYear": 2007,
        "volume": "26",
        "issue": "8",
        "pageInfo": "2228-2238",
        "citedByCount": 7
      },
      {
        "id": "19949811",
        "source": "MED",
        "title": "Multiple thermoregulatory effectors with independent central controls.",
        "authorString": "McAllen RM, Tanaka M, Ootsuka Y, McKinley MJ.",
        "journalAbbreviation": "Eur. J. Appl. Physiol.",
        "pubYear": 2010,
        "volume": "109",
        "issue": "1",
        "pageInfo": "27-33",
        "citedByCount": 7
      },
      {
        "id": "18413319",
        "source": "MED",
        "title": "Complete sequence of the floR-carrying multiresistance plasmid pAB5S9 from freshwater Aeromonas bestiarum.",
        "authorString": "Gordon L, Cloeckaert A, Doublet B, Schwarz S, Bouju-Albert A, Ganiere JP, Le Bris H, Le Fleche-Mateos A, Giraud E.",
        "journalAbbreviation": "J. Antimicrob. Chemother.",
        "pubYear": 2008,
        "volume": "62",
        "issue": "1",
        "pageInfo": "65-71",
        "citedByCount": 7
      },
      {
        "id": "19252922",
        "source": "MED",
        "title": "Proliferation of neuronal progenitor cells and neuronal differentiation in the hypothalamus are enhanced in heat-acclimated rats.",
        "authorString": "Matsuzaki K, Katakura M, Hara T, Li G, Hashimoto M, Shido O.",
        "journalAbbreviation": "Pflugers Arch.",
        "pubYear": 2009,
        "volume": "458",
        "issue": "4",
        "pageInfo": "661-673",
        "citedByCount": 7
      },
      {
        "id": "19515980",
        "source": "MED",
        "title": "Cyclooxygenase-1 or -2--which one mediates lipopolysaccharide-induced hypothermia?",
        "authorString": "Steiner AA, Hunter JC, Phipps SM, Nucci TB, Oliveira DL, Roberts JL, Scheck AC, Simmons DL, Romanovsky AA.",
        "journalAbbreviation": "Am. J. Physiol. Regul. Integr. Comp. Physiol.",
        "pubYear": 2009,
        "volume": "297",
        "issue": "2",
        "pageInfo": "R485-94",
        "citedByCount": 5
      },
      {
        "id": "18617624",
        "source": "MED",
        "title": "Nicotine administration and withdrawal affect survival in systemic inflammation models.",
        "authorString": "Steiner AA, Oliveira DL, Roberts JL, Petersen SR, Romanovsky AA.",
        "journalAbbreviation": "J. Appl. Physiol.",
        "pubYear": 2008,
        "volume": "105",
        "issue": "4",
        "pageInfo": "1028-1034",
        "citedByCount": 5
      },
      {
        "id": "18386391",
        "source": "MED",
        "title": "The preoptic anterior hypothalamic area mediates initiation of the hypotensive response induced by LPS in male rats.",
        "authorString": "Yilmaz MS, Millington WR, Feleder C.",
        "journalAbbreviation": "Shock",
        "pubYear": 2008,
        "volume": "29",
        "issue": "2",
        "pageInfo": "232-237",
        "citedByCount": 4
      },
      {
        "id": "20393159",
        "source": "MED",
        "title": "Food deprivation alters thermoregulatory responses to lipopolysaccharide by enhancing cryogenic inflammatory signaling via prostaglandin D2.",
        "authorString": "Krall CM, Yao X, Hass MA, Feleder C, Steiner AA.",
        "journalAbbreviation": "Am. J. Physiol. Regul. Integr. Comp. Physiol.",
        "pubYear": 2010,
        "volume": "298",
        "issue": "6",
        "pageInfo": "R1512-21",
        "citedByCount": 2
      },
      {
        "id": "20416284",
        "source": "MED",
        "title": "Estrogen in the medial preoptic nucleus of the hypothalamus modulates cold responses in female rats.",
        "authorString": "Uchida Y, Tokizawa K, Nakamura M, Mori H, Nagashima K.",
        "journalAbbreviation": "Brain Res.",
        "pubYear": 2010,
        "volume": "1339",
        "pageInfo": "49-59",
        "citedByCount": 2
      },
      {
        "id": "22389645",
        "source": "MED",
        "title": "Central control of brown adipose tissue thermogenesis.",
        "authorString": "Morrison SF, Madden CJ, Tupone D.",
        "journalAbbreviation": "Front Endocrinol (Lausanne)",
        "pubYear": 2012,
        "volume": "3",
        "issue": "5",
        "citedByCount": 2
      },
      {
        "id": "18686574",
        "source": "MED",
        "title": "The oasis effect: response of birds to exurban development in a southwestern savanna.",
        "authorString": "Bock CE, Jones ZF, Bock JH.",
        "journalAbbreviation": "Ecol Appl",
        "pubYear": 2008,
        "volume": "18",
        "issue": "5",
        "pageInfo": "1093-1106",
        "citedByCount": 1
      },
      {
        "id": "19937527",
        "source": "MED",
        "title": "Characterization of an intravenous lipopolysaccharide inflammation model in broiler chickens.",
        "authorString": "De Boever S, Croubels S, Meyer E, Sys S, Beyaert R, Ducatelle R, De Backer P.",
        "journalAbbreviation": "Avian Pathol.",
        "pubYear": 2009,
        "volume": "38",
        "issue": "5",
        "pageInfo": "403-411",
        "citedByCount": 1
      },
      {
        "id": "21113688",
        "source": "MED",
        "title": "Efficient expression from one CMV enhancer controlling two core promoters.",
        "authorString": "Andersen CR, Nielsen LS, Baer A, Tolstrup AB, Weilguny D.",
        "journalAbbreviation": "Mol. Biotechnol.",
        "pubYear": 2011,
        "volume": "48",
        "issue": "2",
        "pageInfo": "128-137",
        "citedByCount": 0
      },
      {
        "id": "21142998",
        "source": "MED",
        "title": "Real behavior in virtual environments: psychology experiments in a simple virtual-reality paradigm using video games.",
        "authorString": "Kozlov MD, Johansen MK.",
        "journalAbbreviation": "Cyberpsychol Behav Soc Netw",
        "pubYear": 2010,
        "volume": "13",
        "issue": "6",
        "pageInfo": "711-714",
        "citedByCount": 0
      },
      {
        "id": "22823405",
        "source": "MED",
        "title": "A novel hierarchical clustering algorithm for gene sequences.",
        "authorString": "Wei D, Jiang Q, Wei Y, Wang S.",
        "journalAbbreviation": "BMC Bioinformatics",
        "pubYear": 2012,
        "volume": "13",
        "pageInfo": "174",
        "citedByCount": 0
      }
    ]
  }
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/pmc_europe.rb).

## API Documentation
* [PMC Europe RESTful Web Service](http://europepmc.org/RestfulWebService)
