require "rails_helper"

describe "/api/v6/metrics", :type => :api do
  let(:user) { FactoryGirl.create(:user) }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json",
      "Authorization" => "Token token=#{user.api_key}" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript",
      "Authorization" => "Token token=#{user.api_key}" }
  end

  context "index" do
    context "JSON" do
      let(:works) { FactoryGirl.create_list(:work_with_events, 5) }
      let(:work) { works.first }
      let(:work_list) { works.map { |work| "#{work.pid}" }.join(",") }
      let(:uri) { "/api/metrics?ids=#{work_list}" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["metrics"].length).to eq(10)

        item = response["metrics"].find { |i| i["work_id"] == work.pid }
        expect(item["source_id"]).to eq("citeulike")
        expect(item["total"]).to eq(50)
        expect(item["readers"]).to eq(50)
        expect(item["events_url"]).to eq("http://www.citeulike.org/doi/#{work.doi}")
        expect(item["by_day"]).to be_empty
        expect(item["by_month"]).not_to be_nil
        expect(item["by_year"]).not_to be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response["metrics"].length).to eq(10)

        item = response["metrics"].find { |i| i["work_id"] == work.pid }
        expect(item["source_id"]).to eq("citeulike")
        expect(item["work_id"]).to eq(work.pid)
        expect(item["total"]).to eq(50)
        expect(item["readers"]).to eq(50)
        expect(item["events_url"]).to eq("http://www.citeulike.org/doi/#{work.doi}")
        expect(item["by_day"]).to be_empty
        expect(item["by_month"]).not_to be_nil
        expect(item["by_year"]).not_to be_nil
      end
    end

    context "show" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "/api/works/#{work.pid}/metrics" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(2)

        item = response["metrics"].first
        expect(item["source_id"]).to eq("citeulike")
        expect(item["work_id"]).to eq(work.pid)
        expect(item["total"]).to eq(50)
        expect(item["readers"]).to eq(50)
        expect(item["events_url"]).to eq("http://www.citeulike.org/doi/#{work.doi}")
        expect(item["by_day"]).to be_empty
        expect(item["by_month"]).not_to be_nil
        expect(item["by_year"]).not_to be_nil
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response["meta"]["total"]).to eq(2)

        item = response["metrics"].first
        expect(item["source_id"]).to eq("citeulike")
        expect(item["work_id"]).to eq(work.pid)
        expect(item["total"]).to eq(50)
        expect(item["readers"]).to eq(50)
        expect(item["events_url"]).to eq("http://www.citeulike.org/doi/#{work.doi}")
        expect(item["by_day"]).to be_empty
        expect(item["by_month"]).not_to be_nil
        expect(item["by_year"]).not_to be_nil
      end
    end
  end
end
