class UsersController < ApplicationController
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

  def update_password
    load_user
    if @user.update_with_password(user_params)
      # Sign in the user by passing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to root_path
    else
      render "edit"
    end
  end

  protected

  # def load_user
  #   @user = User.find(params[:id])
  #   @reports = Report.available(@user.role)
  #   @doc = Doc.find("api")
  # end

  def load_user
    if user_signed_in?
      @user = current_user
      @reports = Report.available(@user.role)
      @doc = Doc.find("api")
    else
      fail CanCan::AccessDenied.new("Please sign in first.", :read, User)
    end
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
    params.require(:user).permit(:name, :username, :email, :password, :password_confirmation, :subscribe, :unsubscribe, :publisher_id)
  end
end
