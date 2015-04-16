require "rails_helper"

describe "/api/v6/works", :type => :api do
  let(:headers) do
    { "HTTP_ACCEPT" => "application/vnd.lagotto+json; version=6" }
  end

  context "caching", :caching => true do

    context "index" do
      let(:works) { FactoryGirl.create_list(:work_with_events, 2) }
      let(:work_list) { works.map { |work| "#{work.doi_escaped}" }.join(",") }
      let(:uri) { "http://#{ENV['HOSTNAME']}/api/works?ids=#{work_list}&type=doi" }

      it "can cache works" do
        works.all? do |work|
          key = work.decorate.cache_key
          expect(Rails.cache.exist?("jbuilder/v6/#{key}")).to be false
        end
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        sleep 1

        work = works.first
        key = work.decorate.cache_key
        response = Rails.cache.read("jbuilder/v6/#{key}")
        expect(response["id"]).to eq(work.pid)
        expect(response["DOI"]).to eq(work.doi)
        expect(response["issued"]["date-parts"][0]).to eql([work.year, work.month, work.day])
        expect(response["events"]).to eql("citeulike"=>50, "mendeley"=>50)
      end
    end

    context "work is updated" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "http://#{ENV['HOSTNAME']}/api/works?ids=#{work.doi_escaped}&type=doi" }
      let(:key) { "jbuilder/v6/#{work.decorate.cache_key}" }
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
        cache_key = "jbuilder/v6/#{work.decorate.cache_key}"
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
        cache_key = "jbuilder/v6/#{work.decorate.cache_key}"
        expect(cache_key).not_to eql(key)
        expect(Rails.cache.exist?(cache_key)).to be true
        response = Rails.cache.read(cache_key)
        expect(response["timestamp"]).to be > timestamp
      end
    end
  end
end
