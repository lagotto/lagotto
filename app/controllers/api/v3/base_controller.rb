class Api::V3::BaseController < ActionController::Base

  respond_to :json, :xml

  before_filter :default_format_json, :after_token_authentication

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
    elsif request.remote_ip.to_s == '127.0.0.1'
      # don't require API key for requests from localhost
    else
      @error = "Missing API key."
      ErrorMessage.create(:exception => "", :class_name => "Net::HTTPUnauthorized",
                          :message => @error,
                          :target_url => request.original_url,
                          :user_agent => request.user_agent,
                          :content_type => request.formats.first.to_s,
                          :status => 401)
      render "error", :status => 401
    end
  end
end
