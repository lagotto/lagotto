# Load Copernicus sample articles
Article.find_or_create_by_doi(
  :doi => "10.5194/acp-5-1053-2005",
  :title => "Organic aerosol and global climate modelling: a review",
  :published_on => "2005-03-30")
  
Article.find_or_create_by_doi(
  :doi => "10.5194/acp-11-9709-2011",
  :title => "Modelling atmospheric OH-reactivity in a boreal forest ecosystem",
  :published_on => "2011-09-20")
    
Article.find_or_create_by_doi(
  :doi => "10.5194/acp-11-13325-2011",
  :title => "Comparison of chemical characteristics of 495 biomass burning plumes intercepted by the NASA DC-8 aircraft during the ARCTAS/CARB-2008 field campaign",
  :published_on => "2011-12-22")
      
Article.find_or_create_by_doi(
  :doi => "10.5194/acp-12-1-2012",
  :title => "A review of operational, regional-scale, chemical weather forecasting models in Europe",
  :published_on => "2012-01-02")
        
Article.find_or_create_by_doi(
  :doi => "10.5194/se-1-1-2010",
  :title => "The Eons of Chaos and Hades",
  :published_on => "2010-02-02")