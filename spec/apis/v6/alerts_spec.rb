require "rails_helper"

describe "/api/v6/alerts", :type => :api do
  let(:error) { { "error" => "You are not authorized to access this page."} }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json",
      "Authorization" => "Token token=#{user.api_key}" }
  end

  context "index" do
    context "most recent articles" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/v6/alerts" }

      before(:each) { FactoryGirl.create_list(:alert, 55) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(50)
        alert = data.first
        expect(alert["level"]).to eq ("WARN")
        expect(alert["message"]).to eq ("The request timed out.")
      end
    end

    context "only unresolved alerts" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/v6/alerts?unresolved=1" }

      before(:each) do
        FactoryGirl.create_list(:alert, 2, unresolved: false)
        FactoryGirl.create(:alert)
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(1)
        alert = data.first
        expect(alert["unresolved"]).to be true
      end
    end

    context "with source" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/v6/alerts?source_id=citeulike" }

      before(:each) do
        FactoryGirl.create_list(:alert, 2)
        FactoryGirl.create(:alert_with_source)
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(1)
        alert = data.first
        expect(alert["source"]).to eq ("citeulike")
      end
    end

    context "with class_name" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/v6/alerts?class_name=nomethoderror" }

      before(:each) do
        FactoryGirl.create_list(:alert, 2)
        FactoryGirl.create(:alert, class_name: "NoMethodError")
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(1)
        alert = data.first
        expect(alert["class_name"]).to eq ("NoMethodError")
      end
    end

    context "with level ERROR" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/v6/alerts?level=error" }

      before(:each) do
        FactoryGirl.create_list(:alert, 2)
        FactoryGirl.create(:alert, level: Alert::ERROR)
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(1)
        alert = data.first
        expect(alert["level"]).to eq ("ERROR")
      end
    end

    context "with query" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/v6/alerts?q=nomethod" }

      before(:each) do
        FactoryGirl.create_list(:alert, 2)
        FactoryGirl.create(:alert, class_name: "NoMethodError")
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(1)
        alert = data.first
        expect(alert["class_name"]).to eq ("NoMethodError")
      end
    end

    context "with pagination" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/v6/alerts?page=2" }

      before(:each) { FactoryGirl.create_list(:alert, 55) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(5)
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }
      let(:uri) { "/api/v6/alerts" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end
  end
end
