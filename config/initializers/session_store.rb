# Be sure to restart your server when you modify this file.

#Rails.application.config.session_store ActionDispatch::Session::CacheStore
Rails.application.config.session_store ActionDispatch::Session::CookieStore

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Alm::Application.config.session_store :active_record_store
