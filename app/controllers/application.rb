# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Log
  helper :all # include all helpers, all the time

  # Use our standard layout for all non-AJAX/non-RSS-feed requests
  layout proc {|c| (c.request.xhr? || \
    %w[json csv xml pdf].any? {|fmt| c.request.format.to_s.include?(fmt) } \
    ) ? false : "standard-layout" }
  
  include AuthenticatedSystem
  before_filter :login_from_cookie

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'ef6844519c2aaf111cabba8ce89d66eb'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password

protected
  # Simple JSONP support; lifted from this blog post:
  # http://www.sitepoint.com/blogs/2006/10/05/json-p-output-with-rails/
  # and modified to use standard content_type values
  def render_json(json, options={})
    callback, variable = params[:callback], params[:variable]
    response, content_type = begin
      if callback && variable
        ["var #{variable} = #{json};\n#{callback}(#{variable});", :javascript]
      elsif variable
        ["var #{variable} = #{json};", :javascript]
      elsif callback
        ["#{callback}(#{json});", :javascript]
      else
        [json, :json]
      end
    end
    render({:content_type => "application/#{content_type}", :text => response}.merge(options))
  end

  def detect_response_format
    # Because dots are a valid part of our IDs, we have to manually
    # break off format specifiers (eg, ".json", ".xml" or ".csv") here.
    id = params[:id]
    log_debug("detect_response_format id")
    if id and id =~ %r/(.*)\.(json|xml|csv)/i
      params[:id] = $1
      request.format = $2.downcase
    end
    log_debug("request.format:" + request.format)
    
    true # keep processing..
  end
  
end
