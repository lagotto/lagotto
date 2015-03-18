require "rails_helper"

describe "/api/v4/articles", :type => :api do
  let(:error) { { "error"=>"You are not authorized to access this page." } }
  let(:password) { user.password }
  let(:headers) { { 'HTTP_ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user.email, password) } }

  context "create" do
    let(:uri) { "/api/v4/articles" }
    let(:params) do
      { "work" => { "doi" => "10.1371/journal.pone.0036790",
                    "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                    "publisher_id" => 340,
                    "year" => 2012,
                    "month" => 5,
                    "day" => 15 } }
    end

    context "as admin user" do
      let(:user) { FactoryGirl.create(:admin_user) }

      it "JSON" do
        post uri, params, headers
        # expect(last_response.status).to eq(201)

        response = JSON.parse(last_response.body)
        expect(response["success"]).to eq ("Work created.")
        expect(response["error"]).to be_nil
        expect(response["data"]["doi"]).to eq (params["work"]["doi"])
        expect(response["data"]["publisher_id"]).to eq (params["work"]["publisher_id"])
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, :role => "staff") }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "with wrong password" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:password) { 12345678 }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "work exists" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:work) { FactoryGirl.create(:work) }
      let(:params) do
        { "work" => { "doi" => work.doi,
                      "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                      "year" => 2012,
                      "month" => 5,
                      "day" => 15 } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq ({"doi"=>["has already been taken"], "pid"=>["has already been taken"]})
        expect(response["success"]).to be_nil
        expect(response["data"]).to be_nil
      end
    end

    context "with missing work param" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) do
        { "data" => { "doi" => "10.1371/journal.pone.0036790",
                      "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                      "year" => 2012,
                      "month" => 5,
                      "day" => 15 } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq ("param is missing or the value is empty: work")
        expect(response["success"]).to be_nil
        expect(response["data"]).to be_nil
      end
    end

    context "with missing title and year params" do
      before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) do
        { "work" => { "doi" => "10.1371/journal.pone.0036790",
                      "title" => nil, "year" => nil } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq ({ "title"=>["can't be blank"], "year"=>["is not a number"], "published_on"=>["is before 1650"] })
        expect(response["success"]).to be_nil
        expect(response["data"]).to be_nil
      end
    end

    context "with unpermitted params" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) { { "work" => { "foo" => "bar", "baz" => "biz" } } }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq("doi"=>["must provide at least one persistent identifier"], "pid_type"=>["can't be blank"], "pid"=>["can't be blank"], "title"=>["can't be blank"])
        expect(response["success"]).to be_nil
        expect(response["data"]).to be_nil

        # expect(Alert.count).to eq(1)
        # alert = Alert.first
        # expect(alert.class_name).to eq("ActiveModel::ForbiddenAttributesError")
        # expect(alert.status).to eq(422)
      end
    end

    context "with params in wrong format" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) { { "work" => "10.1371/journal.pone.0036790 2012-05-15 New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail" } }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)
        response = JSON.parse(last_response.body)
        expect(response["error"]).to start_with("undefined method")
        expect(response["success"]).to be_nil
        expect(response["data"]).to be_nil

        expect(Alert.count).to eq(1)
        alert = Alert.first
        expect(alert.class_name).to eq("NoMethodError")
        expect(alert.status).to eq(422)
      end
    end
  end

  context "update" do
    let(:work) { FactoryGirl.create(:work) }
    let(:uri) { "/api/v4/articles/info:doi/#{work.doi}" }
    let(:params) do
      { "work" => { "doi" => work.doi,
                    "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                    "year" => 2012,
                    "month" => 5,
                    "day" => 15 } }
    end

    context "as admin user" do
      let(:user) { FactoryGirl.create(:admin_user) }

      it "JSON" do
        put uri, params, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["success"]).to eq ("Work updated.")
        expect(response["error"]).to be_nil
        expect(response["data"]["doi"]).to eq (work.doi)
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, :role => "staff") }

      it "JSON" do
        put uri, params, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }

      it "JSON" do
        put uri, params, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "with wrong password" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:password) { 12345678 }

      it "JSON" do
        put uri, params, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "work not found" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/v4/articles/info:doi/#{work.doi}x" }

      it "JSON" do
        put uri, params, headers
        expect(last_response.status).to eq(404)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq ("Work not found.")
      end
    end

    context "with missing work param" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) do
        { "data" => { "doi" => "10.1371/journal.pone.0036790",
                      "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                      "year" => 2012,
                      "month" => 5,
                      "day" => 15 } }
      end

      it "JSON" do
        put uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq ("param is missing or the value is empty: work")

        expect(Alert.count).to eq(1)
        alert = Alert.first
        expect(alert.class_name).to eq("ActionController::ParameterMissing")
        expect(alert.status).to eq(400)
      end
    end

    context "with missing title and year params" do
      before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) { { "work" => { "doi" => "10.1371/journal.pone.0036790", "title" => nil, "year" => nil } } }

      it "JSON" do
        put uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq("title"=>["can't be blank"], "year"=>["is not a number"], "published_on"=>["is before 1650"])
      end
    end

    # context "with unpermitted params" do
    #   let(:user) { FactoryGirl.create(:admin_user) }
    #   let(:params) { { "work" => { "foo" => "bar", "baz" => "biz" } } }

    #   it "JSON" do
    #     put uri, params, headers
    #     #expect(last_response.status).to eq(422)

    #     response = JSON.parse(last_response.body)
    #     #expect(response["error"]).to eq({ "foo"=>["unpermitted parameter"], "baz"=>["unpermitted parameter"] })
    #     expect(response["success"]).to be_nil
    #     expect(response["data"]).to be_empty

    #     expect(Alert.count).to eq(1)
    #     alert = Alert.first
    #     expect(alert.class_name).to eq("ActiveModel::ForbiddenAttributesError")
    #     expect(alert.status).to eq(422)
    #   end
    # end
  end

  context "destroy" do
    let(:work) { FactoryGirl.create(:work) }
    let(:uri) { "/api/v4/articles/info:doi/#{work.doi}" }

    context "as admin user" do
      let(:user) { FactoryGirl.create(:admin_user) }

      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["success"]).to eq ("Work deleted.")
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, :role => "staff") }

      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }

      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "with wrong password" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:password) { 12345678 }

      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "work not found" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/v4/articles/info:doi/#{work.doi}x" }

      it "JSON" do
        delete uri, nil, headers
        expect(last_response.status).to eq(404)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq ("Work not found.")
        expect(response["success"]).to be_nil
        expect(response["data"]).to be_nil
      end
    end
  end
end
