require 'rails_helper'

describe DocsController, :type => :controller do

  it "GET 'index'" do
    get ""
    expect(last_response.status).to eq(200)
  end

end
