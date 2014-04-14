class Api::V5::BaseController < ActionController::Base
  respond_to :json

  before_filter :default_format_json, :authenticate_user_from_token!, :cors_preflight_check
  after_filter :cors_set_access_control_headers

  rescue_from CanCan::AccessDenied do |exception|
    @error = exception.message
    @article = nil
    render "error", :status => 401
  end

  def default_format_json
    request.format = :json if request.format.html?
  end

  def authenticate_user_from_token!
    user_token = params[:api_key].presence
    user       = user_token && User.find_by_authentication_token(user_token.to_s)

    if user
      sign_in user, store: false
    else
      @error = "Missing or wrong API key."
      Alert.create(:exception => "",
                   :class_name => "Net::HTTPUnauthorized",
                   :message => @error,
                   :target_url => request.original_url,
                   :remote_ip => request.remote_ip,
                   :user_agent => request.user_agent,
                   :content_type => request.formats.first.to_s,
                   :status => 401)
      render "error", :status => 401
    end
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
end
