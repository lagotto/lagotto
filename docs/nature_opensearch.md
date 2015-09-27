---
layout: card
title: "Nature.com OpenSearch"
---

Search the Nature.com corpus for scholarly works using their [OpenSearch](http://www.nature.com/developers/documentation/api-references/opensearch-api/) API.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>Lagotto Name</strong></td>
<td valign="top" width=70%>nature_opensearch</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Lagotto Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Lagotto Core Attributes</strong></td>
<td valign="top" width=80%>&nbsp;</td>
</tr>
<td valign="top" width=20%><strong>Lagotto Other Attributes</strong></td>
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
<td valign="top" width=80%>http://www.nature.com/opensearch/request?query="DOI"+OR+"URL"&httpAccept=application/json&startRecord=1</td>
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
  "comment": "nature.com OpenSearch: urn:uuid:87b647d0-d324-4d30-87cd-06f416627f07",
  "namespaces": {
  },
  "feed": {
    "title": "nature.com OpenSearch: \"https://github.com/najoshi/sickle\"",
    "subtitle": "The nature.com OpenSearch service provides a structured resource discovery facility for content hosted on nature.com.",
    "id": "urn:uuid:87b647d0-d324-4d30-87cd-06f416627f07",
    "author": {
      "name": "nature.com",
      "uri": "http://www.nature.com",
      "email": "interfaces@nature.com"
    },
    "updated": "2015-02-25T18:11:11+00:00",
    "rights": "Â© 2015 Nature Publication Group",
    "icon": "http://www.nature.com/opensearch/common/imgs/npg_icon.jpg",
    "link": [
    ],
    "dc:publisher": "Nature Publishing Group",
    "dc:language": "en",
    "dc:rights": "Â© 2015 Nature Publication Group",
    "prism:copyright": "Â© 2015 Nature Publication Group",
    "prism:rightsAgent": "permissions@nature.com",
    "opensearch:totalResults": 7,
    "opensearch:startIndex": 1,
    "opensearch:itemsPerPage": 7,
    "opensearch:Query": [
    ],
    "sru:numberOfRecords": 7,
    "sru:resultSetId": "66eb80c0-c391-4a04-b327-3e4d59a9bf17",
    "sru:resultSetTTL": "3600",
    "sru:echoedSearchRetrieveRequest": {
      "sru:version": null,
      "sru:query": "\"https://github.com/najoshi/sickle\"",
      "sru:startRecord": "1",
      "sru:maximumRecords": "25",
      "sru:recordPacking": "packed",
      "sru:recordSchema": "pam",
      "sru:sortKeys": ",pam,0"
    },
    "sru:extraResponseData": {
      "npg:collection": "journals_nature,journals_palgrave,lab_animal,-international_abstracts_in_operations_research",
      "npg:context": "false",
      "npg:copyright": "Â© 2015 Nature Publication Group",
      "npg:entry": "",
      "npg:databaseTitle": "nature.com OpenSearch",
      "npg:datetime": "2015-02-25T18:11:11+00:00",
      "npg:httpAccept": "application/json",
      "npg:responseId": "87b647d0-d324-4d30-87cd-06f416627f07"
    },
    "entry": [
      {
        "title": "Community transcriptomics reveals unexpected high microbial diversity in acidophilic biofilm communities",
        "link": "http://dx.doi.org/10.1038/ismej.2014.200",
        "id": "http://dx.doi.org/10.1038/ismej.2014.200",
        "updated": "2015-02-25T18:11:11+00:00",
        "content": null,
        "sru:recordSchema": "info:srw/schema/11/pam-v2.1",
        "sru:recordPacking": "packed",
        "sru:recordData": {
          "pam:message": {
            "pam:article": {
              "xhtml:head": {
                "dc:identifier": "doi:10.1038/ismej.2014.200",
                "dc:title": "Community transcriptomics reveals unexpected high microbial diversity in acidophilic biofilm communities",
                "prism:productCode": "ismej",
                "dc:creator": [
                  "Daniela S Aliaga Goltsman",
                  "Luis R Comolli",
                  "Brian C Thomas",
                  "Jillian F Banfield"
                ],
                "prism:publicationName": "The ISME Journal",
                "prism:issn": "1751-7362",
                "prism:eIssn": "1751-7370",
                "prism:doi": "10.1038/ismej.2014.200",
                "dc:publisher": "Nature Publishing Group",
                "dc:description": "<p>A fundamental question in microbial ecology relates to community structure, and how this varies across environment types. It is widely believed that some environments, such as those at very low pH, host simple communities based on the low number of taxa, possibly due to the extreme environmental conditions. However, most analyses of species richness have relied on methods that provide relatively low ribosomal RNA (rRNA) sampling depth. Here we used community transcriptomics to analyze the microbial diversity of natural acid mine drainage biofilms from the Richmond Mine at Iron Mountain, California. Our analyses target deep pools of rRNA gene transcripts recovered from both natural and laboratory-grown biofilms across varying developmental stages. In all, 91.8% of the âˆ¼254 million Illumina reads mapped to rRNA genes represented in the SILVA database. Up to 159 different taxa, including Bacteria, Archaea and Eukaryotes, were identified. Diversity measures, ordination and hierarchical clustering separate environmental from laboratory-grown biofilms. In part, this is due to the much larger number of rare members in the environmental biofilms. Although <i>Leptospirillum</i> bacteria generally dominate biofilms, we detect a wide variety of other <i>Nitrospira</i> organisms present at very low abundance. Bacteria from the <i>Chloroflexi</i> phylum were also detected. The results indicate that the primary characteristic that has enabled prior extensive cultivation-independent â€˜omicâ€™ analyses is not simplicity but rather the high dominance by a few taxa. We conclude that a much larger variety of organisms than previously thought have adapted to this extreme environment, although only few are selected for at any one time.</p>",
                "prism:publicationDate": "2014-11-04",
                "prism:coverDate": null,
                "prism:aggregationType": "aop",
                "prism:volume": null,
                "prism:number": null,
                "prism:startingPage": null,
                "prism:endingPage": null,
                "prism:url": "http://dx.doi.org/10.1038/ismej.2014.200",
                "prism:channel": null,
                "prism:section": null,
                "dc:subject": [
                  "Environmental microbiology"
                ],
                "prism:genre": "Research",
                "prism:copyright": "Â© 2014 International Society for Microbial Ecology"
              }
            }
          }
        },
        "sru:recordPosition": 1,
        "sru:extraRecordData": {
          "entry": [
          ]
        }
      },
      {
        "title": "Predicting the response of the deep-ocean microbiome to geochemical perturbations by hydrothermal vents",
        "link": "http://dx.doi.org/10.1038/ismej.2015.4",
        "id": "http://dx.doi.org/10.1038/ismej.2015.4",
        "updated": "2015-02-25T18:11:11+00:00",
        "content": null,
        "sru:recordSchema": "info:srw/schema/11/pam-v2.1",
        "sru:recordPacking": "packed",
        "sru:recordData": {
          "pam:message": {
            "pam:article": {
              "xhtml:head": {
                "dc:identifier": "doi:10.1038/ismej.2015.4",
                "dc:title": "Predicting the response of the deep-ocean microbiome to geochemical perturbations by hydrothermal vents",
                "prism:productCode": "ismej",
                "dc:creator": [
                  "Daniel C Reed",
                  "John A Breier",
                  "Houshuo Jiang",
                  "Karthik Anantharaman",
                  "Christopher A Klausmeier",
                  "Brandy M Toner",
                  "Cathrine Hancock",
                  "Kevin Speer",
                  "Andreas M Thurnherr",
                  "Gregory J Dick"
                ],
                "prism:publicationName": "The ISME Journal",
                "prism:issn": "1751-7362",
                "prism:eIssn": "1751-7370",
                "prism:doi": "10.1038/ismej.2015.4",
                "dc:publisher": "Nature Publishing Group",
                "dc:description": "<p>Submarine hydrothermal vents perturb the deep-ocean microbiome by injecting reduced chemical species into the water column that act as an energy source for chemosynthetic organisms. These systems thus provide excellent natural laboratories for studying the response of microbial communities to shifts in marine geochemistry. The present study explores the processes that regulate coupled microbial-geochemical dynamics in hydrothermal plumes by means of a novel mathematical model, which combines thermodynamics, growth and reaction kinetics, and transport processes derived from a fluid dynamics model. Simulations of a plume located in the ABE vent field of the Lau basin were able to reproduce metagenomic observations well and demonstrated that the magnitude of primary production and rate of autotrophic growth are largely regulated by the energetics of metabolisms and the availability of electron donors, as opposed to kinetic parameters. Ambient seawater was the dominant source of microbes to the plume and sulphur oxidisers constituted almost 90% of the modelled community in the neutrally-buoyant plume. Data from drifters deployed in the region allowed the different time scales of metabolisms to be cast in a spatial context, which demonstrated spatial succession in the microbial community. While growth was shown to occur over distances of tens of kilometers, microbes persisted over hundreds of kilometers. Given that high-temperature hydrothermal systems are found less than 100 km apart on average, plumes may act as important vectors between different vent fields and other environments that are hospitable to similar organisms, such as oil spills and oxygen minimum zones.</p>\n<span><i>The ISME Journal</i> advance online publication, 6 February 2015; doi:<span>10.1038/ismej.2015.4</span></span>",
                "prism:publicationDate": "2015-02-06",
                "prism:coverDate": null,
                "prism:aggregationType": "aop",
                "prism:volume": null,
                "prism:number": null,
                "prism:startingPage": null,
                "prism:endingPage": null,
                "prism:url": "http://dx.doi.org/10.1038/ismej.2015.4",
                "prism:channel": null,
                "prism:section": null,
                "dc:subject": null,
                "prism:genre": "Research",
                "prism:copyright": "Â© 2015 International Society for Microbial Ecology"
              }
            }
          }
        },
        "sru:recordPosition": 2,
        "sru:extraRecordData": {
          "entry": [
          ]
        }
      },
      {
        "title": "Stable-isotope probing and metagenomics reveal predation by protozoa drives <i>E. coli</i> removal in slow sand filters",
        "link": "http://dx.doi.org/10.1038/ismej.2014.175",
        "id": "http://dx.doi.org/10.1038/ismej.2014.175",
        "updated": "2015-02-25T18:11:11+00:00",
        "content": null,
        "sru:recordSchema": "info:srw/schema/11/pam-v2.1",
        "sru:recordPacking": "packed",
        "sru:recordData": {
          "pam:message": {
            "pam:article": {
              "xhtml:head": {
                "dc:identifier": "doi:10.1038/ismej.2014.175",
                "dc:title": "Stable-isotope probing and metagenomics reveal predation by protozoa drives <i>E. coli</i> removal in slow sand filters",
                "prism:productCode": "ismej",
                "dc:creator": [
                  "Sarah-Jane Haig",
                  "Melanie Schirmer",
                  "Rosalinda D'Amore",
                  "Joseph Gibbs",
                  "Robert L Davies",
                  "Gavin Collins",
                  "Christopher Quince"
                ],
                "prism:publicationName": "The ISME Journal",
                "prism:issn": "1751-7362",
                "prism:eIssn": "1751-7370",
                "prism:doi": "10.1038/ismej.2014.175",
                "dc:publisher": "Nature Publishing Group",
                "dc:description": "<p>Stable-isotope probing and metagenomics were applied to study samples taken from laboratory-scale slow sand filters 0.5, 1, 2, 3 and 4â€‰h after challenging with <sup>13</sup>C-labelled <i>Escherichia coli</i> to determine the mechanisms and organisms responsible for coliform removal. Before spiking, the filters had been continuously operated for 7 weeks using water from the River Kelvin, Glasgow as their influent source. Direct counts and quantitative PCR assays revealed a clear predatorâ€“prey response between protozoa and <i>E. coli</i>. The importance of top-down trophic-interactions was confirmed by metagenomic analysis, identifying several protozoan and viral species connected to <i>E. coli</i> attrition, with protozoan grazing responsible for the majority of the removal. In addition to top-down mechanisms, indirect mechanisms, such as algal reactive oxygen species-induced lysis, and mutualistic interactions between algae and fungi, were also associated with coliform removal. The findings significantly further our understanding of the processes and trophic interactions underpinning <i>E. coli</i> removal. This study provides an example for similar studies, and the opportunity to better understand, manage and enhance <i>E. coli</i> removal by allowing the creation of more complex trophic interaction models.</p>\n<span><i>The ISME Journal</i> advance online publication, 3 October 2014; doi:<span>10.1038/ismej.2014.175</span></span>",
                "prism:publicationDate": "2014-10-03",
                "prism:coverDate": null,
                "prism:aggregationType": "aop",
                "prism:volume": null,
                "prism:number": null,
                "prism:startingPage": null,
                "prism:endingPage": null,
                "prism:url": "http://dx.doi.org/10.1038/ismej.2014.175",
                "prism:channel": null,
                "prism:section": null,
                "dc:subject": [
                  "Water microbiology"
                ],
                "prism:genre": "Research",
                "prism:copyright": "Â© 2014 International Society for Microbial Ecology"
              }
            }
          }
        },
        "sru:recordPosition": 3,
        "sru:extraRecordData": {
          "entry": [
          ]
        }
      },
      {
        "title": "Aquifer environment selects for microbial species cohorts in sediment and groundwater",
        "link": "http://dx.doi.org/10.1038/ismej.2015.2",
        "id": "http://dx.doi.org/10.1038/ismej.2015.2",
        "updated": "2015-02-25T18:11:11+00:00",
        "content": null,
        "sru:recordSchema": "info:srw/schema/11/pam-v2.1",
        "sru:recordPacking": "packed",
        "sru:recordData": {
          "pam:message": {
            "pam:article": {
              "xhtml:head": {
                "dc:identifier": "doi:10.1038/ismej.2015.2",
                "dc:title": "Aquifer environment selects for microbial species cohorts in sediment and groundwater",
                "prism:productCode": "ismej",
                "dc:creator": [
                  "Laura A Hug",
                  "Brian C Thomas",
                  "Christopher T Brown",
                  "Kyle R Frischkorn",
                  "Kenneth H Williams",
                  "Susannah G Tringe",
                  "Jillian F Banfield"
                ],
                "prism:publicationName": "The ISME Journal",
                "prism:issn": "1751-7362",
                "prism:eIssn": "1751-7370",
                "prism:doi": "10.1038/ismej.2015.2",
                "dc:publisher": "Nature Publishing Group",
                "dc:description": "<p>Little is known about the biogeography or stability of sediment-associated microbial community membership because these environments are biologically complex and generally difficult to sample. High-throughput-sequencing methods provide new opportunities to simultaneously genomically sample and track microbial community members across a large number of sampling sites or times, with higher taxonomic resolution than is associated with 16â€‰S ribosomal RNA gene surveys, and without the disadvantages of primer bias and gene copy number uncertainty. We characterized a sediment community at 5â€‰m depth in an aquifer adjacent to the Colorado River and tracked its most abundant 133 organisms across 36 different sediment and groundwater samples. We sampled sites separated by centimeters, meters and tens of meters, collected on seven occasions over 6 years. Analysis of 1.4 terabase pairs of DNA sequence showed that these 133 organisms were more consistently detected in saturated sediments than in samples from the vadose zone, from distant locations or from groundwater filtrates. Abundance profiles across aquifer locations and from different sampling times identified organism cohorts that comprised subsets of the 133 organisms that were consistently associated. The data suggest that cohorts are partly selected for by shared environmental adaptation.</p>",
                "prism:publicationDate": "2015-02-03",
                "prism:coverDate": null,
                "prism:aggregationType": "aop",
                "prism:volume": null,
                "prism:number": null,
                "prism:startingPage": null,
                "prism:endingPage": null,
                "prism:url": "http://dx.doi.org/10.1038/ismej.2015.2",
                "prism:channel": null,
                "prism:section": null,
                "dc:subject": null,
                "prism:genre": "Research",
                "prism:copyright": "Â© 2015 International Society for Microbial Ecology"
              }
            }
          }
        },
        "sru:recordPosition": 4,
        "sru:extraRecordData": {
          "entry": [
          ]
        }
      },
      {
        "title": "Biology of a widespread uncultivated archaeon that contributes to carbon fixation in the subsurface",
        "link": "http://dx.doi.org/10.1038/ncomms6497",
        "id": "http://dx.doi.org/10.1038/ncomms6497",
        "updated": "2015-02-25T18:11:11+00:00",
        "content": null,
        "sru:recordSchema": "info:srw/schema/11/pam-v2.1",
        "sru:recordPacking": "packed",
        "sru:recordData": {
          "pam:message": {
            "pam:article": {
              "xhtml:head": {
                "dc:identifier": "doi:10.1038/ncomms6497",
                "dc:title": "Biology of a widespread uncultivated archaeon that contributes to carbon fixation in the subsurface",
                "prism:productCode": "ncomms",
                "dc:creator": [
                  "Alexander J. Probst",
                  "Thomas Weinmaier",
                  "Kasie Raymann",
                  "Alexandra Perras",
                  "Joanne B. Emerson",
                  "Thomas Rattei",
                  "Gerhard Wanner",
                  "Andreas Klingl",
                  "Ivan A. Berg",
                  "Marcos Yoshinaga",
                  "Bernhard Viehweger",
                  "Kai-Uwe Hinrichs",
                  "Brian C. Thomas",
                  "Sandra Meck",
                  "Anna K. Auerbach",
                  "Matthias Heise",
                  "Arno Schintlmeister",
                  "Markus Schmid",
                  "Michael Wagner",
                  "Simonetta Gribaldo",
                  "Jillian F. Banfield",
                  "Christine Moissl-Eichinger"
                ],
                "prism:publicationName": "Nature Communications",
                "prism:issn": null,
                "prism:eIssn": "2041-1723",
                "prism:doi": "10.1038/ncomms6497",
                "dc:publisher": "Nature Publishing Group",
                "dc:description": "<p>Subsurface microbial life contributes significantly to biogeochemical cycling, yet it remains largely uncharacterized, especially its archaeal members. This 'microbial dark matter' has been explored by recent studies that were, however, mostly based on DNA sequence information only. Here, we use diverse techniques including ultrastuctural analyses to link genomics to biology for the SM1 Euryarchaeon lineage, an uncultivated group of subsurface archaea. Phylogenomic analyses reveal this lineage to belong to a widespread group of archaea that we propose to classify as a new euryarchaeal order (â€˜<i>Candidatus</i> Altiarchaealesâ€™). The representative, double-membraned species â€˜<i>Candidatus</i> Altiarchaeum hamiconexumâ€™ has an autotrophic metabolism that uses a not-yet-reported Factor<sub>420</sub>-free reductive acetyl-CoA pathway, confirmed by stable carbon isotopic measurements of archaeal lipids. Our results indicate that this lineage has evolved specific metabolic and structural features like nano-grappling hooks empowering this widely distributed archaeon to predominate anaerobic groundwater, where it may represent an important carbon dioxide sink.</p>",
                "prism:publicationDate": "2014-11-26",
                "prism:coverDate": null,
                "prism:aggregationType": "online",
                "prism:volume": "5",
                "prism:number": null,
                "prism:startingPage": null,
                "prism:endingPage": null,
                "prism:url": "http://dx.doi.org/10.1038/ncomms6497",
                "prism:channel": null,
                "prism:section": null,
                "dc:subject": null,
                "prism:genre": "Research",
                "prism:copyright": "Â© 2014 Nature Publishing Group, a division of Macmillan Publishers Limited. All Rights Reserved."
              }
            }
          }
        },
        "sru:recordPosition": 5,
        "sru:extraRecordData": {
          "entry": [
          ]
        }
      },
      {
        "title": "Extraordinary phylogenetic diversity and metabolic versatility in aquifer sediment",
        "link": "http://dx.doi.org/10.1038/ncomms3120",
        "id": "http://dx.doi.org/10.1038/ncomms3120",
        "updated": "2015-02-25T18:11:11+00:00",
        "content": null,
        "sru:recordSchema": "info:srw/schema/11/pam-v2.1",
        "sru:recordPacking": "packed",
        "sru:recordData": {
          "pam:message": {
            "pam:article": {
              "xhtml:head": {
                "dc:identifier": "doi:10.1038/ncomms3120",
                "dc:title": "Extraordinary phylogenetic diversity and metabolic versatility in aquifer sediment",
                "prism:productCode": "ncomms",
                "dc:creator": [
                  "Cindy J. Castelle",
                  "Laura A. Hug",
                  "Kelly C. Wrighton",
                  "Brian C. Thomas",
                  "Kenneth H. Williams",
                  "Dongying Wu",
                  "Susannah G. Tringe",
                  "Steven W. Singer",
                  "Jonathan A. Eisen",
                  "Jillian F. Banfield"
                ],
                "prism:publicationName": "Nature Communications",
                "prism:issn": null,
                "prism:eIssn": "2041-1723",
                "prism:doi": "10.1038/ncomms3120",
                "dc:publisher": "Nature Publishing Group",
                "dc:description": "<p>Microorganisms in the subsurface represent a substantial but poorly understood component of the Earthâ€™s biosphere. Subsurface environments are complex and difficult to characterize; thus, their microbiota have remained as a â€˜dark matterâ€™ of the carbon and other biogeochemical cycles. Here we deeply sequence two sediment-hosted microbial communities from an aquifer adjacent to the Colorado River, CO, USA. No single organism represents more than ~1% of either community. Remarkably, many bacteria and archaea in these communities are novel at the phylum level or belong to phyla lacking a sequenced representative. The dominant organism in deeper sediment, RBG-1, is a member of a new phylum. On the basis of its reconstructed complete genome, RBG-1 is metabolically versatile. Its wide respiration-based repertoire may enable it to respond to the fluctuating redox environment close to the water table. We document extraordinary microbial novelty and the importance of previously unknown lineages in sediment biogeochemical transformations.</p>",
                "prism:publicationDate": "2013-08-27",
                "prism:coverDate": null,
                "prism:aggregationType": "online",
                "prism:volume": "4",
                "prism:number": null,
                "prism:startingPage": null,
                "prism:endingPage": null,
                "prism:url": "http://dx.doi.org/10.1038/ncomms3120",
                "prism:channel": null,
                "prism:section": null,
                "dc:subject": null,
                "prism:genre": "Research",
                "prism:copyright": "Â© 2013 Nature Publishing Group, a division of Macmillan Publishers Limited. All Rights Reserved."
              }
            }
          }
        },
        "sru:recordPosition": 6,
        "sru:extraRecordData": {
          "entry": [
          ]
        }
      },
      {
        "title": "Sailfish enables alignment-free isoform quantification from RNA-seq reads using lightweight algorithms",
        "link": "http://dx.doi.org/10.1038/nbt.2862",
        "id": "http://dx.doi.org/10.1038/nbt.2862",
        "updated": "2015-02-25T18:11:11+00:00",
        "content": null,
        "sru:recordSchema": "info:srw/schema/11/pam-v2.1",
        "sru:recordPacking": "packed",
        "sru:recordData": {
          "pam:message": {
            "pam:article": {
              "xhtml:head": {
                "dc:identifier": "doi:10.1038/nbt.2862",
                "dc:title": "Sailfish enables alignment-free isoform quantification from RNA-seq reads using lightweight algorithms",
                "prism:productCode": "nbt",
                "dc:creator": [
                  "Rob Patro",
                  "Stephen M Mount",
                  "Carl Kingsford"
                ],
                "prism:publicationName": "Nature Biotechnology",
                "prism:issn": "1087-0156",
                "prism:eIssn": "1546-1696",
                "prism:doi": "10.1038/nbt.2862",
                "dc:publisher": "Nature Publishing Group",
                "dc:description": "<p>We introduce Sailfish, a computational method for quantifying the abundance of previously annotated RNA isoforms from RNA-seq data. Because Sailfish entirely avoids mapping reads, a time-consuming step in all current methods, it provides quantification estimates much faster than do existing approaches (typically 20 times faster) without loss of accuracy. By facilitating frequent reanalysis of data and reducing the need to optimize parameters, Sailfish exemplifies the potential of lightweight algorithms for efficiently processing sequencing reads.</p>",
                "prism:publicationDate": "2014-04-20",
                "prism:coverDate": null,
                "prism:aggregationType": null,
                "prism:volume": "32",
                "prism:number": "5",
                "prism:startingPage": "462",
                "prism:endingPage": "464",
                "prism:url": "http://dx.doi.org/10.1038/nbt.2862",
                "prism:channel": null,
                "prism:section": null,
                "dc:subject": [
                  "Transcriptomics",
                  "RNA sequencing",
                  "Software",
                  "Genome informatics"
                ],
                "prism:genre": "Research",
                "prism:copyright": "Â© 2014 Nature Publishing Group, a division of Macmillan Publishers Limited. All Rights Reserved."
              }
            }
          }
        },
        "sru:recordPosition": 7,
        "sru:extraRecordData": {
          "entry": [
          ]
        }
      }
    ]
  }
}
```

## Source Code
The source code is available [here](https://github.com/lagotto/lagotto/blob/master/app/models/sources/nature_opensearch.rb).

## Further Documentation
* [Nature.com Developers OpenSearch API](http://www.nature.com/developers/documentation/api-references/opensearch-api/)
