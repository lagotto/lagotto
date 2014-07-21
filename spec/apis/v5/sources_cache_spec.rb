require "spec_helper"

describe "/api/v5/sources" do

  let(:citeulike) { FactoryGirl.create(:source_with_api_responses) }
  let(:user) { FactoryGirl.create(:admin_user) }
  let(:api_key) { user.authentication_token }

  before(:each) do
    citeulike.put_alm_database
  end

  after(:each) do
    citeulike.delete_alm_database
  end

  context "caching", :caching => true do

    context "index" do
      let(:crossref) { FactoryGirl.create(:crossref) }
      let(:mendeley) { FactoryGirl.create(:mendeley) }
      let(:sources) { [citeulike, crossref, mendeley] }
      let(:uri) { "/api/v5/sources?api_key=#{api_key}" }

      it "can cache sources in JSON" do
        sources.any? do |source|
          Rails.cache.exist?("rabl/v5/#{user.cache_key}/#{source.cache_key}//json")
        end.should_not be_true

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        sources.all? do |source|
          Rails.cache.exist?("rabl/v5/#{user.cache_key}/#{source.cache_key}//json")
        end.should be_true

        source = sources.first
        response = JSON.parse(Rails.cache.read("rabl/v5/#{user.cache_key}/#{source.cache_key}//json"))
        data = response["data"]
        data["name"].should eql(source.name)
        data["update_date"].should eql(source.cached_at.utc.iso8601)
      end

      it "can make API requests 0.9x faster" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200
        ApiRequest.count.should eql(2)
        ApiRequest.last.view_duration.should be < 0.9 * ApiRequest.first.view_duration
      end
    end

    context "show" do
      let(:uri) { "/api/v5/sources/#{citeulike.name}?api_key=#{api_key}" }
      let(:key) { "rabl/v5/#{user.cache_key}/#{citeulike.cache_key}" }
      let(:display_name) { "Foo" }
      let(:event_count) { 75 }

      it "can cache a source in JSON" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true

        response = JSON.parse(Rails.cache.read("#{key}//json"))
        data = response["data"]
        data["name"].should eql(citeulike.name)
        data["update_date"].should eql(citeulike.cached_at.utc.iso8601)
      end

      it "can make API requests 2x faster" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200
        ApiRequest.count.should eql(2)
        ApiRequest.last.view_duration.should be < 0.5 * ApiRequest.first.view_duration
      end

      it "updates the cached_at column when a source is updated" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true
        response = JSON.parse(Rails.cache.read("#{key}//json"))
        data = response["data"]
        data["display_name"].should eql(citeulike.display_name)
        data["display_name"].should_not eql(display_name)

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        cached_at = citeulike.cached_at.utc.iso8601
        citeulike.update_attributes!(display_name: display_name)

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200
        cache_key = "rabl/v5/#{user.cache_key}/#{citeulike.cache_key}"
        cache_key.should_not eql(key)
        Rails.cache.exist?("#{cache_key}//json").should be_true
        response = JSON.parse(Rails.cache.read("#{cache_key}//json"))
        data = response["data"]
        data["display_name"].should eql(citeulike.display_name)
        data["display_name"].should eql(display_name)
        data["update_date"].should be > cached_at
      end

      it "does not use a stale cache when a source is updated" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true
        response = JSON.parse(Rails.cache.read("#{key}//json"))
        data = response["data"]
        data["display_name"].should eql(citeulike.display_name)
        data["display_name"].should_not eql(display_name)

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        citeulike.update_attributes!(display_name: display_name)

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200
        cache_key = "rabl/v5/#{user.cache_key}/#{citeulike.cache_key}"
        cache_key.should_not eql(key)
        Rails.cache.exist?("#{cache_key}//json").should be_true
        response = JSON.parse(Rails.cache.read("#{cache_key}//json"))
        data = response["data"]
        data["display_name"].should eql(citeulike.display_name)
        data["display_name"].should eql(display_name)
      end
    end
  end
end
