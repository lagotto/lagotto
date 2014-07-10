class PublishersController < ApplicationController
  before_filter :load_publisher, :only => [ :show, :edit, :update, :destroy ]
  load_and_authorize_resource

  respond_to :html, :js

  protected

  def load_publisher
    @publisher = Publisher.find(params[:id])
  end
end
