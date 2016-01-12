require "rails_helper"

describe "/api/v6/notifications", :type => :api do
  let(:error) { { "meta"=> { "status"=>"error", "error"=>"You are not authorized to access this page." } } }
  let(:user) { FactoryGirl.create(:admin_user) }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version 6",
      "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript; version=6",
      "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
  end

  context "index" do
    context "most recent notifications" do
      let(:uri) { "/api/notifications" }
      let!(:notification) { FactoryGirl.create_list(:notification, 10) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["notifications"]
        expect(data.length).to eq(10)
        item = data.first
        expect(item["level"]).to eq ("WARN")
        expect(item["message"]).to eq ("The request timed out.")
      end
    end

    context "only unresolved notifications" do
      let(:uri) { "/api/notifications?unresolved=1" }

      before(:each) do
        FactoryGirl.create_list(:notification, 2, unresolved: false)
        FactoryGirl.create(:notification)
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["notifications"]
        expect(data.length).to eq(1)
        notification = data.first
        expect(notification["unresolved"]).to be true
      end
    end

    context "with agent" do
      let(:uri) { "/api/notifications?agent_id=citeulike" }

      before(:each) do
        FactoryGirl.create_list(:notification, 2)
        FactoryGirl.create(:notification_with_agent)
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["notifications"]
        expect(data.length).to eq(1)
        notification = data.first
        expect(notification["agent"]).to eq ("citeulike")
      end
    end

    context "with class_name" do
      let(:uri) { "/api/notifications?class_name=nomethoderror" }

      before(:each) do
        FactoryGirl.create_list(:notification, 2)
        FactoryGirl.create(:notification, class_name: "NoMethodError")
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["notifications"]
        expect(data.length).to eq(1)
        notification = data.first
        expect(notification["class_name"]).to eq ("NoMethodError")
      end
    end

    context "with level ERROR" do
      let(:uri) { "/api/notifications?level=error" }

      before(:each) do
        FactoryGirl.create_list(:notification, 2)
        FactoryGirl.create(:notification, level: Notification::ERROR)
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["notifications"]
        expect(data.length).to eq(1)
        notification = data.first
        expect(notification["level"]).to eq ("ERROR")
      end
    end

    context "with query" do
      let(:uri) { "/api/notifications?q=nomethod" }

      before(:each) do
        FactoryGirl.create_list(:notification, 2)
        FactoryGirl.create(:notification, class_name: "NoMethodError")
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["notifications"]
        expect(data.length).to eq(1)
        notification = data.first
        expect(notification["class_name"]).to eq ("NoMethodError")
      end
    end

    context "with pagination" do
      let(:uri) { "/api/notifications?page=2" }

      before(:each) { FactoryGirl.create_list(:notification, 55) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["notifications"]
        expect(data.length).to eq(5)
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, role: "staff") }
      let!(:notification) { FactoryGirl.create_list(:notification, 10) }
      let(:uri) { "/api/notifications" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["notifications"]
        expect(data.length).to eq(10)
        item = data.first
        expect(item["level"]).to eq ("WARN")
        expect(item["message"]).to eq ("The request timed out.")
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, role: "user") }
      let(:uri) { "/api/notifications" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end
  end
end
