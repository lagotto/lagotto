couch_base_url = ENV['COUCH_DB_URL'] || 'http://127.0.0.1'
pmc_couch_url            = couch_base_url + '/pmc_usage_stats'
twitter_couch_url        = couch_base_url + '/plos-tweetstream/_design/tweets/_view/by_doi?key="%{doi}"'
relativemetric_couch_url = couch_base_url + '/relative_metrics/_design/relative_metric/_view/average_usage?key="%{doi}"'
f1000_couch_url          = couch_base_url + '/f1000'

mediacuration_base_url = ENV['MEDIACURATION_URL'] || 'http://127.0.0.1'
mediacuration_url  = mediacuration_base_url + '/api/v1?doi=%{doi}'

camouflage = '10.136.104.162'

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

# Simple source for testing
simple_source_cfg = OpenStruct.new
simple_source_cfg['total'] = 5
simple_source = SimpleSource.where(name: 'simplesource').first_or_create(
  :type        => 'SimpleSource',
  :name        => 'simplesource',
  :title       => 'SimpleSource',
  :config      => simple_source_cfg,
  :group_id    => cited.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'SimpleSource is a mock source that always returns the same total.',
  :queueable   => 1,
  :eventable   => 1)

# CiteULike
citeulike_cfg = OpenStruct.new
citeulike_cfg['url'] = "http://#{ camouflage }/citeulike/api/posts/for/doi/%{doi}"
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
citeulike_cfg['events_url']                     = "http://#{ camouflage }/citeulike/doi/%{doi}"
citeulike_cfg['priority']                       = 6
citeulike_cfg['queue']                          = 'low'
citeulike_cfg['tracked']                        = 0

