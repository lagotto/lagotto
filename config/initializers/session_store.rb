# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: ENV['SESSION_KEY'], domain: ENV['SESSION_DOMAIN'], tld_length: 2
