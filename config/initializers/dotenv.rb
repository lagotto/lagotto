# Check for required ENV variables, can be set in .env file
# ENV_VARS is hash of required ENV variables
env_vars = %w{ DB_USERNAME DB_HOST HOSTNAME SERVERNAME SERVERS SITENAME COUCHDB_URL ADMIN_EMAIL CONCURRENCY API_KEY SECRET_KEY_BASE MAIL_ADDRESS MAIL_PORT MAIL_DOMAIN OMNIAUTH }
env_vars.each { |env| fail ArgumentError,  "ENV[#{env}] is not set" if ENV[env].blank? }
ENV_VARS = Hash[env_vars.map { |env| [env, ENV[env]] }]
