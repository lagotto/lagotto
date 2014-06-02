if CONFIG[:mail]
  ActionMailer::Base.smtp_settings = {
    :address              => CONFIG[:mail]["address"],
    :port                 => CONFIG[:mail]["port"],
    :domain               => CONFIG[:mail]["domain"],
    :user_name            => CONFIG[:mail]["user_name"],
    :password             => CONFIG[:mail]["password"],
    :authentication       => CONFIG[:mail]["authentication"],
    :enable_starttls_auto => true,
    :openssl_verify_mode  => 'none'
  }
end
