class Api::V4::AlertsController < Api::V4::BaseController
  load_and_authorize_resource

  def index
    collection = Alert
    if params[:source]
      collection = collection.includes(:source).where("sources.name = ?", params[:source])
      @source = Source.find_by_name(params[:source])
    end
    if params[:class_name]
      collection = collection.where(:class_name => params[:class_name])
      @class_name = params[:class_name]
    end
    if params[:level]
      level = Alert::LEVELS.index(params[:level].upcase) || 0
      collection = collection.where("level >= ?", level)
      @level = params[:level]
    end

    collection = collection.query(params[:q]) if params[:q]
    collection = collection.paginate(:page => params[:page], :per_page => 50)
    @alerts = collection.decorate
  end
end
