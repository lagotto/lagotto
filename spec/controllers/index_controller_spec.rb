require 'spec_helper'

describe IndexController do

  it "GET 'index'" do
    get ""
    last_response.status.should eql(200)
  end

end