citeulike = Citeulike.where(name: 'citeulike').first_or_create(
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

# CrossRef
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

# Nature
nature_cfg = OpenStruct.new
nature_cfg['api_key']             = '7jug74j8rh49n8rbn8atwyec'
nature_cfg['url']                 = 'http://blogs.nature.com/posts.json?doi=%{doi}'
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

# Scopus
scopus_cfg = OpenStruct.new
scopus_cfg['username']            = 'AMBRA'
scopus_cfg['live_mode']           = true
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
scopus_cfg['url'] = "https://#{ camouflage }/scopus/content/search/index:SCOPUS?query=DOI(%{doi})"
scopus_cfg['queue']               = 'default'

scopus = Scopus.where(name: 'scopus').first_or_create(
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

# Counter
counter_cfg = OpenStruct.new
counter_cfg['url'] = "http://#{ camouflage }/counter/services/rest?method=usage.stats&doi=%{doi}"
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
counter_cfg['url_private'] = "http://#{ camouflage }/counter/services/rest?method=usage.stats&doi=%{doi}"

counter = Counter.where(name: 'counter').first_or_create(
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

# Web of Science
wos_cfg = OpenStruct.new
wos_cfg['url']                            = "https://#{ camouflage }/wos/cps/xrpc"
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
wos_cfg['url_private']                    = "https://#{ camouflage }/wos/cps/xrpc"

wos = Wos.where(name: 'wos').first_or_create(
  :type        => 'Wos',
  :name        => 'wos',
  :title       => 'Web of Science®',
  :config      => wos_cfg,
  :group_id    => cited.id,
  :private     => 1,
  :state_event => 'inactivate',
  :description => 'Web of Science is an online academic citation index.',
  :queueable   => 1,
  :eventable   => 0)

# PMC Usage Stats
pmc_cfg = OpenStruct.new
pmc_cfg['url']                            = pmc_couch_url
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
pmc_cfg['db_url']     = pmc_couch_url 
pmc_cfg['feed_url']   = "https://#{ camouflage }/pmc/pmc/utils/publisher/pmcstat/pmcstat.cgi"
pmc_cfg['events_url'] = "http://#{ camouflage }/pmc/pmc/articles/PMC%{pmcid}"
pmc_cfg['url_db']     = pmc_couch_url

pmc = Pmc.where(name: 'pmc').first_or_create(
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

# Facebook
facebook_cfg = OpenStruct.new
facebook_cfg['api_key']      = '318375554854773|tNMX2gWP_tTaah0p1Nf4ZFF4A5Q'
facebook_cfg['url']          = "https://#{ camouflage }/facebook/v2.1/?access_token=%{access_token}&id=%{query_url}"
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
    "https://#{ camouflage }/facebook/fql?access_token=%{access_token}&q=select " \
    "url,share_count,like_count,comment_count,click_count,total_count from link_stat " \
    "where url='%{query_url}'"

facebook_cfg['authentication_url'] = "https://#{ camouflage }/facebook/oauth/access_token?client_id=%{client_id}&client_secret=%{client_secret}&grant_type=client_credentials"
facebook_cfg['client_id']          = ''
facebook_cfg['client_secret']      = ''
facebook_cfg['queue']              = 'default'

facebook_cfg['url_linkstat'] =
    "https://#{ camouflage }/facebook/fql?access_token=%{access_token}&q=select " \
    "url, share_count, like_count, comment_count, click_count, total_count from link_stat " \
    "where url = '%{query_url}'"

facebook = Facebook.where(name: 'facebook').first_or_create(
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

# Mendeley
mendeley_cfg = OpenStruct.new
mendeley_cfg['api_key']              = 'dcd28c9a2ed8cd145533731ebd3278e504c06f3d5'
mendeley_cfg['url']                  = 'https://api.mendeley.com/catalog?%{query_string}&view=stats'
mendeley_cfg['url_with_type']        = 'https://api-oauth2.mendeley.com/oapi/documents/details/%{id}/?type=%{doc_type}'
mendeley_cfg['related_articles_url'] = 'https://api-oauth2.mendeley.com/oapi/documents/related/%{id}'
mendeley_cfg['url_with_title']       = 'https://api-oauth2.mendeley.com/oapi/documents/search/%{title}/?items=10'
mendeley_cfg['job_batch_size']                 = 200
mendeley_cfg['batch_time_interval']            = 3600
mendeley_cfg['rate_limiting']                  = 50000
mendeley_cfg['wait_time']                      = 300
mendeley_cfg['staleness_week']                 = 86400
mendeley_cfg['staleness_month']                = 86400
mendeley_cfg['staleness_year']                 = 648000
mendeley_cfg['staleness_all']                  = 2592000
mendeley_cfg['timeout']                        = 30
mendeley_cfg['max_failed_queries']             = 200
mendeley_cfg['max_failed_query_time_interval'] = 86400
mendeley_cfg['disable_delay']                  = 10
mendeley_cfg['workers']                        = 50
mendeley_cfg['authentication_url']             = 'https://api.mendeley.com/oauth/token'
mendeley_cfg['client_id']                      = '18'
mendeley_cfg['secret']                         = 'yE6$Hn5{D8:rD7i9'
mendeley_cfg['access_token']  = 'MSwxNDgxNzYwNzI4MDIzLCwxOCxhbGwsLE80RDVQeFlnSW55bG8xaDZubVdLRGlHMDdxbw'
mendeley_cfg['expires_at']    = '2016-12-14 16:12:09.007529279 -08:00'
mendeley_cfg['priority']      = 5
mendeley_cfg['client_secret'] = 'yE6$Hn5{D8:rD7i9'
mendeley_cfg['queue']         = 'default'

mendeley = Mendeley.where(name: 'mendeley').first_or_create(
  :type        => 'Mendeley',
  :name        => 'mendeley',
  :title       => 'Mendeley',
  :config      => mendeley_cfg,
  :group_id    => saved.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'Mendeley is a reference manager and social bookmarking tool.',
  :queueable   => 1,
  :eventable   => 0)

# Twitter
twitter_cfg = OpenStruct.new
twitter_cfg['url']                            = twitter_couch_url
twitter_cfg['job_batch_size']                 = 200
twitter_cfg['batch_time_interval']            = 3600
twitter_cfg['rate_limiting']                  = 200000
twitter_cfg['wait_time']                      = 300
twitter_cfg['staleness_week']                 = 21600
twitter_cfg['staleness_month']                = 86400
twitter_cfg['staleness_year']                 = 86400
twitter_cfg['staleness_all']                  = 648000
twitter_cfg['timeout']                        = 15
twitter_cfg['max_failed_queries']             = 200
twitter_cfg['max_failed_query_time_interval'] = 86400
twitter_cfg['disable_delay']                  = 10
twitter_cfg['workers']                        = 50
twitter_cfg['priority']                       = 2
twitter_cfg['queue']                          = 'high'
twitter_cfg['url_private']                    = twitter_couch_url
twitter_cfg['tracked']                        = '0'

twitter = Twitter.where(name: 'twitter').first_or_create(
  :type        => 'Twitter',
  :name        => 'twitter',
  :title       => 'Twitter',
  :config      => twitter_cfg,
  :group_id    => discussed.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'Twitter is an online social networking service and microblogging service.',
  :queueable   => 1,
  :eventable   => 1)

# Wikipedia
wikipedia_cfg = OpenStruct.new
wikipedia_cfg['url'] = "http://#{ camouflage }/wikipedia/w/api.php?action=query&list=search&format=json&srsearch=%{query_string}&srnamespace=0&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=1&lang=%{host}"
wikipedia_cfg['job_batch_size']                 = 200
wikipedia_cfg['batch_time_interval']            = 3600
wikipedia_cfg['rate_limiting']                  = 200000
wikipedia_cfg['wait_time']                      = 300
wikipedia_cfg['staleness_week']                 = 86400
wikipedia_cfg['staleness_month']                = 86400
wikipedia_cfg['staleness_year']                 = 648000
wikipedia_cfg['staleness_all']                  = 2592000
wikipedia_cfg['timeout']                        = 90
wikipedia_cfg['max_failed_queries']             = 200
wikipedia_cfg['max_failed_query_time_interval'] = 86400
wikipedia_cfg['disable_delay']                  = 10
wikipedia_cfg['workers']                        = 50
wikipedia_cfg['languages']  = 'en nl de sv fr it es pl war ceb ja vi pt zh uk ca no fi fa id cs ko hu ar commons'
wikipedia_cfg['priority']   = 5
wikipedia_cfg['events_url'] = "http://#{ camouflage }/wikipedia/w/index.php?search=%{query_string}&lang=en.wikipedia.org"
wikipedia_cfg['queue']      = 'default'
wikipedia_cfg['tracked']    = '0'

wikipedia = Wikipedia.where(name: 'wikipedia').first_or_create(
  :type        => 'Wikipedia',
  :name        => 'wikipedia',
  :title       => 'Wikipedia',
  :config      => wikipedia_cfg,
  :group_id    => discussed.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'Wikipedia is a free encyclopedia that everyone can edit.',
  :queueable   => 1,
  :eventable   => 1)

# Relative Metric
relativemetric_cfg = OpenStruct.new
relativemetric_cfg['url']                            = relativemetric_couch_url
relativemetric_cfg['solr_url']                       = 'http://api.plos.org/search'
relativemetric_cfg['job_batch_size']                 = 200
relativemetric_cfg['batch_time_interval']            = 3600
relativemetric_cfg['rate_limiting']                  = 200000
relativemetric_cfg['wait_time']                      = 300
relativemetric_cfg['staleness_week']                 = 86400
relativemetric_cfg['staleness_month']                = 86400
relativemetric_cfg['staleness_year']                 = 86400
relativemetric_cfg['staleness_all']                  = 86400
relativemetric_cfg['timeout']                        = 200
relativemetric_cfg['max_failed_queries']             = 1000
relativemetric_cfg['max_failed_query_time_interval'] = 3600
relativemetric_cfg['disable_delay']                  = 10
relativemetric_cfg['workers']                        = 50
relativemetric_cfg['cron_line']                      = '* 09 * * 2'
relativemetric_cfg['queue']                          = 'default'
relativemetric_cfg['url_private']                    = relativemetric_couch_url
relativemetric_cfg['tracked']                        = '0'

relativemetric = RelativeMetric.where(name: 'relativemetric').first_or_create(
  :type        => 'RelativeMetric',
  :name        => 'relativemetric',
  :title       => 'RelativeMetric',
  :config      => relativemetric_cfg,
  :group_id    => other.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'Relative metric gives context to the raw numbers that are collected.',
  :queueable   => 0,
  :eventable   => 1)

# F1000
f1000_cfg = OpenStruct.new
f1000_cfg['url'] = "http://#{ camouflage }/f1000/linkout/PLOS-intermediate.xml"
f1000_cfg['filename']                       = 'PLOS-intermediate.xml'
f1000_cfg['job_batch_size']                 = 200
f1000_cfg['batch_time_interval']            = 3600
f1000_cfg['rate_limiting']                  = 200000
f1000_cfg['wait_time']                      = 300
f1000_cfg['staleness_week']                 = 86400
f1000_cfg['staleness_month']                = 86400
f1000_cfg['staleness_year']                 = 648000
f1000_cfg['staleness_all']                  = 2592000
f1000_cfg['timeout']                        = 15
f1000_cfg['max_failed_queries']             = 1000
f1000_cfg['max_failed_query_time_interval'] = 86400
f1000_cfg['disable_delay']                  = 10
f1000_cfg['workers']                        = 50
f1000_cfg['cron_line']                      = '* 03 * * 3'
f1000_cfg['db_url']   = f1000_couch_url
f1000_cfg['feed_url'] = "http://#{ camouflage }/f1000/PLOS-intermediate.xml"
f1000_cfg['queue']    = 'default'
f1000_cfg['url_db']   = f1000_couch_url
f1000_cfg['url_feed'] = "http://#{ camouflage }/f1000/linkout/PLOS-intermediate.xml"
f1000_cfg['tracked']  = '0'

f1000 = F1000.where(name: 'f1000').first_or_create(
  :type        => 'F1000',
  :name        => 'f1000',
  :title       => 'F1000Prime',
  :config      => f1000_cfg,
  :group_id    => recommended.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'Post-publication peer review of the biomedical literature.',
  :queueable   => 0,
  :eventable   => 1)

# Figshare
figshare_cfg = OpenStruct.new
figshare_cfg['url'] = 'http://api.figshare.com/v1/publishers/search_for?doi=%{doi}'
figshare_cfg['job_batch_size']                 = 200
figshare_cfg['batch_time_interval']            = 3600
figshare_cfg['rate_limiting']                  = 50000
figshare_cfg['wait_time']                      = 300
figshare_cfg['staleness_week']                 = 86400
figshare_cfg['staleness_month']                = 86400
figshare_cfg['staleness_year']                 = 648000
figshare_cfg['staleness_all']                  = 2592000
figshare_cfg['timeout']                        = 30
figshare_cfg['max_failed_queries']             = 1000
figshare_cfg['max_failed_query_time_interval'] = 86400
figshare_cfg['disable_delay']                  = 10
figshare_cfg['workers']                        = 50
figshare_cfg['queue']                          = 'default'
figshare_cfg['url_private'] = 'http://api.figshare.com/v1/publishers/search_for?doi=%{doi}'

figshare = Figshare.where(name: 'f1000').first_or_create(
  :type        => 'Figshare',
  :name        => 'figshare',
  :title       => 'Figshare',
  :config      => figshare_cfg,
  :group_id    => viewed.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'Figures, tables and supplementary files hosted by figshare.',
  :queueable   => 1,
  :eventable   => 0)

# WordPress
wordpress_cfg = OpenStruct.new
wordpress_cfg['workers'] = 50
wordpress_cfg['url'] = 'http://en.search.wordpress.com/?q=%{query_string}&t=post&f=json&size=20'
wordpress_cfg['job_batch_size'] = 1000
wordpress_cfg['batch_time_interval'] = 3600
wordpress_cfg['rate_limiting'] = 1000
wordpress_cfg['wait_time'] = 300
wordpress_cfg['staleness_week'] = 2592000
wordpress_cfg['staleness_month'] = 2592000
wordpress_cfg['staleness_year'] = 2592000
wordpress_cfg['staleness_all'] = 2592000
wordpress_cfg['timeout'] = 30
wordpress_cfg['max_failed_queries'] = 10000
wordpress_cfg['max_failed_query_time_interval'] = 86400
wordpress_cfg['disable_delay'] = 10
wordpress_cfg['events_url'] = 'http://en.search.wordpress.com/?q=%{query_string}&t=post'
wordpress_cfg['priority'] = 6
wordpress_cfg['queue'] = 'low'

wordpress = Wordpress.where(name: 'wordpress').first_or_create(
  :type        => 'Wordpress',
  :name        => 'wordpress',
  :title       => 'Wordpress.com',
  :config      => wordpress_cfg,
  :group_id    => discussed.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'Wordpress.com is one of the largest blog hosting platforms.',
  :queueable   => 1,
  :eventable   => 1)

# Reddit
reddit_cfg = OpenStruct.new
reddit_cfg['workers'] = 50
reddit_cfg['url'] = 'http://www.reddit.com/search.json?q=%{query_string}&limit=100'
reddit_cfg['job_batch_size']                 = 200
reddit_cfg['batch_time_interval']            = 3600
reddit_cfg['rate_limiting']                  = 1800
reddit_cfg['wait_time']                      = 300
reddit_cfg['staleness_week']                 = 86400
reddit_cfg['staleness_month']                = 86400
reddit_cfg['staleness_year']                 = 648000
reddit_cfg['staleness_all']                  = 2592000
reddit_cfg['timeout']                        = 30
reddit_cfg['max_failed_queries']             = 200
reddit_cfg['max_failed_query_time_interval'] = 86400
reddit_cfg['disable_delay']                  = 10
reddit_cfg['events_url'] = 'http://www.reddit.com/search?q = %{query_string}'
reddit_cfg['priority']   = 6

reddit = Reddit.where(name: 'reddit').first_or_create(
  :type        => 'Reddit',
  :name        => 'reddit',
  :title       => 'Reddit',
  :config      => reddit_cfg,
  :group_id    => discussed.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'User-generated news links.',
  :queueable   => 1,
  :eventable   => 1)

# Article Coverage Curated
articlecoveragecurated_cfg = OpenStruct.new
articlecoveragecurated_cfg['workers']             = 50
articlecoveragecurated_cfg['url']                 = mediacuration_url
articlecoveragecurated_cfg['job_batch_size']      = 200
articlecoveragecurated_cfg['batch_time_interval'] = 3600
articlecoveragecurated_cfg['rate_limiting']       = 200000
articlecoveragecurated_cfg['wait_time']           = 300
articlecoveragecurated_cfg['staleness_week']      = 86400
articlecoveragecurated_cfg['staleness_month']     = 86400
articlecoveragecurated_cfg['staleness_year']      = 648000
articlecoveragecurated_cfg['staleness_all']       = 2592000
articlecoveragecurated_cfg['timeout']             = 30
articlecoveragecurated_cfg['max_failed_queries']  = 200
articlecoveragecurated_cfg['max_failed_query_time_interval'] = 86400
articlecoveragecurated_cfg['disable_delay'] = 10
articlecoveragecurated_cfg['priority']      = 2
articlecoveragecurated_cfg['queue']         = 'default'
articlecoveragecurated_cfg['url_private']   = mediacuration_url

articlecoveragecurated = ArticleCoverageCurated.where(name: 'articlecoveragecurated').first_or_create(
  :type        => 'ArticleCoverageCurated',
  :name        => 'articlecoveragecurated',
  :title       => 'Article Coverage Curated',
  :config      => articlecoveragecurated_cfg,
  :group_id    => discussed.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'Article Coverage Curated',
  :queueable   => 1,
  :eventable   => 1)

# PLOS Comments
# TODO: do not enable this source until the rhino endpoint has been updated
# to v2. diff the payloads too. (see PLT-577)
plos_comments_cfg = OpenStruct.new
plos_comments_cfg['job_batch_size']     = 200
plos_comments_cfg['workers']            = 50
plos_comments_cfg['rate_limiting']      = 200000
plos_comments_cfg['wait_time']          = 300
plos_comments_cfg['staleness_week']     = 86400
plos_comments_cfg['staleness_month']    = 86400
plos_comments_cfg['staleness_year']     = 648000
plos_comments_cfg['staleness_all']      = 2592000
plos_comments_cfg['timeout']            = 30
plos_comments_cfg['max_failed_queries'] = 200
plos_comments_cfg['max_failed_query_time_interval'] = 86400
plos_comments_cfg['disable_delay'] = 10
plos_comments_cfg['url']           = 'http://api.plosjournals.org/v1/articles/%{doi}?comments'
plos_comments_cfg['queue']         = 'default'
plos_comments_cfg['url_private']   = 'http://api.plosjournals.org/v1/articles/%{doi}?comments'

plos_comments = PlosComments.where(name: 'plos_comments').first_or_create(
  :type        => 'PlosComments',
  :name        => 'plos_comments',
  :title       => 'Journal Comments',
  :config      => plos_comments_cfg,
  :group_id    => discussed.id,
  :private     => 0,
  :state_event => 'inactivate',
  :description => 'Comments from the PLOS website.',
  :queueable   => 1,
  :eventable   => 1)

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
