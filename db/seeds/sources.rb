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
# SOURCES
#
Source.delete_all   # clean-slate 

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
citeulike_cfg['tracked']                        = 0

citeulike = Citeulike.where(name: 'citeulike').first_or_create(
  :id          => 2,
  :type        => 'Citeulike',
  :name        => 'citeulike',
  :title       => 'CiteULike',
  :config      => citeulike_cfg,
  :group_id    => saved.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'CiteULike is a free social bookmarking service for scholarly content.',
  :queueable   => 1,
  :eventable   => 1)


crossref_cfg = OpenStruct.new
crossref_cfg['username'] = 'plos'
crossref_cfg['password'] = 'plos1'
crossref_cfg['url'] = 'http://doi.crossref.org/servlet/getForwardLinks?usr=%{username}&pwd=%{password}&doi=%{doi}'
crossref_cfg['default_url'] = 'http://www.crossref.org/openurl/?pid=%{pid}&id=doi:%{doi}&noredirect=true'
crossref_cfg['job_batch_size']                 = 200
crossref_cfg['batch_time_interval']            = 3600
crossref_cfg['rate_limiting']                  = 70000
crossref_cfg['wait_time']                      = 300
crossref_cfg['staleness_week']                 = 86400
crossref_cfg['staleness_month']                = 86400
crossref_cfg['staleness_year']                 = 648000
crossref_cfg['staleness_all']                  = 2592000
crossref_cfg['timeout']                        = 90
crossref_cfg['max_failed_queries']             = 200
crossref_cfg['max_failed_query_time_interval'] = 86400
crossref_cfg['disable_delay']                  = 10
crossref_cfg['workers']                        = 10
crossref_cfg['priority']                       = 5
crossref_cfg['openurl'] = 'http://www.crossref.org/openurl/?pid=%{openurl_username}&id=doi:%{doi}&noredirect=true'
crossref_cfg['openurl_username']               = 'plos'
crossref_cfg['queue']                          = 'default'
crossref_cfg['tracked']                        = 0

crossref = CrossRef.where(name: 'crossref').first_or_create(
  :id          => 4,
  :type        => 'CrossRef',
  :name        => 'crossref',
  :title       => 'CrossRef',
  :config      => crossref_cfg,
  :group_id    => cited.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'CrossRef is a DOI Registration Agency for scholarly content.',
  :queueable   => 1,
  :eventable   => 1)


nature_cfg = OpenStruct.new
nature_cfg['api_key']             = '7jug74j8rh49n8rbn8atwyec'
nature_cfg['url']                 = 'http://blogs.nature.com/posts.json?doi = %{doi}'
nature_cfg['job_batch_size']      = 200
nature_cfg['batch_time_interval'] = 3600
nature_cfg['rate_limiting']       = 5000
nature_cfg['wait_time']           = 300
nature_cfg['staleness_week']      = 86400
nature_cfg['staleness_month']     = 86400
nature_cfg['staleness_year']      = 2592000
nature_cfg['staleness_all']       = 2592000
nature_cfg['timeout']             = 45
nature_cfg['max_failed_queries']  = 200
nature_cfg['max_failed_query_time_interval'] = 86400
nature_cfg['disable_delay']       = 10
nature_cfg['workers']             = 50
nature_cfg['priority']            = 6

nature = Nature.where(name: 'nature').first_or_create(
  :id          => 5,
  :type        => 'Nature',
  :name        => 'nature',
  :title       => 'Nature',
  :config      => nature_cfg,
  :group_id    => discussed.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'A science blogs aggregator.',
  :queueable   => 1,
  :eventable   => 1)


scopus_cfg = OpenStruct.new
scopus_cfg['username']            = 'AMBRA'
scopus_cfg['live_mode']           = 'true'
scopus_cfg['salt']                = 'Q)M4ha6:G1twpMxGvsnyj=iS0A!qvr!T'
scopus_cfg['partner_id']          = 'OIVxnoIl'
scopus_cfg['api_key']             = '788818e50c994eab70b681b2ed46c77a'
scopus_cfg['insttoken']           = 'b7efefd626fe2fc84fc97be1c48bdc06'
scopus_cfg['job_batch_size']      = 200
scopus_cfg['batch_time_interval'] = 3600
scopus_cfg['rate_limiting']       = 50000
scopus_cfg['wait_time']           = 300
scopus_cfg['staleness_week']      = 86400
scopus_cfg['staleness_month']     = 86400
scopus_cfg['staleness_year']      = 648000
scopus_cfg['staleness_all']       = 2592000
scopus_cfg['timeout']             = 30
scopus_cfg['max_failed_queries']  = 1000
scopus_cfg['max_failed_query_time_interval'] = 1800
scopus_cfg['disable_delay']       = 10
scopus_cfg['workers']             = 50
scopus_cfg['url'] = 'https://api.elsevier.com/content/search/index:SCOPUS?query=DOI(%{doi})'
scopus_cfg['queue']               = 'default'

