require "rails_helper"

describe "/api/v6/relations", :type => :api do
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version=6" }
  end

  context "caching", :caching => true do
    context "work is updated" do
      let(:work) { FactoryGirl.create(:work, :with_relations) }
      let(:keys) { work.relations.map { |rs| rs.cache_key } }
      let(:uri) { "http://#{ENV['HOSTNAME']}/api/works/#{work.pid}/relations" }
      let(:title) { "Foo" }
      let(:total) { 75 }

      it "does not use a stale cache when the source query parameter changes" do
        keys.all? do |key|
          expect(Rails.cache.exist?("jbuilder/v6/#{key}")).to be false
        end

        get uri, nil, headers
        expect(last_response.status).to eq(200)

        sleep 1

        keys.all? do |key|
          expect(Rails.cache.exist?("jbuilder/v6/#{key}")).to be true
        end

        #response = Rails.cache.read(keys.first)
        #expect(response).to eq(2)

        source_uri = "#{uri}?source_id=citeulike"
        get source_uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(2)
        item = response["relations"].first
        expect(item["work_id"]).to eql(work.pid)
        expect(item["total"]).to eql(50)
        expect(item["relations_url"]).to eq("http://www.citeulike.org/doi/#{work.doi}")
      end
    end
  end
end
