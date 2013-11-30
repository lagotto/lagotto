class Admin::SourcesController < Admin::ApplicationController
  before_filter :load_source, :only => [ :show, :edit, :update ]
  load_and_authorize_resource

  def show
    filename = Rails.root.join("docs/#{@source.name.capitalize}.md")
    @doc = { :text => File.exist?(filename) ? IO.read(filename) : "No documentation found." }
  end

  def index
    @groups = Group.includes(:sources).order("groups.id, sources.display_name")
    respond_with @groups
  end

  def edit
    respond_with(@source) do |format|
      format.js { render :show }
    end
  end

  def update
    @source.update_attributes(params[:source])
    respond_with(@source) do |format|
      format.js { render :show }
    end
  end

  protected
  def load_source
    @source = Source.find_by_name(params[:id])
  end
end