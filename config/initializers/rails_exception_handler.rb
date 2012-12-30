RailsExceptionHandler.configure do |config|
  config.environments = [:development, :test, :production]
  config.fallback_layout = 'greenrobo'  
                        
  # config.after_initialize do
  #   # This block will be called after the initialization is done.
  #   # Usefull for interaction with authentication mechanisms, which should
  #   # only happen when the exception handler is enabled.
  # end
  
  config.filters = [
    # :all_404s,
    :no_referer_404s,
    # :anon_404s,
    # {:user_agent_regxp => /\b(ApptusBot|TurnitinBot|DotBot|SiteBot)\b/i},
    {:target_url_regxp => /\.php/i}
    # {:referer_url_regxp => /problematicreferer/i}
  ]

  config.responses = {
    :default => '<div class="content">
      <div class="page-header">
        <h1>500</h1>
      </div>
      <p>Internal server error</p>
    </div>',
    :not_found => '<div class="content">
      <div class="page-header">
        <h1>404</h1>
      </div>
      <p>Page not found</p>
    </div>',
    :wrong_token => '<div class="content">
      <div class="page-header">
        <h1>500</h1>
      </div>
      <p>There was a problem authenticating the submitted form. Reload the page and try again.</p>
    </div>'
  }
  
  config.response_mapping = {
   'ActiveRecord::RecordNotFound' => :not_found,
   'ActionController:RoutingError' => :not_found,
   'AbstractController::ActionNotFound' => :not_found,
   'ActionController::InvalidAuthenticityToken' => :wrong_token
  }

  config.storage_strategies = [:active_record]
  
  config.store_request_info do |storage,request|
    storage[:target_url] =    request.url
    storage[:referer_url] =   request.referer
    storage[:params] =        request.params.inspect
    storage[:user_agent] =    request.user_agent
  end

  config.store_exception_info do |storage,exception|
    storage[:class_name] =   exception.class.to_s
    storage[:message] =      exception.to_s
    storage[:trace] =        exception.backtrace.join("\n")
  end

  #config.store_environment_info do |storage,env|
  #  storage[:doc_root] =      env['DOCUMENT_ROOT']
  #end

  config.store_global_info do |storage|
    # storage[:app_name] =     Rails.application.class.parent_name
    storage[:created_at] =   Time.now
  end
  
  # config.store_user_info = {:method => :current_user, :field => :login} # Helper method for easier access to current_user
end
