class StatusController < ApplicationController
  def index
    @status = Status.new

    if current_user.try(:is_admin?) && @status.outdated_version?
      flash.now[:alert] = "Your Lagotto software is outdated, please install <a href='https://github.com/articlemetrics/lagotto/releases'>version #{@status.current_version}</a>.".html_safe
      @flash = flash
    end
  end
end
