class Api::V3::BaseController < ActionController::Base

  respond_to :json, :xml

  before_filter :default_format_json, :after_token_authentication, :cors_preflight_check
  after_filter :cors_set_access_control_headers

  rescue_from CanCan::AccessDenied do |exception|
    @error = exception.message
    @article = nil
    render "error", :status => 401
  end

  def default_format_json
    request.format = :json if request.format.html?
  end

  def after_token_authentication
    if params[:api_key].present?
      @user = User.find_by_authentication_token(params[:api_key])
      sign_in @user if @user
    else
      @error = "Missing API key."
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