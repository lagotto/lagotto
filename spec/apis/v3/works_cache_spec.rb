require "rails_helper"

describe "/api/v3/articles", :type => :api do
  let(:user) { FactoryGirl.create(:user) }
  let(:api_key) { user.authentication_token }

  context "caching", :caching => true do

    context "index" do
      let(:works) { FactoryGirl.create_list(:work_with_events, 2) }
      let(:source_ids) { Source.pluck(:id) }
      let(:work_list) { works.map { |work| "#{work.doi_escaped}" }.join(",") }

      before(:each) do
        @uri = "/api/v3/articles?ids=#{work_list}&api_key=#{api_key}"
      end

      it "can cache works" do
        works.all? do |work|
          key = work.decorate(:context => { info: nil, source_ids: source_ids }).cache_key
          expect(Rails.cache.exist?("jbuilder/v3/#{key}")).to be false
        end
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        sleep 1

        work = works.first
        key = work.decorate(:context => { info: nil, source_ids: source_ids }).cache_key
        response = Rails.cache.read("jbuilder/v3/#{key}")
        response_source = response["sources"][0]
        expect(response["doi"]).to eql(work.doi)
        expect(response["publication_date"]).to eql(work.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"][:total].to_i).to eql(work.events.first.total)
        expect(response_source["events"]).to be_nil
      end
    end

    context "show" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:source_ids) { Source.pluck(:id) }
      let(:key) { work.decorate(:context => { info: nil, source_ids: source_ids }).cache_key }
      let(:uri) { "/api/v3/articles/info:doi/#{work.doi}?api_key=#{api_key}" }
      let(:title) { "Foo" }
      let(:total) { 75 }

      it "can cache an work" do
        expect(Rails.cache.exist?("jbuilder/v3/#{key}")).not_to be true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        sleep 1

        expect(Rails.cache.exist?("jbuilder/v3/#{key}")).to be true

        response = Rails.cache.read("jbuilder/v3/#{key}")
        response_source = response["sources"][0]
        expect(response["doi"]).to eql(work.doi)
        expect(response["publication_date"]).to eql(work.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"][:total].to_i).to eql(work.events.first.total)
        expect(response_source["events"]).to be_nil
      end

      it "can make API requests 1.5x faster" do
        expect(Rails.cache.exist?("jbuilder/v3/#{key}")).not_to be true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        sleep 1

        expect(Rails.cache.exist?("jbuilder/v3/#{key}")).to be true

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)
        expect(ApiRequest.count).to eql(2)
        expect(ApiRequest.last.view_duration).to be < 0.75 * ApiRequest.first.view_duration
      end

      it "does not use a stale cache when a work is updated" do
        expect(Rails.cache.exist?("jbuilder/v3/#{key}")).not_to be true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        sleep 1

        expect(Rails.cache.exist?("jbuilder/v3/#{key}")).to be true
        response = Rails.cache.read("jbuilder/v3/#{key}")
        expect(response["title"]).to eq(work.title)
        expect(response["title"]).not_to eq(title)

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        work.update_attributes!(title: title)

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)
        cache_key = work.decorate(:context => { info: nil, source_ids: source_ids }).cache_key
        expect(cache_key).not_to eql(key)
        expect(Rails.cache.exist?("jbuilder/v3/#{cache_key}")).to be true
        response = Rails.cache.read("jbuilder/v3/#{cache_key}")
        expect(response["title"]).to eq(work.title)
        expect(response["title"]).to eq(title)
      end

      it "does not use a stale cache when a source is updated" do
        expect(Rails.cache.exist?("jbuilder/v3/#{key}")).not_to be true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        sleep 1

        expect(Rails.cache.exist?("jbuilder/v3/#{key}")).to be true
        response = Rails.cache.read("jbuilder/v3/#{key}")
        update_date = response["update_date"]
        expect(update_date).not_to be_nil

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        work.events.first.update_attributes!(total: total)
        # TODO: make sure that touch works in production
        work.touch

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)
        cache_key = work.decorate(:context => { info: nil, source_ids: source_ids }).cache_key
        expect(cache_key).not_to eql(key)
        expect(Rails.cache.exist?("jbuilder/v3/#{cache_key}")).to be true
        response = Rails.cache.read("jbuilder/v3/#{cache_key}")
        expect(response["update_date"]).to be > update_date
      end

      it "does not use a stale cache when the source query parameter changes" do
        expect(Rails.cache.exist?("jbuilder/v3/#{key}")).not_to be true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        sleep 1

        expect(Rails.cache.exist?("jbuilder/v3/#{key}")).to be true
        response = Rails.cache.read("jbuilder/v3/#{key}")
        expect(response["sources"].length).to eql(2)

        source_uri = "#{uri}&source=crossref"
        get source_uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(404)
        expect(JSON.parse(last_response.body)).to eql("error" => "Article not found.")
      end

      it "does not use a stale cache when the info query parameter changes" do
        expect(Rails.cache.exist?("jbuilder/v3/#{key}")).not_to be true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        sleep 1

        expect(Rails.cache.exist?("jbuilder/v3/#{key}")).to be true

        detail_uri = "#{uri}&info=detail"
        get detail_uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        response_source = response["sources"][0]
        expect(response["doi"]).to eql(work.doi)
        expect(response["publication_date"]).to eql(work.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"]["total"]).to eq(work.events.first.total)
        expect(response_source["metrics"]["shares"]).to eq(work.events.first.total)
        expect(response_source["events"]).not_to be_nil

        summary_uri = "#{uri}&info=summary"
        get summary_uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["sources"]).to be_nil
        expect(response["doi"]).to eql(work.doi)
        expect(response["publication_date"]).to eql(work.published_on.to_time.utc.iso8601)
      end
    end
  end
end
