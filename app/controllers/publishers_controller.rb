class PublishersController < ApplicationController
  before_filter :load_publisher, :only => [ :show, :edit, :update, :destroy ]
  load_and_authorize_resource

  respond_to :html, :js

  def index
    load_index
    respond_with @publishers
  end

  def destroy
    @publisher.destroy
    load_index
    respond_with(@publishers) do |format|
      format.js { render :index }
    end
  end

  protected

  def load_publisher
    @publisher = Publisher.find(params[:id])
  end

  def load_index
    publisher = Publisher.new
    collection = publisher.query(params[:query])

    @publishers = collection.paginate(:page => params[:page])
  end
end
