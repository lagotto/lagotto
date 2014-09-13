class Api::V4::ArticlesController < Api::V4::BaseController
  # include article controller methods
  include Articable

  before_filter :load_article, only: [:update, :destroy]

  def create
    @article = Article.new(safe_params)
    authorize! :create, @article

    if @article.save
      @success = "Article created."
      render "success", :status => :created
    else
      @error = @article.errors
      render "error", :status => :bad_request
    end
  end

  def update
    authorize! :update, @article

    if @article.blank?
      @error = "No article found."
      render "error", :status => :not_found
    elsif @article.update_attributes(safe_params)
      @success = "Article updated."
      render "success", :status => :ok
    else
      @error = @article.errors
      render "error", :status => :bad_request
    end
  end

  def destroy
    authorize! :destroy, @article

    if @article.blank?
      @error = "No article found."
      render "error", :status => :not_found
    elsif @article.destroy
      @success = "Article deleted."
      render "success", :status => :ok
    else
      @error = "An error occured."
      render "error", :status => :bad_request
    end
  end
end
