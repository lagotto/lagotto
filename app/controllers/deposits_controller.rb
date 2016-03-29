class DepositsController < ApplicationController
  before_filter :load_work, only: [:show, :edit, :update, :destroy]
  before_filter :new_work, only: [:create]
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :index]

  def index
    if params[:state]
      states = { "waiting" => 0, "working" => 1, "failed" => 2, "done" => 3 }
      @state = states.fetch(params[:state], 0)
    end

    @page = (params[:page] || 1).to_i
    @q = params[:q]
    @source = cached_source(params[:source_id])
  end
end
