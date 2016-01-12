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

    @users = collection.paginate(page: (params[:page] || 1).to_i)
  end

  private

  def safe_params
    params.require(:user).permit(:name,
                                 :email,
                                 :subscribe,
                                 :unsubscribe,
                                 :role,
                                 :publisher_id,
                                 :authentication_token)
  end
end
