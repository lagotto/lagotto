# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.

# no need to precompile CSS when using assets server
if ENV['CDN_HOST'].present?
  Rails.application.config.assets.precompile += %W( api_requests/*.js works/*.js relations/*.js deposits/*.js contributions/*.js sources/*.js agents/*.js contributors/*.js layouts/*.js publishers/*.js status/*.js api/*.js docs/*.js )
else
  Rails.application.config.assets.precompile += %W( api_requests/*.js works/*.js relations/*.js deposits/*.js contributions/*.js sources/*.js agents/*.js contributors/*.js layouts/*.js publishers/*.js status/*.js api/*.js docs/*.js #{ENV['MODE']}.css )
end
