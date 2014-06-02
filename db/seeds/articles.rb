# encoding: UTF-8
# Load sample articles
if ENV['ARTICLES']
  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pone.0008776",
    title: "The \"Island Rule\" and Deep-Sea Gastropods: Re-Examining the Evidence",
    year: 2010,
    month: 1,
    day: 19)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pcbi.1000204",
    title: "Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web",
    year: 2008,
    month: 10,
    day: 31)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pone.0018657",
    title: "Who Shares? Who Doesn't? Factors Associated with Openly Archiving Raw Research Data",
    year: 2011,
    month: 7,
    day: 13)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pcbi.0010057",
    title: "Ten Simple Rules for Getting Published",
    year: 2005,
    month: 10,
    day: 28)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pone.0000443",
    title: "Order in Spontaneous Behavior",
    year: 2007,
    month: 5,
    day: 16)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pbio.1000242",
    title: "Article-Level Metrics and the Evolution of Scientific Impact",
    year: 2009,
    month: 11,
    day: 17)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pone.0035869",
    title: "Research Blogs and the Discussion of Scholarly Information",
    year: 2012,
    month: 5,
    day: 11)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pmed.0020124",
    title: "Why Most Published Research Findings Are False",
    year: 2005,
    month: 8,
    day: 30)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pone.0036240",
    title: "How Academic Biologists and Physicists View Science Outreach",
    year: 2012,
    month: 5,
    day: 9)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pone.0000000",
    title: "PLoS Journals Sandbox: A Place to Learn and Play",
    year: 2006,
    month: 12,
    day: 20)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pmed.0020146",
    title: "How Prevalent Is Schizophrenia?",
    year: 2005,
    month: 5,
    day: 31)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pbio.0030137",
    title: "Perception Space-The Final Frontier",
    year: 2005,
    month: 4,
    day: 12)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pcbi.1002445",
    title: "Circular Permutation in Proteins",
    year: 2012,
    month: 3,
    day: 29)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pone.0036790",
    title: "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
    year: 2012,
    month: 5,
    day: 15)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pbio.0060188",
    title: "Going, Going, Gone: Is Animal Migration Disappearing",
    year: 2008,
    month: 7,
    day: 29)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pone.0001636",
    title: "Measuring the Meltdown: Drivers of Global Amphibian Extinction and Decline",
    year: 2008,
    month: 2,
    day: 20)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pone.0006872",
    title: "Persistent Exposure to Mycoplasma Induces Malignant Transformation of Human Prostate Cells",
    year: 2009,
    month: 9,
    day: 1)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pcbi.0020131",
    title: "Sampling Realistic Protein Conformations Using Local Structural Bias",
    year: 2006,
    month: 9,
    day: 22)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pbio.0040015",
    title: "Thriving Community of Pathogenic Plant Viruses Found in the Human Gut",
    year: 2005,
    month: 12,
    day: 20)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pbio.0020413",
    title: "Taking Stock of Biodiversity to Stem Its Rapid Decline",
    year: 2004,
    month: 10,
    day: 26)

  Article.find_or_create_by_doi(
    doi: "10.5194/acp-5-1053-2005",
    title: "Organic aerosol and global climate modelling: a review",
    year: 2005,
    month: 3,
    day: 30)

  Article.find_or_create_by_doi(
    doi: "10.5194/acp-11-9709-2011",
    title: "Modelling atmospheric OH-reactivity in a boreal forest ecosystem",
    year: 2011,
    month: 9,
    day: 20)

  Article.find_or_create_by_doi(
    doi: "10.5194/acp-11-13325-2011",
    title: "Comparison of chemical characteristics of 495 biomass burning plumes intercepted by the NASA DC-8 aircraft during the ARCTAS/CARB-2008 field campaign",
    year: 2011,
    month: 12,
    day: 22)

  Article.find_or_create_by_doi(
    doi: "10.5194/acp-12-1-2012",
    title: "A review of operational, regional-scale, chemical weather forecasting models in Europe",
    year: 2012,
    month: 1,
    day: 2)

  Article.find_or_create_by_doi(
    doi: "10.5194/se-1-1-2010",
    title: "The Eons of Chaos and Hades",
    year: 2010,
    month: 2,
    day: 2)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.ppat.1000446",
    title: "A New Malaria Agent in African Hominids",
    year: 2009,
    month: 5,
    day: 29)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pone.0020094",
    title: "Meiofauna in the Gollum Channels and the Whittard Canyon, Celtic Margin—How Local Environmental Conditions Shape Nematode Structure and Function",
    year: 2011,
    month: 5,
    day: 18)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pbio.0000045",
    title: "The Genome Sequence of Caenorhabditis briggsae: A Platform for Comparative Genomics",
    year: 2003,
    month: 11,
    day: 17)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pbio.0050254",
    title: "The Diploid Genome Sequence of an Individual Human",
    year: 2007,
    month: 9,
    day: 4)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pone.0044271",
    title: "Lesula: A New Species of <italic>Cercopithecus</italic> Monkey Endemic to the Democratic Republic of Congo and Implications for Conservation of Congo’s Central Basin",
    year: 2012,
    month: 9,
    day: 12)

  Article.find_or_create_by_doi(
    doi: "10.1371/journal.pone.0033288",
    title: "Genome Features of 'Dark-Fly', a <italic>Drosophila</italic> Line Reared Long-Term in a Dark Environment",
    year: 2012,
    month: 3,
    day: 14)

  Article.find_or_create_by_doi(
    doi: "10.2307/1158830",
    title: "Histoires de riz, histoires d'igname: le cas de la Moyenne Cote d'Ivoire",
    year: 1981)

  Article.find_or_create_by_doi(
    doi: "10.2307/683422",
    title: "Review of: The Life and Times of Sara Baartman: The Hottentot Venus by Zola Maseko",
    year: 2000,
    month: 9)

  Article.find_or_create_by_doi(
    doi: "10.1098/rstl.1665.0022",
    title: "Of A Way of Killing Ratle-Snakes",
    year: 1665)

  Article.find_or_create_by_doi(
    doi: "10.1098/rstl.1665.0005",
    title: "A Spot in One of the Belts of Jupiter",
    year: 1665)
end
