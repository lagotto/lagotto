class AlertsController < ActionController::Base

  respond_to :html, :xml, :json, :rss

  def create
    exception = env["action_dispatch.exception"]
    @alert = Alert.new(:exception => exception, :request => request)

    # Filter for errors that should not be saved
    unless["ActiveRecord::RecordNotFound","ActionController::RoutingError"].include?(exception.class.to_s)
      @alert.save
    else
      @alert.status = request.headers["PATH_INFO"][1..-1]
    end

    respond_with(@alert) do |format|
      format.json { render json: { error: @alert.public_message }, status: @alert.status }
      format.xml  { render xml: @alert.public_message, root: "error", status: @alert.status }
      format.html { render :show, status: @alert.status, layout: !request.xhr? }
      format.rss { render :show, status: @alert.status, layout: false }
    end
  end

end
