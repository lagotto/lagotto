class Admin::SourcesController < ApplicationController
  
  before_filter :authenticate_user!
  respond_to :html
  
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
      redirect_to sources_url
    else
      render :edit
    end
  end
end