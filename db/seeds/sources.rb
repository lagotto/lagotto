#
# GROUPS
#
cited       = Group.where(name: 'cited').first_or_create(title: 'Cited')
discussed   = Group.where(name: 'discussed').first_or_create(title: 'Discussed')
other       = Group.where(name: 'other').first_or_create(title: 'Other')
recommended = Group.where(name: 'recommended').first_or_create(title: 'Recommended')
saved       = Group.where(name: 'saved').first_or_create(title: 'Saved')
viewed      = Group.where(name: 'viewed').first_or_create(title: 'Viewed')

#
# SOURCES
#

# start with a clean-slate
Source.delete_all

bloglines_cfg = OpenStruct.new
bloglines_cfg['username'] = 'admin@plos.org'
bloglines_cfg['password'] = '1D556489390DB3E4DA0F6D97A9AB4949'
bloglines_cfg['url'] = 'http://www.bloglines.com/search?format=publicapi&apiuser=%{username}&apikey=%{password}&q=%{title}'

bloglines = Bloglines.where(name: 'bloglines').first_or_create(
  :id          => 1,
  :type        => 'Bloglines',
  :name        => 'bloglines',
  :title       => 'Bloglines',
  :config      => bloglines_cfg,
  :group_id    => other.id,
  :private     => 0,
  :state_event => 'inactivate',
  :queueable   => 1,
  :eventable   => 1)

#
# PUBLISHER_OPTIONS 
#
crossref_cfg = OpenStruct.new
crossref_cfg['username'] = 'plos'
crossref_cfg['password'] = 'plos1'

crossref_po = PublisherOption.where(source_id: bloglines.id).where(publisher_id: 340).first_or_create(
  :publisher_id => 340,
  :source_id => bloglines.id,
  :config => crossref_cfg)

#pmc_cfg = OpenStruct.new
#pmc_cfg['journals'] = 'plosbiol plosmed ploscomp plosgen plospath plosone plosntd plosct ploscurrents'
#pmc_cfg['username'] = 'plospubs'
#pmc_cfg['password'] = 'er56nm'

#pmc = PublisherOption.where(source_id: 13).where(publisher_id: 340).first_or_create(
  #:publisher_id => 340,
  #:source_id => 13,
  #:config => pmc_cfg)
