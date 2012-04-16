module ApplicationHelper
  def link_to_setup_or_login
    if User.count > 0
      link_to "Login", new_user_session_path, :class => current_page?(new_user_session_path) ? 'current' : ''
    else
      link_to 'Setup', new_user_registration_path, :class => current_page?(new_user_registration_path) ? 'current' : ''
    end
  end
end