scopus = Scopus.where(name: 'scopus').first_or_create(
  :id          => 8,
  :type        => 'Scopus',
  :name        => 'scopus',
  :title       => 'Scopus',
  :config      => scopus_cfg,
  :group_id    => cited.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'Scopus is an abstract and citation database of peer-reviewed literature.',
  :queueable   => 1,
  :eventable   => 0)


counter_cfg = OpenStruct.new
counter_cfg['url'] = 'http://www.plosreports.org/services/rest?method=usage.stats&doi=%{doi}'
counter_cfg['job_batch_size']      = 200
counter_cfg['batch_time_interval'] = 3600
counter_cfg['rate_limiting']       = 200000
counter_cfg['wait_time']           = 300
counter_cfg['staleness_week']      = 86400
counter_cfg['staleness_month']     = 86400
counter_cfg['staleness_year']      = 86400
counter_cfg['staleness_all']       = 86400
counter_cfg['timeout']             = 30
counter_cfg['max_failed_queries']  = 1000
counter_cfg['max_failed_query_time_interval'] = 86400
counter_cfg['disable_delay']       = 10
counter_cfg['workers']             = 50
counter_cfg['cron_line']           = '30 13 * * *'
counter_cfg['priority']            = 2
counter_cfg['queue']               = 'high'
counter_cfg['url_private'] = 'http://www.plosreports.org/services/rest?method=usage.stats&doi=%{doi}'

counter = Counter.where(name: 'counter').first_or_create(
  :id          => 9,
  :type        => 'Counter',
  :name        => 'counter',
  :title       => 'Counter',
  :config      => counter_cfg,
  :group_id    => viewed.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => '',
  :queueable   => 0,
  :eventable   => 0)


wos_cfg = OpenStruct.new
wos_cfg['url']                            = 'https://ws.isiknowledge.com/cps/xrpc'
wos_cfg['job_batch_size']                 = 200
wos_cfg['batch_time_interval']            = 3600
wos_cfg['rate_limiting']                  = 50000
wos_cfg['wait_time']                      = 300
wos_cfg['staleness_week']                 = 86400
wos_cfg['staleness_month']                = 86400
wos_cfg['staleness_year']                 = 648000
wos_cfg['staleness_all']                  = 2592000
wos_cfg['timeout']                        = 30
wos_cfg['max_failed_queries']             = 200
wos_cfg['max_failed_query_time_interval'] = 86400
wos_cfg['disable_delay']                  = 10
wos_cfg['workers']                        = 50
wos_cfg['queue']                          = 'default'
wos_cfg['url_private']                    = 'https://ws.isiknowledge.com/cps/xrpc'

wos = Wos.where(name: 'wos').first_or_create(
  :id          => 12,
  :type        => 'Wos',
  :name        => 'wos',
  :title       => 'Web of Science®',
  :config      => wos_cfg,
  :group_id    => cited.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'Web of Science is an online academic citation index.',
  :queueable   => 1,
  :eventable   => 0)


# TODO: salt pmc config?
pmc_cfg = OpenStruct.new
pmc_cfg['url']                            = 'http://lagotto-201.sfo.plos.org:5984/pmc_usage_stats/'
pmc_cfg['filepath']                       = '/home/alm/pmcdata/'
pmc_cfg['job_batch_size']                 = 200
pmc_cfg['batch_time_interval']            = 3600
pmc_cfg['rate_limiting']                  = 200000
pmc_cfg['wait_time']                      = 300
pmc_cfg['staleness_week']                 = 2592000
pmc_cfg['staleness_month']                = 2592000
pmc_cfg['staleness_year']                 = 2592000
pmc_cfg['staleness_all']                  = 2592000
pmc_cfg['timeout']                        = 30
pmc_cfg['max_failed_queries']             = 200
pmc_cfg['max_failed_query_time_interval'] = 86400
pmc_cfg['disable_delay']                  = 10
pmc_cfg['username']                       = 'plospubs'
pmc_cfg['password']                       = 'er56nm'
pmc_cfg['workers']                        = 50
pmc_cfg['cron_line']                      = '0 5 9 * *'
pmc_cfg['priority']                       = 5
pmc_cfg['queue']                          = 'high'
pmc_cfg['journals']   = 'plosbiol plosmed ploscomp plosgen plospath plosone plosntd plosct ploscurrents'
pmc_cfg['db_url']     = 'http://lagotto-201.sfo.plos.org:5984/pmc_usage_stats/'
pmc_cfg['feed_url']   = 'https://www.ncbi.nlm.nih.gov/pmc/utils/publisher/pmcstat/pmcstat.cgi'
pmc_cfg['events_url'] = 'http://www.ncbi.nlm.nih.gov/pmc/articles/PMC%{pmcid}'
pmc_cfg['url_db']     = 'http://lagotto-201.sfo.plos.org:5984/pmc_usage_stats/'

