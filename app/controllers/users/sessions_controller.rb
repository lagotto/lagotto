class Users::SessionsController < ApplicationController
  def index
  end
  
  def new
  end
  
  def destroy
    sign_out
    redirect_to root_url
  end
end