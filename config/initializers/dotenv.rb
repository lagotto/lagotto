# Check for required ENV variables, can be set in .env file

env_vars = %w{ DB_USERNAME DB_HOST HOSTNAME SERVERNAME SERVERS SITENAME COUCHDB_URL ADMIN_EMAIL WORKERS UID API_KEY SECRET_KEY_BASE MAIL_ADDRESS MAIL_PORT MAIL_DOMAIN }
env_vars.each { |env| fail ArgumentError,  "ENV[#{env}] is not set" if ENV[env].blank? }
