require "spec_helper"

describe "/api/v3/status", :not_teamcity => true do

  let(:source) { FactoryGirl.create(:source_with_api_responses) }
  let(:user) { FactoryGirl.create(:user) }
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
      let(:uri) { "/api/v3/status?api_key=#{api_key}" }

      it "can cache status in JSON" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true

        response = Rails.cache.read("#{key}//json")
        response[:version].should eq(VERSION)
        response[:users_count].should == 1
        response[:responses_count].should == 5
        response[:update_date].should eql(Status.update_date)
      end

      it "can make API requests 2x faster" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true

        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        ApiRequest.count.should eql(2)
        ApiRequest.last.view_duration.should be < 0.5 * ApiRequest.first.view_duration
      end

      it "does not use a stale cache when a source is updated" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true
        response = Rails.cache.read("#{key}//json")
        response[:version].should eq(VERSION)
        response[:users_count].should == 1
        response[:responses_count].should == 5
        response[:update_date].should eql(Status.update_date)

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        source.update_attributes!({ :display_name => "Foo" })

        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        cache_key = "rabl/#{Status.update_date}"
        cache_key.should_not eql(key)
        Rails.cache.exist?("#{cache_key}//json").should be_true
        response = Rails.cache.read("#{cache_key}//json")
        response[:update_date].should eql(Status.update_date)
      end
    end

    context "sources index" do
      let(:cross_ref) { FactoryGirl.create(:cross_ref) }
      let(:mendeley) { FactoryGirl.create(:mendeley) }
      let(:sources) { [source, cross_ref, mendeley] }
      let(:uri) { "/api/v3/sources?api_key=#{api_key}" }

      it "can cache sources in JSON" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true

        source = sources.first
        response = Rails.cache.read("rabl/#{Status.update_date}//json")
        response[:version].should eq(VERSION)
        response[:users_count].should == 1
        response[:responses_count].should == 5
        response[:update_date].should eql(Status.update_date)
      end

      it "can make API requests 0.9x faster" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        ApiRequest.count.should eql(2)
        ApiRequest.last.view_duration.should be < 0.9 * ApiRequest.first.view_duration
      end
    end

    context "sources show" do
      let(:uri) { "/api/v3/sources/#{source.name}?api_key=#{api_key}" }
      let(:display_name) { "Foo" }
      let(:event_count) { 75 }

      it "can cache a source in JSON" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true

        response = Rails.cache.read("#{key}//json")
        response[:version].should eq(VERSION)
        response[:users_count].should == 1
        response[:responses_count].should == 5
        response[:update_date].should eql(Status.update_date)
      end

      it "can make API requests 2x faster" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true

        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        ApiRequest.count.should eql(2)
        ApiRequest.last.view_duration.should be < 0.5 * ApiRequest.first.view_duration
      end

      it "does not use a stale cache when a source is updated" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true
        response = Rails.cache.read("#{key}//json")
        response[:update_date].should eql(Status.update_date)
        update_date = response[:update_date]

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        source.update_attributes!({ :display_name => display_name })

        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        cache_key = "rabl/#{Status.update_date}"
        cache_key.should_not eql(key)
        Rails.cache.exist?("#{cache_key}//json").should be_true
        response = Rails.cache.read("#{cache_key}//json")
        response[:version].should eq(VERSION)
        response[:users_count].should == 1
        response[:responses_count].should == 5
        response[:update_date].should eql(Status.update_date)
      end
    end
  end
end