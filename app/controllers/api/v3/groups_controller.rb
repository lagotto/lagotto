class Api::V3::GroupsController < Api::V3::BaseController
  
  def index
    @groups = GroupDecorator.order("id").decorate
    
    # Return 404 HTTP status code and error message if no groups are found
    render "404", :status => 404 if @groups.blank?
  end  
end