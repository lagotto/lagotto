class Admin::GroupsController < Admin::ApplicationController
  
  load_and_authorize_resource 
  
  # GET /groups
  def index
    @groups = Group.includes(:sources).order("groups.id, sources.display_name")
    respond_with do |format|  
      format.js { render :index }
    end
  end

  # GET /groups/:id/edit
  def edit
    @groups = Group.includes(:sources).order("groups.id, sources.display_name")
    @group = Group.find(params[:id])
    respond_with(@group) do |format|  
      format.js { render :index }
    end
  end

  # PUT /groups/:id
  def update
    @groups = Group.includes(:sources).order("groups.id, sources.display_name")
    @group = Group.find(params[:id])
    @group.update_attributes(params[:group])
    respond_with(@group) do |format|  
      format.js { render :index }
    end
  end

  # DELETE /groups/:id
  def destroy
    @groups = Group.includes(:sources).order("groups.id, sources.display_name")
    @group = Group.find(params[:id])
    @group.destroy
    respond_with(@group) do |format|  
      format.js { render :index }
    end
  end

  # GET /groups/new
  def new
    @group = Group.new
    respond_with(@group) do |format|  
      format.js { render :index }
    end
  end

  # POST /groups
  def create
    @groups = Group.includes(:sources).order("groups.id, sources.display_name")
    @group = Group.new(params[:group])
    @group.save
    respond_with(@group) do |format|  
      format.js { render :index }
    end
  end
  
end