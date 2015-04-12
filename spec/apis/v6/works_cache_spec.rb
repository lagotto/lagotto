require "rails_helper"

describe "/api/v6/works", :type => :api do
  let(:user) { FactoryGirl.create(:user) }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/vnd.lagotto+json; version=6",
      "Authorization" => "Token token=#{user.api_key}" }
  end

  context "caching", :caching => true do

    context "index" do
      let(:works) { FactoryGirl.create_list(:work_with_events, 2) }
      let(:work_list) { works.map { |work| "#{work.doi_escaped}" }.join(",") }
      let(:uri) { "http://#{ENV['HOSTNAME']}/api/works?ids=#{work_list}&type=doi" }

      it "can cache works" do
        works.all? do |work|
          key = work.decorate(:context => { source: 'citeulike' }).cache_key
          expect(Rails.cache.exist?("jbuilder/v6/#{key}")).to be false
        end
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        sleep 1

        work = works.first
        key = work.decorate(:context => { source: 'citeulike' }).cache_key
        response = Rails.cache.read("jbuilder/v6/#{key}")
        response_source = response["sources"][0]
        expect(response["doi"]).to eql(work.doi)
        expect(response["issued"]["date-parts"][0]).to eql([work.year, work.month, work.day])
        expect(response_source["metrics"][:total].to_i).to eql(work.retrieval_statuses.first.total)
        expect(response_source["events"]).to be_nil
      end

      # it "can cache an work" do
      #   Rails.cache.exist?("jbuilder/v6/#{cache_key_list}//hash").should_not be true
      #   get uri, nil, 'HTTP_ACCEPT' => 'application/json'
      #   last_response.status.should == 200

      #   sleep 1

      #   work = works.first
      #   response = Rails.cache.read("jbuilder/v6/#{work.decorate(:context => { :source => [1] }).cache_key}//hash").first
      #   response_source = response[:sources][0]
      #   response[:doi].should eql(work.doi)
      #   response[:issued]["date-parts"][0].should eql([work.year, work.month, work.day])
      #   response_source[:metrics][:total].to_i.should eql(work.retrieval_statuses.first.event_count)
      #   response_source[:events].should be_nil
      # end
    end

    context "work is updated" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "http://#{ENV['HOSTNAME']}/api/works?ids=#{work.doi_escaped}" }
      let(:key) { "jbuilder/v6/#{work.decorate(:context => { source: 'citeulike' }).cache_key}" }
      let(:title) { "Foo" }
      let(:total) { 75 }

      it "does not use a stale cache when a work is updated" do
        expect(Rails.cache.exist?(key)).to be false
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        sleep 1

        expect(Rails.cache.exist?(key)).to be true
        response = Rails.cache.read(key)
        expect(response["title"]).to eql(work.title)
        expect(response["title"]).not_to eql(title)

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        work.update_attributes!(title: title)

        get uri, nil, headers
        expect(last_response.status).to eq(200)
        cache_key = "jbuilder/v6/#{work.decorate(:context => { source: 'citeulike' }).cache_key}"
        expect(cache_key).not_to eql(key)
        expect(Rails.cache.exist?(cache_key)).to be true
        response = Rails.cache.read(cache_key)
        expect(response["title"]).to eql(work.title)
        expect(response["title"]).to eql(title)
      end

      it "does not use a stale cache when a source is updated" do
        expect(Rails.cache.exist?(key)).to be false
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        sleep 1

        expect(Rails.cache.exist?(key)).to be true
        response = Rails.cache.read(key)
        timestamp = response["timestamp"]

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        work.retrieval_statuses.first.update_attributes!(total: total)
        # TODO: make sure that touch works in production
        work.touch

        get uri, nil, headers
        expect(last_response.status).to eq(200)
        cache_key = "jbuilder/v6/#{work.decorate(:context => { source: 'citeulike' }).cache_key}"
        expect(cache_key).not_to eql(key)
        expect(Rails.cache.exist?(cache_key)).to be true
        response = Rails.cache.read(cache_key)
        expect(response["timestamp"]).to be > timestamp
      end

      it "does not use a stale cache when the source query parameter changes" do
        expect(Rails.cache.exist?(key)).to be false
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        sleep 1

        response = Rails.cache.read(key)
        expect(response["sources"].size).to eq(2)

        source_uri = "#{uri}&source_id=crossref"
        get source_uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["total"]).to eq(1)
        item = response["works"].first
        expect(item["doi"]).to eql(work.doi)
        expect(item["issued"]["date-parts"][0]).to eql([work.year, work.month, work.day])
        expect(item["sources"]).to be_empty
      end

      it "does not use a stale cache when the info query parameter changes" do
        expect(Rails.cache.exist?(key)).to be false
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        sleep 1

        detail_uri = "#{uri}&info=detail"
        get detail_uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["works"][0]
        expect(data["doi"]).to eql(work.doi)
        expect(data["issued"]["date-parts"][0]).to eql([work.year, work.month, work.day])

        response_source = data["sources"][0]
        expect(response_source["metrics"]["total"]).to eq(work.retrieval_statuses.first.total)
        expect(response_source["metrics"]["readers"]).to eq(work.retrieval_statuses.first.total)
        expect(response_source["events"]).not_to be_nil

        summary_uri = "#{uri}&info=summary"
        get summary_uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["works"][0]
        expect(data["sources"]).to be_nil
        expect(data["doi"]).to eql(work.doi)
        expect(data["issued"]["date-parts"][0]).to eql([work.year, work.month, work.day])
      end
    end
  end
end
