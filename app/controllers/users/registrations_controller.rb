class Users::RegistrationsController < Devise::RegistrationsController

  def new
    redirect_to new_user_session_path if User.count > 0
  end
end
