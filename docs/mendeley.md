---
layout: card
title: "Mendeley"
---

[Mendeley](http://www.mendeley.com) is a reference manager and social bookmarking tool.

The Mendeley API returns incomplete API responses for articles where they don't have enough information, and we ignore those:

```json
    { uuid: "182cf980-6d0c-11df-a2b2-0026b95e3eb7" }
```

Mendeley uses OAuth2 authentification, we automatically obtain the access token using the **client_id** and **secret**.

## Required configuration fields

* **client_id** and **client_secret (secret)**: register your OAuth2 application at https://mix.mendeley.com/portal#/register

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>mendeley</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes<br/>(for groups only)</strong></td>
<td valign="top" width=80%>date (as date_added)<br/>contributor (as profile_id)</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>group_id</td>
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
<td valign="top" width=80%>150/hour</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Authentication</strong></td>
<td valign="top" width=80%>OAuth 2.0</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Restriction by IP Address</strong></td>
<td valign="top" width=80%>no</td>
</tr>
<tr>
<td valign="top" width=20%><strong>API URL</strong></td>
<td valign="top" width=80%>https://api-oauth2.mendeley.com/oapi/documents/details/DOI/?type=doi&consumer_key=API_KEY</td>
</tr>
</tbody>
</table>

## Example Response

```json
{ abstract: "Background: The whole blood interferon-gamma assay (QuantiFERON-TB-2G; QFT) has not been fully evaluated as a baseline tuberculosis screening test in Japanese healthcare students commencing clinical contact. The aim of this study was to compare the results from the QFT with those from the tuberculin skin test (TST) in a population deemed to be at a low risk for infection with Mycobacterium tuberculosis. Methodology/Principal Findings: Healthcare students recruited at Okayama University received both the TST and the QFT to assess the level of agreement between these two tests. The interleukin-10 levels before and after exposure to M tuberculosis-specific antigens (early-secreted antigenic target 6-kDa protein ESAT-6 and culture filtrate protein 10 CFP-10) were also measured. Of the 536 healthcare students, most of whom had been vaccinated with bacillus-Calmette-Guérin (BCG), 207 (56%) were enrolled in this study. The agreement between the QFT and the TST results was poor, with positive result rates of 1.4% vs. 27.5%, respectively. A multivariate analysis also revealed that the induration diameter of the TST was not affected by the interferon-gamma concentration after exposure to either of the antigens but was influenced by the number of BCG needle scars (p=0.046). The whole blood interleukin-10 assay revealed that after antigen exposure, the median increases in interleukin-10 concentration was higher in the subgroup with the small increase in interferon-gamma concentration than in the subgroup with the large increase in interferon-gamma concentration (0.3 vs. 0 pg/mL; p=0.004). Conclusions/Significance: As a baseline screening test for low-risk Japanese healthcare students at their course entry, QFT yielded quite discordant results, compared with the TST, probably because of the low specificity of the TST results in the BCG-vaccinated population. We also found, for the first time, that the change in the interleukin-10 level after exposure to specific antigens was inversely associated with that in the interferon-gamma level in a low-risk population.",
website: "http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=1950083&tool=pmcentrez&rendertype=abstract",
identifiers: {
  oai_id: "oai:pubmedcentral.nih.gov:1950083",
  other: "07-PONE-RA-00987R2",
  pmid: "17726533",
  pmc_id: "1950083",
  doi: "10.1371/journal.pone.0000803"
},
stats: {
  readers: 5,
  discipline: [
  {
    id: 19,
    name: "Medicine",
    value: 80
  },
  {
    id: 3,
    name: "Biological Sciences",
    value: 20
  }
  ],
  country: [
  {
    name: "United Kingdom",
    value: 20
  },
  {
    name: "Germany",
    value: 20
  },
  {
    name: "Australia",
    value: 20
  }
  ],
  status: [
  {
    name: "Post Doc",
    value: 60
  },
  {
    name: "Senior Lecturer",
    value: 20
  },
  {
    name: "Researcher (at a non-Academic Institution)",
    value: 20
  }
  ]
  },
  issue: "8",
  pages: "7",
  public_file_hash: "66a757a2f75fa5434b3cdd8a36d743d4a808416e",
  editors: [
  {
    forename: "Madhukar",
    surname: "Pai"
  }
  ],
  publication_outlet: "PLoS ONE",
  type: "Journal Article",
  mendeley_url: "http://api.mendeley.com/research/whole-blood-interferongamma-assay-for-baseline-tuberculosis-screening-among-japanese-healthcare-students/",
  publisher: "Public Library of Science",
  uuid: "182cf980-6d0c-11df-a2b2-0026b95e3eb7",
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/mendeley.rb).

## Further Documentation
* [Mendeley API Documentation](http://apidocs.mendeley.com)
* [Mendeley Open API Developers Google Group](https://groups.google.com/forum/?fromgroups#!forum/mendeley-open-api-developers)
