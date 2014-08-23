require "spec_helper"

describe "/api/v5/status" do

  let(:source) { FactoryGirl.create(:source_with_api_responses) }
  let(:user) { FactoryGirl.create(:admin_user) }
  let(:api_key) { user.authentication_token }
  let(:status) { Status.new }
  let(:key) { "rabl/v5/#{user.cache_key}/#{status.cache_key}//hash" }

  before(:each) do
    source.put_alm_database
  end

  after(:each) do
    source.delete_alm_database
  end

  context "caching", :caching => true do

    context "status" do
      let(:uri) { "http://#{CONFIG[:hostname]}/api/v5/status?api_key=#{api_key}" }

      it "can cache status in JSON" do
        Rails.cache.exist?(key).should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?(key).should be_true

        cached_status = Rails.cache.read(key)
        cached_status[:version].should eq(Rails.application.config.version)
        cached_status[:users_count].should == 1
        cached_status[:responses_count].should == 5
        cached_status[:update_date].should eql(status.update_date)
      end

      it "can make API requests 2x faster" do
        Rails.cache.exist?(key).should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should eql(200)

        sleep 1

        Rails.cache.exist?(key).should be_true

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200
        ApiRequest.count.should == 2
        ApiRequest.last.view_duration.should be < 0.5 * ApiRequest.first.view_duration
      end
    end
  end
end
