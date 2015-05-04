require "rails_helper"

describe "/api/v6/events", :type => :api do
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version=6" }
  end

  context "caching", :caching => true do
    context "work is updated" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "http://#{ENV['HOSTNAME']}/api/works/#{work.pid}/events" }
      let(:key) { "jbuilder/v6/#{work.decorate.cache_key}" }
      let(:title) { "Foo" }
      let(:total) { 75 }

      it "does not use a stale cache when the source query parameter changes" do
        expect(Rails.cache.exist?(key)).to be false
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        sleep 1

        response = Rails.cache.read(key)
        expect(response).to eq(2)

        source_uri = "#{uri}?source_id=crossref"
        get source_uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(1)
        item = response["works"].first
        expect(item["DOI"]).to eql(work.doi)
        expect(item["issued"]["date-parts"][0]).to eql([work.year, work.month, work.day])
        expect(item["events"]).to be_empty
      end
    end
  end
end
