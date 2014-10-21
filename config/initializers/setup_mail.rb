ActionMailer::Base.smtp_settings = {
  :address              => ENV['MAIL_ADDRESS'],
  :port                 => ENV['MAIL_PORT'],
  :domain               => ENV['MAIL_DOMAIN'],
  :user_name            => ENV['MAIL_USERNAME'],
  :password             => ENV['MAIL_PASSWORD'],
  :authentication       => ENV['MAIL_AUTHENTICATION'],
  :enable_starttls_auto => true,
  :openssl_verify_mode  => 'none'
}
