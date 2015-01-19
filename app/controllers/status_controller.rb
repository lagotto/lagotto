class StatusController < ApplicationController
  def index
    Status.create(current_version: Rails.application.config.version) if Rails.env == "development" || Status.count == 0

    collection = Status.order("created_at DESC")
    @current_status = collection.first
    @status = collection.paginate(:page => params[:page])

    @process = SidekiqProcess.new

    if current_user.try(:is_admin?) && @current_status.outdated_version?
      flash.now[:alert] = "Your Lagotto software is outdated, please install <a href='https://github.com/articlemetrics/lagotto/releases'>version #{@current_status.current_version}</a>.".html_safe
      @flash = flash
    end
  end

  private

  def safe_params
    params.require(:status).permit(:current_version)
  end
end
