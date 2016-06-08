class Api::V7::ContributorsController < Api::BaseController
  swagger_controller :contributors, "Contributors"

  swagger_api :index do
    summary 'Returns all contributors, ordered by family name'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns contributor by pid'
    param :path, :id, :string, :required, "Contributor pid"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def show
    pid = get_pid(params[:id])
    contributor = Contributor.where(pid: pid).first
    if contributor.present?
      @contributor = contributor.decorate
    else
      render json: { meta: { status: "error", error: "Contributor #{params[:id]} not found." } }.to_json, status: :not_found
    end
  end

  def index
    collection = Contributor
    collection = collection.query(params[:q]) if params[:q]
    collection = collection.order_by_name

    per_page = params[:per_page] && (0..1000).include?(params[:per_page].to_i) ? params[:per_page].to_i : 1000
    page = params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1
    total_entries = get_total_entries(params)

    collection = collection.paginate(per_page: per_page,
                                     page: page,
                                     total_entries: total_entries)
    @contributors = collection.decorate
  end

  def get_pid(id)
    return nil unless id.present?
    id.starts_with?('http') ? id.gsub(/(http|https):\/+(\w+)/, '\1://\2') : "http://#{id}"
  end

  # use cached counts for total number of results
  def get_total_entries(params)
    case
    when params[:q] then nil # can't be cached
    else Contributor.count_all
    end
  end
end
