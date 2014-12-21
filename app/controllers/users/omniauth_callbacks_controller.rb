class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  redirect to home page if login fails
  rescue_from ActiveRecord::RecordInvalid do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def persona
    auth = request.env["omniauth.auth"]
    auth.info.name = auth.info.email
    @user = User.from_omniauth(auth)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication # this will throw if @user is not activated
    else
      session["devise.persona_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end

  def cas
    auth = request.env["omniauth.auth"]
    auth.info.name = auth.extra.name
    auth.info.email = auth.extra.email
    @user = User.from_omniauth(auth)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication # this will throw if @user is not activated
    else
      session["devise.cas_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end

  def github
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication # this will throw if @user is not activated
    else
      session["devise.github_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end

  def orcid
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication # this will throw if @user is not activated
    else
      session["devise.orcid_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end
end
