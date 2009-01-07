
class NoSourceTypeSpecified < ArgumentError; end
class DuplicateSourceType < ArgumentError; end

class SourcesController < ApplicationController
  before_filter :login_required

  # GET /sources
  # GET /sources.xml
  def index
    @sources = (Source.all + Source.unconfigured_source_names).sort_by do |s|
      s.is_a?(Source) ? s.class.name : s
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sources }
    end
  end

  # GET /sources/1
  # GET /sources/1.xml
  def show
    @source = Source.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @source }
    end
  end

  # GET /sources/new
  # GET /sources/new.xml
  def new
    @source = source_class.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @source }
    end
  end

  # GET /sources/1/edit
  def edit
    @source = Source.find(params[:id])
  end

  # POST /sources
  # POST /sources.xml
  def create
    @source = source_class.new(params[:source])

    respond_to do |format|
      if @source.save
        flash[:notice] = 'Source was successfully created.'
        format.html { redirect_to(sources_url) }
        format.xml  { render :xml => @source, :status => :created, :location => @source }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sources/1
  # PUT /sources/1.xml
  def update
    @source = source_class(false).find(params[:id])

    respond_to do |format|
      if @source.update_attributes(params[:source])
        flash[:notice] = 'Source was successfully updated.'
        format.html { redirect_to(sources_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sources/1
  # DELETE /sources/1.xml
  def destroy
    @source = Source.find(params[:id])
    @source.destroy

    respond_to do |format|
      format.html { redirect_to(sources_url) }
      format.xml  { head :ok }
    end
  end

protected
  def source_class(new = true)
    # Extract the class of this source from the params we got
    # Make sure there's no existing one if it's supposed to be "new"
    klass = params.delete(:class)
    klass = ((params[:source] || {}).delete(:class)) unless klass
    raise(NoSourceTypeSpecified) unless klass
    raise(DuplicateSourceType) if new and Source.find_by_type(klass)
    return Kernel.const_get(klass)
  end
end
