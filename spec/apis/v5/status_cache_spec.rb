require "spec_helper"

describe "/api/v5/status" do

  let(:source) { FactoryGirl.create(:source_with_api_responses) }
  let(:user) { FactoryGirl.create(:admin_user) }
  let(:api_key) { user.authentication_token }
  let(:status) { Status.new }
  let(:key) { "rabl/v5/#{user.cache_key}/#{status.cache_key}" }

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
        Rails.cache.exist?("#{key}//hash").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        response = Rails.cache.read("#{key}//hash")
        response[:version].should eq(Rails.application.config.version)
        response[:users_count].should == 1
        response[:responses_count].should == 5
        response[:update_date].should eql(status.update_date)
      end

      it "can make API requests 2x faster" do
        Rails.cache.exist?("#{key}//hash").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should eql(200)

        sleep 1

        Rails.cache.exist?("#{key}//hash").should be_true

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200
        ApiRequest.count.should == 2
        ApiRequest.last.view_duration.should be < 0.5 * ApiRequest.first.view_duration
      end

      it "does not use a stale cache when a source is updated" do
        Rails.cache.exist?("#{key}//hash").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should eql(200)

        sleep 1

        response = Rails.cache.read("#{key}//hash")
        response[:version].should eq(Rails.application.config.version)
        response[:users_count].should == 1
        response[:responses_count].should == 5
        response[:update_date].should eql(status.update_date)

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        source.update_attributes!(display_name: "Foo")

        get uri, nil, 'HTTP_ACCEPT' => "application/json"
        last_response.status.should eql(200)
        cache_key = "rabl/v5/#{status.cache_key}"
        cache_key.should_not eql(key)
        Rails.cache.exist?("#{cache_key}//hash").should be_true
        response = Rails.cache.read("#{cache_key}//hash")
        response[:update_date].should eql(status.update_date)
      end
    end
  end
end
