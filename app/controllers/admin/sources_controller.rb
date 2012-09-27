class Admin::SourcesController < Admin::ApplicationController
  
  def show
    @source = Source.find(params[:id])
    @samples = @source.retrieval_statuses.most_cited_sample

    respond_with @source
  end

  def edit
    @source = Source.find(params[:id])
    respond_with(@source) do |format|  
      format.js { render :show }
    end
  end


  def update
    @source = Source.find(params[:id])
    @samples = @source.retrieval_statuses.most_cited_sample
    @source.update_attributes(params[:source])   
    respond_with(@source) do |format|  
      format.js { render :show }
    end
  end
end