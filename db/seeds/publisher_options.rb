crossref_cfg = OpenStruct.new
crossref_cfg['username'] = 'plos'
crossref_cfg['password'] = 'plos1'

crossref = PublisherOption.where(source_id: 4).where(publisher_id: 340).first_or_create(
  :publisher_id => 340,
  :source_id => 4,
  :config => crossref_cfg)

pmc_cfg = OpenStruct.new
pmc_cfg['journals'] = 'plosbiol plosmed ploscomp plosgen plospath plosone plosntd plosct ploscurrents'
pmc_cfg['username'] = 'plospubs'
pmc_cfg['password'] = 'er56nm'

pmc = PublisherOption.where(source_id: 13).where(publisher_id: 340).first_or_create(
  :publisher_id => 340,
  :source_id => 13,
  :config => pmc_cfg)
