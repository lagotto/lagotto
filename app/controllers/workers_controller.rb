class WorkersController < ApplicationController
  respond_to :html

  def index
    @workers = Worker.all
  end

  def show
    @worker = Worker.find(params[:id])
  end
end
