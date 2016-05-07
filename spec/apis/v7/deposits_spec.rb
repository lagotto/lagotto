require "rails_helper"

describe "/api/v7/deposits", :type => :api do
  before(:each) do
    allow(Time).to receive(:now).and_return(Time.mktime(2015, 4, 8))
    allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8))
  end

  let(:deposit) { FactoryGirl.build(:deposit) }
  let(:error) { { "meta" => { "status" => "error", "error" => "You are not authorized to access this page." } } }
  let(:success) { { "id"=>deposit.uuid,
                    "state"=>"waiting",
                    "message_type"=>"relation",
                    "message_action"=>"create",
                    "source_token"=>"citeulike_123",
                    "subj_id"=>"http://www.citeulike.org/user/dbogartoit",
                    "obj_id"=>"http://doi.org/10.1371/journal.pmed.0030186",
                    "prefix" => "10.1371",
                    "relation_type_id"=>"bookmarks",
                    "source_id"=>"citeulike",
                    "total"=>1,
                    "occurred_at"=>deposit.occurred_at.utc.iso8601,
                    "timestamp"=>deposit.timestamp,
                    "subj"=>{ "pid"=>"http://www.citeulike.org/user/dbogartoit",
                              "author"=>[{"given"=>"dbogartoit"}],
                              "title"=>"CiteULike bookmarks for user dbogartoit",
                              "container-title"=>"CiteULike",
                              "issued"=>"2006-06-13T16:14:19Z",
                              "URL"=>"http://www.citeulike.org/user/dbogartoit",
                              "type"=>"entry",
                              "tracked"=>false},
                    "obj"=>{} }}

  let(:user) { FactoryGirl.create(:admin_user) }
  let(:uuid) { SecureRandom.uuid }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version=7",
      "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
  end

  context "create" do
    let(:uri) { "/api/deposits" }
    let(:params) do
      { "deposit" => { "uuid" => deposit.uuid,
                       "subj_id" => deposit.subj_id,
                       "subj" => deposit.subj,
                       "obj_id" => deposit.obj_id,
                       "relation_type_id" => deposit.relation_type_id,
                       "source_id" => deposit.source_id,
                       "source_token" => deposit.source_token } }
    end

    context "as admin user" do
      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(202)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["status"]).to eq("accepted")
        expect(response["meta"]["error"]).to be_nil
        expect(response["deposit"]).to eq (success)
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, role: "staff") }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, role: "user") }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "without source_token" do
      let(:params) do
        { "deposit" => { "uuid" => uuid,
                         "subj_id" => deposit.subj_id,
                         "subj" => deposit.subj,
                         "obj_id" => deposit.obj_id,
                         "relation_type_id" => deposit.relation_type_id,
                         "source_id" => deposit.source_id } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response).to eq("meta"=>{"status"=>"error", "error"=>{"source_token"=>["can't be blank"]}}, "deposit"=>{})
      end
    end

    context "without source_id" do
      let(:params) do
        { "deposit" => { "uuid" => uuid,
                         "subj_id" => deposit.subj_id,
                         "subj" => deposit.subj,
                         "obj_id" => deposit.obj_id,
                         "relation_type_id" => deposit.relation_type_id,
                         "source_token" => deposit.source_token } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response).to eq("meta"=>{"status"=>"error", "error"=>{"source_id"=>["can't be blank"]}}, "deposit"=>{})
      end
    end

    context "without subj_id" do
      let(:params) do
        { "deposit" => { "uuid" => uuid,
                         "subj" => deposit.subj,
                         "obj_id" => deposit.obj_id,
                         "relation_type_id" => deposit.relation_type_id,
                         "source_id" => deposit.source_id,
                         "source_token" => deposit.source_token } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response).to eq("meta"=>{"status"=>"error", "error"=>{"subj_id"=>["can't be blank"]}}, "deposit"=>{})
      end
    end

    context "with wrong API key" do
      let(:headers) do
        { "HTTP_ACCEPT" => "application/json; version=7",
          "HTTP_AUTHORIZATION" => "Token token=12345678" }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "with missing deposit param" do
      let(:params) do
        { "data" => { "uuid" => uuid,
                      "message_type" => "work",
                      "source_token" => "123" } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["error"]).to eq ("param is missing or the value is empty: deposit")
        expect(response["meta"]["status"]).to eq("error")
        expect(response["work"]).to be_blank
      end
    end

    context "with unpermitted params" do
      let(:params) do
        { "deposit" => { "uuid" => uuid,
                         "subj_id" => deposit.subj_id,
                         "source_id" => deposit.source_id,
                         "source_token" => deposit.source_token,
                         "foo" => "bar" } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["status"]).to eq("error")
        expect(response["meta"]["error"]).to eq("found unpermitted parameter: foo")
        expect(response["deposit"]).to be_blank

        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("ActionController::UnpermittedParameters")
        expect(notification.status).to eq(422)
      end
    end

    context "with params in wrong format" do
      let(:params) { { "deposit" => "10.1371/journal.pone.0036790 2012-05-15 New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail" } }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)
        response = JSON.parse(last_response.body)
        expect(response["meta"]["error"]).to start_with("undefined method")
        expect(response["meta"]["status"]).to eq("error")
        expect(response["deposit"]).to be_blank

        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("NoMethodError")
        expect(notification.status).to eq(422)
      end
    end
  end

  context "show" do
    let(:deposit) { FactoryGirl.create(:deposit) }
    let(:uri) { "/api/deposits/#{deposit.uuid}" }

    context "as admin user" do
      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["status"]).to eq("ok")
        expect(response["meta"]["error"]).to be_nil
        expect(response["deposit"]).to eq(success)
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, role: "staff") }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["status"]).to eq("ok")
        expect(response["meta"]["error"]).to be_nil
        expect(response["deposit"]).to eq(success)
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, role: "user") }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["status"]).to eq("ok")
        expect(response["meta"]["error"]).to be_nil
        expect(response["deposit"]).to eq(success)
      end
    end

    context "deposit not found" do
      let(:uri) { "/api/deposits/#{deposit.uuid}x" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(404)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["error"]).to eq ("The page you are looking for doesn't exist.")
      end
    end
  end

  context "index" do
    let(:uri) { "/api/deposits" }

    context "with no API key" do

      # Exclude the token header.
      let(:headers) do
        { "HTTP_ACCEPT" => "application/json; version=6" }
      end

      it "JSON" do
        get uri, nil, headers

        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)

        # Just test that the API can be accessed without a token.
        expect(response["meta"]["status"]).to eq("ok")
        expect(response["meta"]["error"]).to be_nil
      end
    end
  end

  context "destroy" do
    let(:deposit) { FactoryGirl.create(:deposit) }
    let(:uri) { "/api/deposits/#{deposit.uuid}" }

    context "as admin user" do
      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["status"]).to eq ("deleted")
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, role: "staff") }

      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, role: "user") }

      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "with wrong API key" do
      let(:headers) do
        { "HTTP_ACCEPT" => "application/json; version=6",
          "HTTP_AUTHORIZATION" => "Token token=12345678" }
      end

      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "deposit not found" do
      let(:uri) { "/api/deposits/#{deposit.uuid}x" }

      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(404)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["error"]).to eq ("The page you are looking for doesn't exist.")
        expect(response["meta"]["status"]).to eq("error")
        expect(response["work"]).to be_nil
      end
    end
  end
end
