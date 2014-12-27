class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  rescue_from ActiveRecord::RecordInvalid do |exception|
    redirect_to root_path, :alert => exception.message
  end

  # generic handler for all omniauth providers
  def action_missing(provider)
    auth = request.env["omniauth.auth"]

    # provider-specific tweaks to standard omniauth hash
    case provider
    when "cas"
      auth.info.name = auth.extra.name
      auth.info.email = auth.extra.email
    end

    @user = User.from_omniauth(auth)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.#{provider}_data"] = request.env["omniauth.auth"]
      flash[:alert] = @user.errors.map{ |k,v| "#{k}: #{v}"}.join("<br />").html_safe || "Error signing in with #{provider}"
      redirect_to root_path
    end
  end
end
