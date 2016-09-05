class Api::V7::DataExportsController < Api::BaseController
  before_filter :authenticate_user_from_token!
  load_and_authorize_resource

  PER_PAGE = 1000

  def index
    collection = DataExport.all.order("id DESC")
    per_page = params[:per_page] && (0..PER_PAGE).include?(params[:per_page].to_i) ? params[:per_page].to_i : PER_PAGE
    page = params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1
    collection = collection.paginate(per_page: per_page, :page => page)

    @data_exports = collection.decorate
  end
end
