#
# GROUPS
#
saved       = Group.where(name: 'saved').first_or_create(title: 'Saved')
cited       = Group.where(name: 'cited').first_or_create(title: 'Cited')
discussed   = Group.where(name: 'discussed').first_or_create(title: 'Discussed')
viewed      = Group.where(name: 'viewed').first_or_create(title: 'Viewed')
other       = Group.where(name: 'other').first_or_create(title: 'Other')
recommended = Group.where(name: 'recommended').first_or_create(title: 'Recommended')

#
# SOURCES (start with a clean slate)
#
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


citeulike_cfg = OpenStruct.new
citeulike_cfg['url'] = 'http://www.citeulike.org/api/posts/for/doi/%{doi}'
citeulike_cfg['job_batch_size']                 = 200
citeulike_cfg['batch_time_interval']            = 3600
citeulike_cfg['rate_limiting']                  = 2000
citeulike_cfg['wait_time']                      = 300
citeulike_cfg['staleness_week']                 = 86400
citeulike_cfg['staleness_month']                = 86400
citeulike_cfg['staleness_year']                 = 648000
citeulike_cfg['staleness_all']                  = 2592000
citeulike_cfg['timeout']                        = 30
citeulike_cfg['max_failed_queries']             = 200
citeulike_cfg['max_failed_query_time_interval'] = 86400
citeulike_cfg['disable_delay']                  = 10
citeulike_cfg['workers']                        = 50
citeulike_cfg['events_url']                     = 'http://www.citeulike.org/doi/%{doi}'
citeulike_cfg['priority']                       = 6
citeulike_cfg['queue']                          = 'low'
citeulike_cfg['tracked']                        = "'0'"

citeulike = Citeulike.where(name: 'citeulike').first_or_create(
  :id          => 2,
  :type        => Citeulike,
  :name        => citeulike,
  :title       => CiteULike,
  :config      => citeulike_cfg,
  :group_id    => saved.id,
  :private     => 0,
  :description => 'CiteULike is a free social bookmarking service for scholarly content.',
  :queueable   => 1,
  :eventable   => 1)

#
# PUBLISHER_OPTIONS 
#
crossref_cfg = OpenStruct.new
crossref_cfg['username'] = 'plos'
crossref_cfg['password'] = 'plos1'

crossref_po = PublisherOption.where(source_id: crossref.id).where(publisher_id: 340).first_or_create(
  :publisher_id => 340,
  :source_id => crossref.id,
  :config => crossref_cfg)

#pmc_cfg = OpenStruct.new
#pmc_cfg['journals'] = 'plosbiol plosmed ploscomp plosgen plospath plosone plosntd plosct ploscurrents'
#pmc_cfg['username'] = 'plospubs'
#pmc_cfg['password'] = 'er56nm'

#pmc = PublisherOption.where(source_id: 13).where(publisher_id: 340).first_or_create(
  #:publisher_id => 340,
  #:source_id => 13,
  #:config => pmc_cfg)
