class Rss::WorksController < ApplicationController
  before_filter :load_work

  def show
    format_options = params.slice :source

    @page = params[:page] || 1
    @source = Source.active.where(name: params[:source_id]).first
    @relation_type = RelationType.where(name: params[:relation_type_id]).first

    render :show
  end

  protected

  def load_work
    # Load one work given query params
    id_hash = get_id_hash(params[:id])
    if id_hash.respond_to?("key")
      key, value = id_hash.first
      @work = Work.where(key => value).first
    else
      @work = nil
    end
    fail ActiveRecord::RecordNotFound unless @work.present?
  end
end
