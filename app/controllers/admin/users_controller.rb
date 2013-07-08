class Admin::UsersController < Admin::ApplicationController
  before_filter :load_user, :only => [ :show, :edit, :update, :destroy ]
  load_and_authorize_resource

  respond_to :html, :js
  
  def show
    # filter query parameters, use "Home" if no match is found
    params[:id] = "Home" if params[:doc].nil?
    id = %w(Home Installation Setup Sources API Rake Errors FAQ Roadmap Past-Contributors).detect { |s| s.casecmp(params[:id])==0 }
    @doc = { :title => id, :text => IO.read(Rails.root.join("docs/#{id}.md")) }
    respond_with(@user) do |format|  
      format.js { render :show }
    end
  end
  
  def index
    load_index
    respond_with @users
  end
  
  def edit
    respond_with(@user) do |format|  
      format.js { render :show }
    end
  end
  
  def update
    # User updates his account
    if params[:user][:email]
      sign_in @user, :bypass => true if @user.update_attributes(params[:user])
      respond_with(@user) do |format|  
        format.js { render :show }
      end
    else
      @user.update_attributes(params[:user])
      load_index
      respond_with(@users) do |format|  
        format.js { render :index }
      end
    end
  end
  
  def destroy
    @user.destroy
    load_index
    respond_with(@users) do |format|  
      format.js { render :index }
    end
  end
  
  protected
  def load_user
    @user = User.find_by_username(params[:id])
  end
  
  def load_index
    collection = User
    if params[:role]
      collection = collection.where(:role => params[:role]) 
      @role = params[:role]
    end
    collection = collection.query(params[:query]) if params[:query]
    
    @users = collection.paginate(:page => params[:page])
  end
end