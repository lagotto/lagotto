class GroupsController < ApplicationController
  respond_to :html

  # GET /groups
  def index
    @groups = Group.order("name")
    respond_with @groups
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
    if @group.update_attributes(params[:group])
      flash[:notice] = 'Group was successfully updated.'
      redirect_to groups_path
    else
      render :edit
    end
  end

  # DELETE /groups/:id
  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    @group.delete
    flash[:notice] = 'Group was successfully deleted.'
    respond_with(@group)
  end

  # GET /groups/new
  def new
    @group = Group.new
    respond_with @group
  end

  # POST /groups
  def create
    @group = Group.new(params[:group])

    if @group.save
      flash[:notice] = 'Group was successfully created.'
      redirect_to groups_path
    else
      render :new
    end
  end
end
