class Admin::UsersController < Admin::ApplicationController
  
  load_and_authorize_resource

  respond_to :html, :js
  
  def show
    load_user
    # filter query parameters, use "Home" if no match is found
    params[:id] = "Home" if params[:doc].nil?
    id = %w(Home Installation Setup Sources API Rake FAQ Version-History Roadmap Past-Contributors).detect { |s| s.casecmp(params[:id])==0 }
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
    load_user
    respond_with(@user) do |format|  
      format.js { render :show }
    end
  end
  
  def update
    load_user
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
  
  protected
  def load_user
    if user_signed_in?
      @user = current_user
    else
      raise CanCan::AccessDenied.new("Please sign in first.", :read, User)
    end
  end
  
  def destroy
    load_user
    @user.destroy
    load_index
    respond_with(@users) do |format|  
      format.js { render :index }
    end
  end
  
  protected
  def load_user
    @user = User.where(:username => params[:id]).first
    
    # raise error if user wasn't found
    raise ActiveRecord::RecordNotFound.new if @user.blank?
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