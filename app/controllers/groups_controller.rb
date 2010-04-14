class GroupsController < ApplicationController
  before_filter :login_required, :except => [ :index, :show, :groupArticleSummaries ]
  before_filter :detect_response_format, :only => [ :groupArticleSummaries ]
                
  #This is a way of excepting a list of DOIS and getting back summaries for them all.
  #Articles with no cites are not returned
  #This method does not check for article staleness and does not query articles for refresh
  def groupArticleSummaries
    log_debug("groupArticleSummaries")

    #Ids can be a collection
    ids = params['id'].split('-')
    ids = ids.map { |id| DOI::from_uri(id) }
      
    @result  = []

    #Specifiy the eager loading so we get all the data we need up front
    articles = Article.find(:all, 
      :include => [ :retrievals => [ :citations, { :source => :group } ]], 
      :conditions => [ "articles.doi in (?) and (retrievals.citations_count > 0 or retrievals.other_citations_count > 0)", ids ])
    
    for article in articles
      hash = {}
      hash[:article] = article
      hash[:groupcounts] = article.citations_by_group
      
      #If any groups are specified via URL params, get those details
      if params[:group] != nil then
        groups = []
        
        params[:group].split(",").map { | group |
           sources = article.get_cites_by_group(group)
           
           if(sources.length > 0) then
             groupHash = {}
             groupHash[:name] = group
             
             groupHash[:sources] = sources
             groups << groupHash
           end
        }
        
        hash[:groups] = groups
      end
      
      @result << hash
    end
  
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @result }
      format.json  { render_json @result.to_json }
    end
  end

  # GET /groups
  def index
    @groups = Group.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /groups/1
  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /groups/new
  def new
    @group = Group.new
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /groups
  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to(groups_url) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # POST /groups/1
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to(groups_url) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /groups/1
  def destroy
    @group = Group.find(params[:id])
    
    Source.find(:all, :conditions => {  :group_id => @group.id }).each do |s| 
      s.group = nil;
      s.save
    end
    
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
    end
  end

end

