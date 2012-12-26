class Admin::SourcesController < Admin::ApplicationController
  
  def show
    @source = Source.find(params[:id])
    respond_with @source
  end
  
  def index
    @sources = Source.order("name")
    respond_with @sources
  end

  def edit
    @source = Source.find(params[:id])
    respond_with(@source) do |format|  
      format.js { render :show }
    end
  end


  def update
    @source = Source.find(params[:id])
    @source.update_attributes(params[:source])   
    respond_with(@source) do |format|  
      format.js { render :show }
    end
  end
end