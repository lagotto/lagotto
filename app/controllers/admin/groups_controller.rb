class Admin::GroupsController < Admin::ApplicationController
  
  # GET /groups
  def index
    @groups = Group.order("name")
    redirect_to admin_root_path
  end

  # GET /groups/:id
  def show
    @group = Group.find(params[:id])
    respond_with @group
  end

  # GET /groups/:id/edit
  def edit
    @group = Group.find(params[:id])
  end

  # PUT /groups/:id
  def update
    @group = Group.find(params[:id])
    flash[:notice] = 'Group was successfully updated.' if @group.update_attributes(params[:group])
    redirect_to admin_root_path
  end

  # DELETE /groups/:id
  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    @group.delete
    flash[:notice] = 'Group was successfully deleted.'
    redirect_to admin_root_path
  end

  # GET /groups/new
  def new
    @group = Group.new(:name => "Test")
  end

  # POST /groups
  def create
    @group = Group.new(params[:group])
    flash[:notice] = 'Group was successfully created.' if @group.save
    redirect_to admin_root_path
  end
  
end