module Authenticable
  extend ActiveSupport::Concern

  included do
    def default_format_json
      request.format = :json if request.format.html?
    end

    # from https://github.com/spree/spree/blob/master/api/app/controllers/spree/api/base_controller.rb
    def set_jsonp_format
      if params[:callback] && request.get?
        self.response_body = "#{params[:callback]}(#{response.body})"
        headers["Content-Type"] = 'application/javascript'
      end
    end

    def authenticate_user_from_token!
      user_token = params[:api_key].presence
      user       = user_token && User.where(authentication_token: user_token.to_s).first

      if user
        sign_in user, store: false
      else
        @error = "Missing or wrong API key."
        render "error", :status => 401
      end
    end

    def authenticate_user_via_basic_authentication!
      authenticate_or_request_with_http_basic do |username, password|
        resource = User.where(username: username).first
        if resource && resource.valid_password?(password)
          sign_in :user, resource
        else
          @error = "You are not authorized to access this page."
          render "error", :status => 401
        end
      end
    end

    def create_alert(exception, options = {})
      Alert.create(exception: exception, status: options[:status])
    end

    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Max-Age'] = "1728000"
    end

    def cors_preflight_check
      if request.method == :options
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
        headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
        headers['Access-Control-Max-Age'] = '1728000'
        render :text => '', :content_type => 'text/plain'
      end
    end

    rescue_from CanCan::AccessDenied do |exception|
      @error = exception.message
      @article = nil
      render "error", :status => 401
    end

    rescue_from ActionController::ParameterMissing do |exception|
      @error = { exception.param => ['parameter is required'] }
      @article = nil
      create_alert(exception, status: 422)
      render "error", :status => 422
    end

    rescue_from ActiveModel::ForbiddenAttributesError do |exception|
      @error = Hash[exception.params.map { |v| [v, ['unpermitted parameter']] }]
      @article = nil
      create_alert(exception, status: 422)
      render "error", :status => 422
    end

    rescue_from NoMethodError do |exception|
      @error = "Undefined method."
      @article = nil
      create_alert(exception, status: 422)
      render "error", :status => 422
    end
  end
end
