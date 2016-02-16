require "rails_helper"
require "securerandom"

describe "/api/v6/deposits", :type => :api do
  let(:error) { { "meta" => { "status" => "error", "error" => "You are not authorized to access this page." } } }
  let(:user) { FactoryGirl.create(:admin_user) }
  let(:uuid) { SecureRandom.uuid }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version=6",
      "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
  end

  context "create" do
    let(:uri) { "/api/deposits" }
    let(:params) do
      { "deposit" => { "uuid" => uuid,
                       "message_type" => "mendeley",
                       "message" => { "works" => [1], "events" => [] },
                       "source_token" => "123" } }
    end

    context "as admin user" do
      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(202)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["status"]).to eq("accepted")
        expect(response["meta"]["error"]).to be_nil
        expect(response["deposit"]["id"]).to eq (uuid)
        expect(response["deposit"]["state"]).to eq ("waiting")
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

    context "with message as array" do
      let(:params) do
        { "deposit" => { "uuid" => uuid,
                         "message_type" => "mendeley",
                         "message" => ["abc"],
                         "source_token" => "123" } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response).to eq("meta"=>{"status"=>"error", "error"=>{"message"=>["should be a hash"]}}, "deposit"=>{})
      end
    end

    context "with message as string" do
      let(:params) do
        { "deposit" => { "uuid" => uuid,
                         "message_type" => "mendeley",
                         "message" => "abc",
                         "source_token" => "123" } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response).to eq("meta"=>{"status"=>"error", "error"=>{"message"=>["should be a hash"]}}, "deposit"=>{})
      end
    end

    context "with message without required hash keys" do
      let(:params) do
        { "deposit" => { "uuid" => uuid,
                         "message_type" => "mendeley",
                         "message" => { "foo" => "abc" },
                         "source_token" => "123" } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response).to eq("meta"=>{"status"=>"error", "error"=>{"message"=>["should contain works, events, contributors, or publishers"]}}, "deposit"=>{})
      end
    end

    context "with wrong API key" do
      let(:headers) do
        { "HTTP_ACCEPT" => "application/json; version=6",
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
                      "message_type" => "mendeley",
                      "message" => { "events" => [] },
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

    context "with missing uuid, message-type and message params" do
      before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

      let(:params) do
        { "deposit" => { "foo" => "baz" } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["error"]).to eq("unknown attribute 'foo' for Deposit.")
        expect(response["meta"]["status"]).to eq("error")
        expect(response["deposit"]).to be_blank
      end
    end

    context "with unpermitted params" do
      let(:params) { { "deposit" => { "foo" => "bar", "baz" => "biz" } } }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["error"]).to eq("unknown attribute 'foo' for Deposit.")
        expect(response["meta"]["status"]).to eq("error")
        expect(response["work"]).to be_blank

        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("ActiveRecord::UnknownAttributeError")
        expect(notification.status).to eq(400)
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
        expect(response["deposit"]).to eq("id"=> deposit.uuid, "state"=>"waiting", "message_type"=>"citeulike", "message_action"=>"create", "message"=>{"works"=>[], "events"=>[]}, "source_token"=>"citeulike_123", "timestamp"=> deposit.timestamp)
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
        expect(response["deposit"]).to eq("id"=> deposit.uuid, "state"=>"waiting", "message_type"=>"citeulike", "message_action"=>"create", "message"=>{"works"=>[], "events"=>[]}, "source_token"=>"citeulike_123", "timestamp"=> deposit.timestamp)
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, role: "user") }

      it "JSON" do
        get uri, nil, headers
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
        get uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
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
