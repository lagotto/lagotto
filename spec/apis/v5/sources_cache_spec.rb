require "spec_helper"

describe "/api/v5/sources" do

  let(:source) { FactoryGirl.create(:source_with_api_responses) }
  let(:user) { FactoryGirl.create(:admin_user) }
  let(:api_key) { user.authentication_token }

  before(:each) do
    source.put_alm_database
  end

  after(:each) do
    source.delete_alm_database
  end

  context "caching", :caching => true do

    context "index" do
      let(:crossref) { FactoryGirl.create(:crossref) }
      let(:mendeley) { FactoryGirl.create(:mendeley) }
      let(:sources) { [source, crossref, mendeley] }
      let(:key) { "rabl/v5/#{user.cache_key}/#{source.decorate.cache_key}" }
      let(:cache_key_list) { sources.map { |source| "#{source.decorate.cache_key}" }.join("/") }
      let(:uri) { "http://#{CONFIG[:hostname]}/api/v5/sources?api_key=#{api_key}" }

      it "can cache sources in JSON" do
        Rails.cache.exist?("rabl/v5/#{user.cache_key}/#{cache_key_list}//hash").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        source = sources.first
        response = Rails.cache.read("rabl/v5/#{user.cache_key}/#{cache_key_list}//hash").first
        response[:name].should eql(source.name)
        response[:responses].should eq("count"=>5, "average"=>200, "maximum"=>200)
      end

      # it "can cache a source in JSON" do
      #   Rails.cache.exist?("rabl/v5/#{cache_key_list}//hash").should_not be_true
      #   get uri, nil, 'HTTP_ACCEPT' => 'application/json'
      #   last_response.status.should == 200

      #   sleep 1

      #   response = Rails.cache.read("rabl/v5/#{source.decorate.cache_key}//hash")
      #   response.should eq(2)
      #   response[:name].should eql(source.name)
      #   response[:responses].should eq("count"=>5, "average"=>200, "maximum"=>200)
      # end
    end

    context "show" do
      let(:uri) { "http://#{CONFIG[:hostname]}/api/v5/sources/#{source.name}?api_key=#{api_key}" }
      let(:key) { "rabl/v5/#{user.cache_key}/#{source.decorate.cache_key}" }
      let(:display_name) { "Foo" }
      let(:event_count) { 75 }

      it "can cache a source in JSON" do
        Rails.cache.exist?("#{key}//hash").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//hash").should be_true

        response = Rails.cache.read("#{key}//hash")
        response[:name].should eql(source.name)
        response[:responses].should eq("count"=>5, "average"=>200, "maximum"=>200)
      end

      it "can make API requests 2x faster" do
        Rails.cache.exist?("#{key}//hash").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//hash").should be_true

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200
        ApiRequest.count.should eql(2)
        ApiRequest.last.view_duration.should be < 0.5 * ApiRequest.first.view_duration
      end
    end
  end
end
