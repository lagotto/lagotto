class Api::V7::PrefixesController < Api::BaseController
  def show
    prefix = Prefix.where(name: params[:id]).first
    fail ActiveRecord::RecordNotFound unless prefix.present?

    @prefix = prefix.decorate
  end

  def index
    collection = Prefix.order(:name)
    @prefixes = collection.decorate
  end
end
