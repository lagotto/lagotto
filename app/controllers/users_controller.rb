class UsersController < ApplicationController

  respond_to :html
  
  def show
    load_user
    @doc = { :title => "Getting Started", :text => IO.read(Rails.root.join("docs/Home.md")) }
  end
  
  def index
    redirect_to root_path
  end
  
  protected
  def load_user
    if user_signed_in?
      @user = current_user
    else
      raise CanCan::AccessDenied.new("Please sign in first.", :read, User)
    end
  end
end