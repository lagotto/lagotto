# Check for required ENV variables, can be set in .env file
# ENV_VARS is hash of required ENV variables
env_vars = [
    'ADMIN_EMAIL',
    'API_KEY',
    'CONCURRENCY',
    'DATABASE_URL',
    'HOSTNAME',
    'MAIL_ADDRESS',
    'MAIL_DOMAIN',
    'MAIL_PORT',
    'OMNIAUTH',
    'SECRET_KEY_BASE',
    'SERVERNAME',
    'SERVERS',
    'SITENAME',
    'SOLR_URL',
]
env_vars.each { |env| fail ArgumentError,  "ENV[#{env}] is not set" if ENV[env].blank? }
ENV_VARS = Hash[env_vars.map { |env| [env, ENV[env]] }]
