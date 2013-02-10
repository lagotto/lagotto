class Admin::SourcesController < Admin::ApplicationController
  
  def show
    @source = Source.find_by_name(params[:id])
    respond_with @source
  end
  
  def index
    @groups = Group.includes(:sources).order("groups.id, sources.display_name")
    respond_with @groups
  end

  def edit
    @source = Source.find_by_name(params[:id])
    respond_with(@source) do |format|  
      format.js { render :show }
    end
  end


  def update
    @source = Source.find_by_name(params[:id])
    @source.update_attributes(params[:source])   
    respond_with(@source) do |format|  
      format.js { render :show }
    end
  end
end