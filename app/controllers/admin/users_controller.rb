class Admin::UsersController < Admin::ApplicationController

  respond_to :html
  
  def show
    load_user
    # filter query parameters, use "Home" if no match is found
    params[:id] = "Home" if params[:doc].nil?
    id = %w(Home Installation Setup Sources API Rake FAQ Version-History Roadmap Past-Contributors).detect { |s| s.casecmp(params[:id])==0 }
    @doc = { :title => id, :text => IO.read(Rails.root.join("docs/#{id}.md")) }
  end
  
  def index
    load_index
    respond_with @users
  end
  
  def update
    load_user
    @user.update_attributes(:role => params[:new_role])
    load_index
    respond_with(@users) do |format|  
      format.js { render :index }
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