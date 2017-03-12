require "rails_helper"

describe "/works", :type => :api, vcr: true do
  let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"admin", "iat"=>1472762438} }
  let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json",
      "HTTP_AUTHORIZATION" => "Token token=#{token}" }
  end
  let(:jsonp_headers) { { "HTTP_ACCEPT" => "application/javascript" } }

  context "create" do
    let(:uri) { "/works" }
    let(:pid) { "https://doi.org/10.7554/elife.01567" }
    let(:params) do
      { "data" => { "type" => "works",
                    "attributes" => {
                      "pid" => pid } } }
    end

    context "as admin user" do
      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(201)

        response = JSON.parse(last_response.body)
        work = response["data"]
        expect(work.fetch("id")).to eq(pid)
        expect(work.fetch("attributes", {}).fetch("doi")).to eq("10.7554/elife.01567")
        expect(work.fetch("attributes", {}).fetch("provider-id")).to eq("crossref")
      end
    end

    context "as contributor user" do
      let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"contributor", "iat"=>1472762438} }
      let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(201)

        response = JSON.parse(last_response.body)
        work = response["data"]
        expect(work.fetch("id")).to eq(pid)
        expect(work.fetch("attributes", {}).fetch("doi")).to eq("10.7554/elife.01567")
        expect(work.fetch("attributes", {}).fetch("provider-id")).to eq("crossref")
      end
    end

    context "as regular user" do
      let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"user", "iat"=>1472762438} }
      let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq([{"status"=>"401", "title"=>"You are not authorized to access this resource."}])
      end
    end
  end

  context "update" do
    let(:work) { FactoryGirl.create(:work, pid: "https://doi.org/10.7554/elife.01567") }
    let(:uri) { "/works/#{work.pid}" }
    let(:params) do
      { "data" => { "type" => "works",
                    "attributes" => {
                      "pid" => work.pid + "x" } } }
    end

    context "as admin user" do
      it "JSON" do
        patch uri, params, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        work = response["data"]
        expect(work.fetch("id")).to eq("https://doi.org/10.7554/elife.01567x")
        expect(work.fetch("attributes", {}).fetch("doi")).to eq("10.7554/elife.01567x")
        expect(work.fetch("attributes", {}).fetch("provider-id")).to eq("crossref")
      end
    end

    context "as contributor user" do
      let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"contributor", "iat"=>1472762438} }
      let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }

      it "JSON" do
        patch uri, params, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        work = response["data"]
        expect(work.fetch("id")).to eq("https://doi.org/10.7554/elife.01567x")
        expect(work.fetch("attributes", {}).fetch("doi")).to eq("10.7554/elife.01567x")
        expect(work.fetch("attributes", {}).fetch("provider-id")).to eq("crossref")
      end
    end

    context "as regular user" do
      let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"user", "iat"=>1472762438} }
      let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }

      it "JSON" do
        patch uri, params, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq([{"status"=>"401", "title"=>"You are not authorized to access this resource."}])
      end
    end
  end

  context "delete" do
    let(:work) { FactoryGirl.create(:work, pid: "https://doi.org/10.7554/elife.01567") }
    let(:uri) { "/works/#{work.pid}" }

    context "as admin user" do
      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(204)
        expect(last_response.body).to be_blank
      end
    end

    context "as contributor user" do
      let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"contributor", "iat"=>1472762438} }
      let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }

      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(204)
        expect(last_response.body).to be_blank
      end
    end

    context "as regular user" do
      let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"user", "iat"=>1472762438} }
      let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }

      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq([{"status"=>"401", "title"=>"You are not authorized to access this resource."}])
      end
    end
  end

  context "index" do
    let(:works) { FactoryGirl.create_list(:work, 10) }

    context "works found via PID" do
      before(:each) do
        work_list = works.map { |work| work.pid }.join(",")
        @uri = "/works?ids=#{work_list}"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(10)
        work = data.first
        expect(work.fetch("id")).to start_with("https://doi.org/10.1371/journal.pone")
        expect(work.fetch("attributes", {}).fetch("doi")).to start_with("10.1371/journal.pone")
      end
    end

    context "works found via DOI" do
      before(:each) do
        work_list = works.map { |work| work.doi }.join(",")
        @uri = "/works?ids=#{work_list}"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        work = data.first
        expect(work.fetch("id")).to start_with("https://doi.org/10.1371/journal.pone")
        expect(work.fetch("attributes", {}).fetch("doi")).to start_with("10.1371/journal.pone")
      end
    end

    context "no records found" do
      let(:uri) { "/works?ids=xxx" }
      let(:nothing_found) { { "data" => [], "links" => {}, "meta" => { "total" => 0, "total-pages" => 0, "page" => 1 } } }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq(nothing_found.to_json)
      end
    end
  end

  context "show" do
    let(:work) { FactoryGirl.create(:work) }

    context "work found via PID" do
      let(:uri) { "/works/#{work.pid}" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        work = response["data"]
        expect(work.fetch("id")).to start_with("https://doi.org/10.1371/journal.pone")
        expect(work.fetch("attributes", {}).fetch("doi")).to start_with("10.1371/journal.pone")
      end
    end

    context "work found via DOI" do
      let(:uri) { "/works/#{work.doi}" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        work = response["data"]
        expect(work.fetch("id")).to start_with("https://doi.org/10.1371/journal.pone")
        expect(work.fetch("attributes", {}).fetch("doi")).to start_with("10.1371/journal.pone")
      end
    end
  end
end
