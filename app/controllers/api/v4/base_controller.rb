class Api::V4::BaseController < ActionController::Base
  respond_to :json

  before_filter :default_format_json, :check_basic_authentication

  rescue_from CanCan::AccessDenied do |exception|
    @error = exception.message
    @article = nil
    render "error", :status => 401
  end

  rescue_from ActionController::ParameterMissing do |exception|
    @error = { exception.param => ['parameter is required'] }
    @article = nil
    render "error", :status => 422
  end

  rescue_from ActionController::UnpermittedParameters do |exception|
    @error = Hash[exception.params.map { |v| [v, ['unpermitted parameter']] }]
    @article = nil
    render "error", :status => 422
  end

  rescue_from NoMethodError do |exception|
    @error = "Undefined method."
    @article = nil
    render "error", :status => 422
  end

  def default_format_json
    request.format = :json if request.format.html?
  end

  def check_basic_authentication
    authenticate_or_request_with_http_basic do |username, password|
      resource = User.find_by_username(username)
      if resource && resource.valid_password?(password)
        sign_in :user, resource
      else
        @error = "You are not authorized to access this page."
        Alert.create(:exception => "", :class_name => "Net::HTTPUnauthorized",
                     :message => @error,
                     :target_url => request.original_url,
                     :remote_ip => request.remote_ip,
                     :user_agent => request.user_agent,
                     :content_type => request.formats.first.to_s,
                     :status => 401)
        render "error", :status => 401
      end
    end
  end
end
