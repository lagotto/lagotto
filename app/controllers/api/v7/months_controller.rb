class Api::V7::MonthsController < Api::BaseController
  before_filter :authenticate_user_from_token!, :load_source

  def index
    collection = @source.months.select("year, month, '#{@source.name}' as source_id,
                                        sum(total) as total,
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
