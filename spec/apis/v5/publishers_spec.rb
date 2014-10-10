require "spec_helper"

describe "/api/v5/publishers" do
  context "index" do
    let(:user) { FactoryGirl.create(:admin_user) }
    let(:uri) { "/api/v5/publishers?api_key=#{user.authentication_token}" }

    context "index" do
      before(:each) do
        @publisher = FactoryGirl.create(:publisher)
      end

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"]
        item = data.first
        item["name"].should eq(@publisher.name)
        item["other_names"].should eq(["Public Library of Science",
                                       "Public Library of Science (PLoS)"])
        item["prefixes"].should eq(["10.1371"])
        item["crossref_id"].should == 340
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil,
            "HTTP_ACCEPT" => "application/javascript"
        last_response.status.should eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        item = data.first
        item["name"].should eq(@publisher.name)
        item["other_names"].should eq(["Public Library of Science",
                                       "Public Library of Science (PLoS)"])
        item["prefixes"].should eq(["10.1371"])
        item["crossref_id"].should == 340
      end
    end
  end
end
