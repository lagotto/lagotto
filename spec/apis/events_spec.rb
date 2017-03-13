require "rails_helper"

describe "/events", :type => :api do
  before(:each) do
    allow(Time).to receive(:now).and_return(Time.mktime(2015, 4, 8))
    allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8))
  end

  let(:event) { FactoryGirl.build(:event) }
  let(:errors) { [{"status"=>"401", "title"=>"You are not authorized to access this resource."}] }

  # Successful response from creating via the API.
  let(:success) { { "id"=> event.uuid,
                    "type"=>"events",
                    "attributes"=>{
                      "state"=>"waiting",
                      "message-action"=>"create",
                      "source-token"=>"citeulike_123",
                      "callback"=>nil,
                      "subj-id"=>"http://www.citeulike.org/user/dbogartoit",
                      "obj-id"=>"http://doi.org/10.1371/journal.pmed.0030186",
                      "relation-type-id"=>"bookmarks",
                      "source-id"=>"citeulike",
                      "total"=>1,
                      "occurred-at"=>"2015-04-08T00:00:00Z",
                      "subj"=>{"pid"=>"http://www.citeulike.org/user/dbogartoit",
                               "author"=>[{"given"=>"dbogartoit"}],
                               "title"=>"CiteULike bookmarks for user dbogartoit",
                               "container-title"=>"CiteULike",
                               "issued"=>"2006-06-13T16:14:19Z",
                               "url"=>"http://www.citeulike.org/user/dbogartoit",
                               "type"=>"entry"},
                      "obj"=>{}}}}

  let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"admin", "iat"=>1472762438} }
  let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }
  let(:uuid) { SecureRandom.uuid }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json",
      "HTTP_AUTHORIZATION" => "Token token=#{token}" }
  end

  context "create" do
    let(:uri) { "/events" }
    let(:params) do
      { "data" => { "type" => "events",
                    "attributes" => {
                      "uuid" => event.uuid,
                      "subj_id" => event.subj_id,
                      "subj" => event.subj,
                      "obj_id" => event.obj_id,
                      "relation_type_id" => event.relation_type_id,
                      "source_id" => event.source_id,
                      "source_token" => event.source_token } } }
    end

    context "as admin user" do
      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(201)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to be_nil
        expect(response["data"]).to eq(success)
      end
    end

    context "as staff user" do
      let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"staff", "iat"=>1472762438} }
      let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq(errors)
        expect(response["data"]).to be_nil
      end
    end

    context "as contributor user" do
      let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"contributor", "iat"=>1472762438} }
      let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(201)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to be_nil
        expect(response["data"]).to eq(success)
      end
    end

    context "as regular user" do
      let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"user", "iat"=>1472762438} }
      let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq(errors)
        expect(response["data"]).to be_blank
      end
    end

    context "without source_token" do
      let(:params) do
        { "data" => { "type" => "events",
                      "attributes" => {
                        "uuid" => uuid,
                        "subj_id" => event.subj_id,
                        "source_id" => event.source_id } } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq([{"status"=>422, "title"=>"Source token can't be blank"}])
        expect(response["data"]).to be_nil
      end
    end

    context "without source_id" do
      let(:params) do
        { "data" => { "type" => "events",
                      "attributes" => {
                        "uuid" => uuid,
                        "subj_id" => event.subj_id,
                        "source_token" => event.source_token } } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq([{"status"=>422, "title"=>"Source can't be blank"}])
        expect(response["data"]).to be_blank
      end
    end

    context "without subj_id" do
      let(:params) do
        { "data" => { "type" => "events",
                      "attributes" => {
                        "uuid" => uuid,
                        "source_id" => event.source_id,
                        "source_token" => event.source_token } } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq([{"status"=>422, "title"=>"Subj can't be blank"}])
        expect(response["data"]).to be_blank
      end
    end

    context "with wrong API key" do
      let(:headers) do
        { "HTTP_ACCEPT" => "application/json",
          "HTTP_AUTHORIZATION" => "Token token=12345678" }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq(errors)
        expect(response["data"]).to be_blank
      end
    end

    context "with missing data param" do
      let(:params) do
        { "event" => { "type" => "events",
                         "attributes" => {
                           "uuid" => uuid,
                           "source_token" => "123" } } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq([{"status"=>"422", "title"=>"param is missing or the value is empty: data"}])
        expect(response["data"]).to be_blank
      end
    end

    context "with unpermitted params" do
      let(:params) do
        { "data" => { "type" => "events",
                      "attributes" => {
                        "uuid" => uuid,
                        "subj_id" => event.subj_id,
                        "source_id" => event.source_id,
                        "source_token" => event.source_token,
                        "foo" => "bar" } } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq([{"status"=>"422", "title"=>"found unpermitted parameter: foo"}])
        expect(response["data"]).to be_blank
      end
    end

    context "with params in wrong format" do
      let(:params) { { "data" => "10.1371/journal.pone.0036790 2012-05-15 New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail" } }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)
        response = JSON.parse(last_response.body)
        error = response["errors"].first
        expect(error["status"]).to eq("422")
        expect(error["title"]).to start_with("undefined method `permit")
        expect(response["data"]).to be_blank
      end
    end
  end

  context "show" do
    let(:event) { FactoryGirl.create(:event) }
    let(:uri) { "/events/#{event.uuid}" }

    context "as admin user" do
      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to be_nil
        expect(response["data"]).to eq(success)
      end
    end

    context "as staff user" do
      let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"staff", "iat"=>1472762438} }
      let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to be_nil
        expect(response["data"]).to eq(success)
      end
    end

    context "as regular user" do
      let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"user", "iat"=>1472762438} }
      let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to be_nil
        expect(response["data"]).to eq(success)
      end
    end

    context "event not found" do
      let(:uri) { "/events/#{event.uuid}x" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(404)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq([{"status"=>"404", "title"=>"The resource you are looking for doesn't exist."}])
        expect(response["data"]).to be_nil
      end
    end
  end

  context "index" do
    let!(:event) { FactoryGirl.create(:event) }
    let(:uri) { "/events" }

    # Just test that the API can be accessed without a token.
    context "with no API key" do

      # Exclude the token header.
      let(:headers) do
        { "HTTP_ACCEPT" => "application/json" }
      end

      it "JSON" do
        get uri, nil, headers

        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)

        expect(response["errors"]).to be_nil
        expect(response["data"]).to eq([success])
      end

      it "No accept header" do
        get uri

        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)

        expect(response["errors"]).to be_nil
        expect(response["data"]).to eq([success])
      end
    end
  end

  context "destroy" do
    let(:event) { FactoryGirl.create(:event) }
    let(:uri) { "/events/#{event.uuid}" }

    context "as admin user" do
      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to be_nil
        expect(response["data"]).to eq({})
      end
    end

    context "as staff user" do
      let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"staff", "iat"=>1472762438} }
      let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }

      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq(errors)
        expect(response["data"]).to be_nil
      end
    end

    context "as regular user" do
      let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"user", "iat"=>1472762438} }
      let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }

      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq(errors)
        expect(response["data"]).to be_nil
      end
    end

    context "with wrong API key" do
      let(:headers) do
        { "HTTP_ACCEPT" => "application/json",
          "HTTP_AUTHORIZATION" => "Token token=12345678" }
      end

      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq(errors)
        expect(response["data"]).to be_nil
      end
    end

    context "event not found" do
      let(:uri) { "/events/#{event.uuid}x" }

      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(404)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq([{"status"=>"404", "title"=>"The resource you are looking for doesn't exist."}])
        expect(response["data"]).to be_nil
      end
    end
  end
end
