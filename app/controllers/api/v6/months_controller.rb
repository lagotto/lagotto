class Api::V6::MonthsController < Api::BaseController
  before_filter :authenticate_user_from_token!, :load_source

  swagger_controller :months, "Months"

  swagger_api :index do
    summary "Returns list of monhtly metrics by source names"
   param :query, :source_id, :string, :required, "Source name"
    response :ok
    response :unprocessable_entity
    response :not_found
    response :internal_server_error
  end

  def index
    collection = @source.months.select("year, month, '#{@source.name}' as source_id,
                                        sum(total) as total,
                                        sum(pdf) as pdf,
                                        sum(html) as html,
                                        sum(readers) as readers,
                                        sum(comments) as comments,
                                        sum(likes) as likes,
                                        max(updated_at) as updated_at").group(:year, :month)
    collection = collection.includes(:source)

    @months = collection.decorate
  end

  protected

  def load_source
    @source = Source.where(name: params[:source_id]).first

    fail ActiveRecord::RecordNotFound unless @source.present?
  end
end
