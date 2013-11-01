if APP_CONFIG['mail']
  ActionMailer::Base.smtp_settings = {
    :address              => APP_CONFIG['mail']['address'],
    :port                 => APP_CONFIG['mail']['port'],
    :domain               => APP_CONFIG['mail']['domain'],
    :user_name            => APP_CONFIG['mail']['user_name'],
    :password             => APP_CONFIG['mail']['password'],
    :authentication       => APP_CONFIG['mail']['authentication'],
    :enable_starttls_auto => true
  }
end

ActionMailer::Base.register_interceptor( DevelopmentMailInterceptor ) if Rails.env.development?
