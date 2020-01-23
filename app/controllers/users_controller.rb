class UsersController < ApplicationController
  before_filter :load_user, only: [:show, :edit, :destroy]
  load_and_authorize_resource

  def show
    respond_to do |format|
      format.js { render :show }
      format.html
    end
  end

  def index
    load_index
  end

  def edit
    if params[:id].to_i == current_user.id
      # user updates his account
      render :show
    else
      # admin updates user account
      @user = User.find(params[:id])
      @reports = Report.available(@user.role)
      @doc = Doc.find("api")
      load_index
      render :index
    end
  end

  def update
    if params[:id].to_i == current_user.id
      # user updates his account

      load_user

      if params[:user][:subscribe]
        report = Report.find(params[:user][:subscribe])
        @user.reports << report
      elsif params[:user][:unsubscribe]
        report = Report.find(params[:user][:unsubscribe])
        @user.reports.delete(report)
      else
        sign_in @user, :bypass => true if @user.update_attributes(safe_params)
      end

      render :show
    else
      # admin updates user account
      @user = User.find(params[:id])
      @user.update_attributes(safe_params)

      load_index
      render :index
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    load_index
    render :index
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
    allowed_params = [
      :name,
      :email,
      :password,
      :password_confirmation,
      :subscribe,
      :unsubscribe,
      :publisher_id,
      :authentication_token
    ]
    allowed_params << :role if current_user.try(:is_admin?)
    params.require(:user).permit(allowed_params)
  end
end
