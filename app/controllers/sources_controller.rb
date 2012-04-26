class SourcesController < ApplicationController
  before_filter :authenticate_user!, :except => [ :index ]

  respond_to :html

  def index
    @sources = Source.order(:display_name)
    respond_with @sources
  end

  def show
    @source = Source.find(params[:id])
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
