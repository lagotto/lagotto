class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def cas
    @user = User.find_for_cas_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
    else
      session["devise.cas_data"] = request.env["omniauth.auth"]
      redirect_to root_url
    end
  end

  def github
    @user = User.find_for_github_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
    else
      session["devise.github_data"] = request.env["omniauth.auth"]
      redirect_to root_url
    end
  end

  def persona
    @user = User.find_for_persona_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
    else
      session["devise.persona_data"] = request.env["omniauth.auth"]
      redirect_to root_url
    end
  end
end
