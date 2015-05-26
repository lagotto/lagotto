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
      token = params[:api_key].presence
      user = token && User.where(authentication_token: token).first

      if user && Devise.secure_compare(user.authentication_token, token)
        sign_in user, store: false
      else
        current_user = false
      end
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

    def create_notification(exception, options = {})
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

    rescue_from *RESCUABLE_EXCEPTIONS do |exception|
      status = case exception.class.to_s
               when "CanCan::AccessDenied" then 401
               when "ActiveRecord::RecordNotFound" then 404
               when "ActiveModel::ForbiddenAttributesError", "NoMethodError" then 422
               else 400
               end

      if status == 404
        message = "The page you are looking for doesn't exist."
      elsif status == 401
        message = "You are not authorized to access this page."
      else
        create_notification(exception, status: status)
        message = exception.message
      end

      respond_to do |format|
        format.html do
          if /(jpe?g|png|gif|css)/i == request.path
            render text: message, status: status
          else
            @notification = Alert.where(message: message).where(unresolved: true).first_or_initialize(
              status: status)
            render "notifications/show", status: status
          end
        end
        format.xml { render xml: { error: message }.to_xml, status: status }
        format.rss { render :show, status: status, layout: false }
        format.all { render json: { meta: { status: "error", error: message }}, status: status }
      end
    end
  end
end
