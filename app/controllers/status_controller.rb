class StatusController < ApplicationController
  def index
    @status = Status.new
  end
end
