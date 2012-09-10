class Admin::SourcesController < Admin::ApplicationController
  
  def show
    @source = Source.find(params[:id])
    @samples = @source.retrieval_statuses.most_cited_sample

    respond_with @source
  end

  def edit
    @source = Source.find(params[:id])
  end

  def update
    @source = Source.find(params[:id])
    if @source.update_attributes(params[:source])
      flash[:notice] = 'Source was successfully updated.'
      redirect_to admin_source_path(@source)
    else
      render :edit
    end
  end
end