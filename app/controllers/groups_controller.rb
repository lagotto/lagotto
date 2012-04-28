class GroupsController < ApplicationController
  respond_to :html

  # GET /groups
  def index
    @groups = Group.order("name")
    respond_with @groups
  end

  # GET /groups/:id
  def show
    @group = Group.find(params[:id])
    respond_with @group
  end

  # GET /groups/:id/edit
  def edit
    @group = Group.find(params[:id])
  end

  # PUT /groups/:id
  def update
    @group = Group.find(params[:id])
    if @group.update_attributes(params[:group])
      flash[:notice] = 'Group was successfully updated.'
      redirect_to groups_url
    else
      render :edit
    end
  end

  # DELETE /groups/:id
  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    @group.delete
    flash[:notice] = 'Group was successfully deleted.'
    respond_with(@group)
  end

  # GET /groups/new
  def new
    @group = Group.new
    respond_with @group
  end

  # POST /groups
  def create
    @group = Group.new(params[:group])

    if @group.save
      flash[:notice] = 'Group was successfully created.'
      redirect_to groups_url
    else
      render :new
    end
  end

  def group_article_summaries

    # get the list of DOIs
    ids = params[:id].split(",")

    # TODO validate the dois (format)

    # get all the groups
    groups = {}
    gs = Group.all
    gs.each { |group| groups[group.id] = group.name }

    @summaries = []

    # get the articles
    articles = Article.where("doi in (?)", ids)

    articles.each do |article|
      summary = {}

      summary[:article] = article

      # for each article, group the source information by group
      group_info = article.group_source_info

      summary[:groupcounts] = []
      group_info.each do |key, value|
        total = value.inject(0) {|sum, source| sum + source[:total] }
        summary[:groupcounts] << {:name => groups[key],
                                  :total => total,
                                  :sources => value}
      end

      # if any groups are specified via URL params, get those details
      summary[:groups] = params[:group].split(",").map do |group|
        sources = article.get_data_by_group(group)
        { :name => group,
          :sources => sources } unless sources.empty?
      end.compact if params[:group]

      @summaries << summary
    end

    respond_with(@summaries) do |format|
      format.html
      format.json { render :json => @summaries, :callback => params[:callback]}
      # format.xml
    end
  end
end
