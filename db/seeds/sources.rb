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

# Bloglines
bloglines_cfg = OpenStruct.new
bloglines_cfg['username'] = 'admin@plos.org'
bloglines_cfg['password'] = '1D556489390DB3E4DA0F6D97A9AB4949'
bloglines_cfg['url'] = 'http://www.bloglines.com/search?format=publicapi&apiuser=%{username}&apikey=%{password}&q=%{title}'

bloglines = Bloglines.where(name: 'bloglines').first_or_create(
  :type        => 'Bloglines',
  :name        => 'bloglines',
  :title       => 'Bloglines',
  :config      => bloglines_cfg,
  :group_id    => other.id,
  :private     => 0,
  :state_event => 'inactivate',
  :queueable   => 1,
  :eventable   => 1)

# CiteULike 
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

#TODO: salt
# PMC Usage Stats
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
    "https://graph.facebook.com/fql?access_token=%{access_token}&q=select " \
    "url,share_count,like_count,comment_count,click_count,total_count from link_stat " \
    "where url='%{query_url}'"

facebook_cfg['authentication_url'] = 'https://graph.facebook.com/oauth/access_token?client_id = %{client_id}&client_secret = %{client_secret}&grant_type = client_credentials'
facebook_cfg['client_id']          = ''
facebook_cfg['client_secret']      = ''
facebook_cfg['queue']              = 'default'

facebook_cfg['url_linkstat'] =
    "https://graph.facebook.com/fql?access_token=%{access_token}&q=select " \
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
mendeley_cfg['url_with_title']       = 'https://api-oauth2.mendeley.com/oapi/documents/search/%{title}/?items = 10'
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
#TODO: salt twitter config
twitter_cfg = OpenStruct.new
twitter_cfg['url'] = 'http://lagotto-201.sfo.org:5984/plos-tweetstream/_design/tweets/_view/by_doi?key="%{doi}"'
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
twitter_cfg['url_private'] = 'http://lagotto-201.sfo.org:5984/plos-tweetstream/_design/tweets/_view/by_doi?key="%{doi}"'
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
wikipedia_cfg['url'] = 'http://%{host}/w/api.php?action=query&list=search&format=json&srsearch=%{query_string}&srnamespace=0&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=1'
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
wikipedia_cfg['events_url'] = 'http://en.wikipedia.org/w/index.php?search=%{query_string}'
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
#TODO: salt
relativemetric_cfg = OpenStruct.new
relativemetric_cfg['url'] = 'http://lagotto-201.sfo.plos.org:5984/relative_metrics/_design/relative_metric/_view/average_usage?key="%{doi}"'
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
relativemetric_cfg['url_private'] = 'http://lagotto-201.sfo.plos.org:5984/relative_metrics/_design/relative_metric/_view/average_usage?key="%{doi}"'
relativemetric_cfg['tracked']     = '0'

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

#TODO: salt
# F1000
f1000_cfg = OpenStruct.new
f1000_cfg['url'] = 'http://linkout.export.f1000.com.s3.amazonaws.com/linkout/PLOS-intermediate.xml'
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
f1000_cfg['db_url']   = 'http://lagotto-201.sfo.plos.org:5984/f1000/'
f1000_cfg['feed_url'] = 'http://linkout.export.f1000.com.s3.amazonaws.com/linkout/PLOS-intermediate.xml'
f1000_cfg['queue']    = 'default'
f1000_cfg['url_db']   = 'http://lagotto-201.sfo.plos.org:5984/f1000/'
f1000_cfg['url_feed'] = 'http://linkout.export.f1000.com.s3.amazonaws.com/linkout/PLOS-intermediate.xml'
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
  :description => 'Figures, tables and supplementary files hosted by figshare',
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
wordpress_cfg['tracked'] = '0'

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
reddit_cfg['queue']      = 'low'
reddit_cfg['tracked']    = '0'

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

#TODO: salt
# Article Coverage Curated
articlecoveragecurated_cfg = OpenStruct.new
articlecoveragecurated_cfg['workers']             = 50
articlecoveragecurated_cfg['url']                 = 'http://mediacuration-101.soma.plos.org/api/v1?doi = %{doi}'
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
articlecoveragecurated_cfg['url_private']   = 'http://mediacuration-101.soma.plos.org/api/v1?doi = %{doi}'
articlecoveragecurated_cfg['tracked']       = '0'

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
plos_comments_cfg['tracked']       = '0'

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
