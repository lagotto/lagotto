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

    # looking for header "Authorization: Token token=12345" where token is a jwt
    def authenticate_user_from_token!
      authenticate_with_http_token do |token, options|
        @current_user = User.new((JWT.decode token, ENV['JWT_SECRET_KEY']).first)
      end
    end

    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
      headers['Access-Control-Max-Age'] = "1728000"
    end

    rescue_from *RESCUABLE_EXCEPTIONS do |exception|
      status, message = case exception.class.to_s
        when "CanCan::AccessDenied", "JWT::DecodeError"
          [401, "You are not authorized to access this resource."]
        when "ActiveRecord::RecordNotFound"
          [404, "The resource you are looking for doesn't exist."]
        when "ActiveModel::ForbiddenAttributesError", "ActionController::UnpermittedParameters", "ActionController::ParameterMissing"
          [422, exception.message]
        when "NoMethodError"
          Rails.env.development? || Rails.env.test? ? [422, exception.message] : [422, "The request could not be processed."]
        else
          [400, exception.message]
        end

      respond_to do |format|
        format.all { render json: { errors: [{ status: status.to_s,
                                               title: message }]
                                  }, status: status
                   }
      end
    end

    private

    def current_user
      @current_user
    end
  end
end
