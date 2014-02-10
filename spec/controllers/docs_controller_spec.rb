require 'spec_helper'

describe DocsController do

  it "GET 'index'" do
    get ""
    last_response.status.should == 302
  end

end
