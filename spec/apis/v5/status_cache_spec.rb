require "spec_helper"

describe "/api/v5/status", :not_teamcity => true do

  let(:source) { FactoryGirl.create(:source_with_api_responses) }
  let(:user) { FactoryGirl.create(:admin_user) }
  let(:api_key) { user.authentication_token }
  let(:key) { "rabl/#{Status.update_date}" }

  before(:each) do
    source.put_alm_database
  end

  after(:each) do
    source.delete_alm_database
  end

  context "caching", :caching => true do

    context "status" do
      let(:uri) { "/api/v5/status?api_key=#{api_key}" }

      it "can cache status in JSON" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true

        response = JSON.parse(Rails.cache.read("#{key}//json"))
        data = response["data"]
        data["version"].should eq(VERSION)
        data["users_count"].should == 1
        data["responses_count"].should == 5
        data["update_date"].should eql(Status.update_date)
      end

      it "can make API requests 2x faster" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true

        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200
        ApiRequest.count.should == 2
        ApiRequest.last.view_duration.should be < 0.5 * ApiRequest.first.view_duration
      end

      it "does not use a stale cache when a source is updated" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true
        response = JSON.parse(Rails.cache.read("#{key}//json"))
        data = response["data"]
        data["version"].should eq(VERSION)
        data["users_count"].should == 1
        data["responses_count"].should == 5
        data["update_date"].should eql(Status.update_date)

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        source.update_attributes!({ :display_name => "Foo" })

        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        cache_key = "rabl/#{Status.update_date}"
        cache_key.should_not eql(key)
        Rails.cache.exist?("#{cache_key}//json").should be_true
        response = JSON.parse(Rails.cache.read("#{cache_key}//json"))
        data = response["data"]
        data["update_date"].should eql(Status.update_date)
      end
    end
  end
end