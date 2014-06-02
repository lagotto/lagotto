class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def persona
    @user = User.find_for_persona_oauth(request.env["omniauth.auth"], current_user) if request.env["omniauth.auth"]

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication # this will throw if @user is not activated
    else
      session["devise.persona_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end

  def cas
    @user = User.find_for_cas_oauth(request.env["omniauth.auth"], current_user) if request.env["omniauth.auth"]

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication # this will throw if @user is not activated
    else
      session["devise.cas_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end
end
