class Api::V4::WorksController < Api::V4::BaseController
  # include works controller methods
  include Workable

  before_filter :load_work, only: [:update, :destroy]

  def create
    @work = Article.new(safe_params)
    authorize! :create, @work

    if @work.save
      @success = "Article created."
      render "success", :status => :created
    else
      @error = @work.errors
      render "error", :status => :bad_request
    end
  end

  def update
    authorize! :update, @work

    if @work.blank?
      @error = "No article found."
      render "error", :status => :not_found
    elsif @work.update_attributes(safe_params)
      @success = "Article updated."
      render "success", :status => :ok
    else
      @error = @work.errors
      render "error", :status => :bad_request
    end
  end

  def destroy
    authorize! :destroy, @work

    if @work.blank?
      @error = "No article found."
      render "error", :status => :not_found
    elsif @work.destroy
      @success = "Article deleted."
      render "success", :status => :ok
    else
      @error = "An error occured."
      render "error", :status => :bad_request
    end
  end

  private

  def safe_params
    params.require(:work).permit(:doi, :title, :pmid, :pmcid, :mendeley_uuid, :canonical_url, :year, :month, :day)
  end
end