pmc = Pmc.where(name: 'pmc').first_or_create(
  :id          => 13,
  :type        => 'Pmc',
  :name        => 'pmc',
  :title       => 'PMC Usage Stats',
  :config      => pmc_cfg,
  :group_id    => viewed.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => '',
  :queueable   => 0,
  :eventable   => 0)


facebook_cfg = OpenStruct.new

facebook_cfg['api_key']      = '318375554854773|tNMX2gWP_tTaah0p1Nf4ZFF4A5Q'
facebook_cfg['url']          = 'https://graph.facebook.com/v2.1/?access_token=%{access_token}&id=%{query_url}'
facebook_cfg['access_token'] = '318375554854773|tNMX2gWP_tTaah0p1Nf4ZFF4A5Q'

facebook_cfg['job_batch_size']                 = 200
facebook_cfg['batch_time_interval']            = 3600
facebook_cfg['rate_limiting']                  = 100000
facebook_cfg['wait_time']                      = 300
facebook_cfg['staleness_week']                 = 86400
facebook_cfg['staleness_month']                = 86400
facebook_cfg['staleness_year']                 = 648000
facebook_cfg['staleness_all']                  = 2592000
facebook_cfg['timeout']                        = 30
facebook_cfg['max_failed_queries']             = 3000
facebook_cfg['max_failed_query_time_interval'] = 86400
facebook_cfg['disable_delay']                  = 10
facebook_cfg['workers']                        = 50
facebook_cfg['count_limit']                    = 20000
facebook_cfg['priority']                       = 2

facebook_cfg['linkstat_url'] = 
    "https://graph.facebook.com/fql?access_token=%{access_token}&q=select\n" \
    "url,share_count,like_count,comment_count,click_count,total_count from link_stat\n " \
    "where url='%{query_url}'"

facebook_cfg['authentication_url'] = 'https://graph.facebook.com/oauth/access_token?client_id = %{client_id}&client_secret = %{client_secret}&grant_type = client_credentials'
facebook_cfg['client_id']          = ''
facebook_cfg['client_secret']      = ''
facebook_cfg['queue']              = 'default'

facebook_cfg['url_linkstat'] =
    "https://graph.facebook.com/fql?access_token=%{access_token}&q=select\n" \
    "url, share_count, like_count, comment_count, click_count, total_count from link_stat\n" \
    "where url = '%{query_url}'"

facebook = Facebook.where(name: 'facebook').first_or_create(
  :id          => 15,
  :type        => 'Facebook',
  :name        => 'facebook',
  :title       => 'Facebook',
  :config      => facebook_cfg,
  :group_id    => discussed.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'Facebook is the largest social network.',
  :queueable   => 1,
  :eventable   => 0)

#
# PUBLISHER_OPTIONS 
#
crossref_po_cfg = OpenStruct.new
crossref_po_cfg['username'] = 'plos'
crossref_po_cfg['password'] = 'plos1'

crossref_po = PublisherOption.where(source_id: crossref.id).where(publisher_id: 340).first_or_create(
  :publisher_id => 340,
  :source_id => crossref.id,
  :config => crossref_po_cfg)

pmc_po_cfg = OpenStruct.new
pmc_po_cfg['journals'] = 'plosbiol plosmed ploscomp plosgen plospath plosone plosntd plosct ploscurrents'
pmc_po_cfg['username'] = 'plospubs'
pmc_po_cfg['password'] = 'er56nm'

pmc = PublisherOption.where(source_id: 13).where(publisher_id: 340).first_or_create(
  :publisher_id => 340,
  :source_id => pmc.id,
  :config => pmc_po_cfg)
