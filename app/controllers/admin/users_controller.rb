class Admin::UsersController < Admin::ApplicationController
  before_filter :load_user, :only => [ :show, :edit, :update, :destroy ]
  load_and_authorize_resource

  respond_to :html, :js

  def show
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
    # Admin updates user role
    if params[:user][:role]
      @user.update_attribute(:role, params[:user][:role])
      load_index
      respond_with(@users) do |format|
        format.js { render :index }
      end
    # User updates his account
    else
      if params[:user][:subscribe]
        report = Report.find(params[:user][:subscribe])
        @user.reports << report
      elsif params[:user][:unsubscribe]
        report = Report.find(params[:user][:unsubscribe])
        @user.reports.delete(report)
      else
        sign_in @user, :bypass => true if @user.update_attributes(safe_params)
      end

      respond_with(@user) do |format|
        format.js { render :show }
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
    @user = User.find(params[:id])
    @reports = Report.available(@user.role)
    @doc = Doc.find("api")
  end

  def load_index
    collection = User
    if params[:role]
      collection = collection.where(:role => params[:role])
      @role = params[:role]
    end
    collection = collection.query(params[:query]) if params[:query]
    collection = collection.ordered

    @users = collection.paginate(:page => params[:page])
  end

  private

  def safe_params
    params.require(:user).permit(:name, :username, :email, :password, :password_confirmation, :subscribe, :unsubscribe)
  end
end
