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

    def authenticate_user_from_token_param!
      user_token = params[:api_key].presence
      user = user_token && User.where(authentication_token: user_token.to_s).first
      sign_in user, store: false if user
    end

    # looking for header "Authorization: Token token=12345"
    def authenticate_user_from_token!
      authenticate_with_http_token do |token, options|
        user = token && User.where(authentication_token: token).first

        if user && Devise.secure_compare(user.authentication_token, token)
          sign_in user, store: false
        else
          current_user = false
        end
      end
    end

    def create_alert(exception, options = {})
      Alert.where(message: exception.message).where(unresolved: true).first_or_create(
        exception: exception,
        status: options[:status])
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

    def disable_devise_trackable
      request.env["devise.skip_trackable"] = true
    end

    rescue_from CanCan::AccessDenied do |exception|
      render json: { meta: { status: "error", error: exception.message }}, status: 401
    end

    rescue_from ActiveRecord::RecordNotFound do |exception|
      render json: { meta: { status: "error", error: exception.message }}, status: 404
    end

    rescue_from ActionController::ParameterMissing do |exception|
      create_alert(exception, status: 400)
      render json: { meta: { status: "error", error: exception.message }}, status: 400
    end

    rescue_from ActiveModel::ForbiddenAttributesError do |exception|
      create_alert(exception, status: 422)
      render json: { meta: { status: "error", error: exception.message }}, status: 422
    end

    rescue_from NoMethodError do |exception|
      create_alert(exception, status: 422)

      render json: { meta: { status: "error", error: exception.message }}, status: 422
    end
  end
end
