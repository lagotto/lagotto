require "rails_helper"

describe "/api/v4/articles", :type => :api do
  let(:error) { { "total" => 0, "total_pages" => 0, "page" => 0, "success" => nil, "error" => "You are not authorized to access this page.", "data" => [] } }
  let(:password) { user.password }
  let(:headers) { { 'HTTP_ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user.username, password) } }

  context "create" do
    let(:uri) { "/api/v4/works" }
    let(:params) do
      { "work" => { "doi" => "10.1371/journal.pone.0036790",
                       "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                       "year" => 2012,
                       "month" => 5,
                       "day" => 15 } }
    end

    context "as admin user" do
      let(:user) { FactoryGirl.create(:admin_user) }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(201)

        response = JSON.parse(last_response.body)
        expect(response["success"]).to eq ("Article created.")
        expect(response["error"]).to be_nil
        expect(response["data"]["doi"]).to eq (params["work"]["doi"])
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, :role => "staff") }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(201)

        response = JSON.parse(last_response.body)
        expect(response["success"]).to eq ("Article created.")
        expect(response["error"]).to be_nil
        expect(response["data"]["doi"]).to eq (params["work"]["doi"])
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
        expect(response["error"]).to eq ({"doi"=>["has already been taken"]})
        expect(response["success"]).to be_nil
        expect(response["data"]).to be_empty
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
        expect(last_response.status).to eq(422)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq ({ "work" => ["parameter is required"] })
        expect(response["success"]).to be_nil
        expect(response["data"]).to be_empty
      end
    end

    context "with missing title and year params" do
      before(:each) { allow(Date).to receive(:today).and_return(Date.new(2013, 9, 5)) }

      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) do
        { "work" => { "doi" => "10.1371/journal.pone.0036790",
                         "title" => nil, "year" => nil } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq ({ "title"=>["can't be blank"], "year"=>["is not a number", "should be between 1650 and 2014"] })
        expect(response["success"]).to be_nil
        expect(response["data"]).to be_empty
      end
    end

    context "with unpermitted params" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) { { "work" => { "foo" => "bar", "baz" => "biz" } } }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq ({ "foo" => ["unpermitted parameter"],
                                       "baz" => ["unpermitted parameter"] })
        expect(response["success"]).to be_nil
        expect(response["data"]).to be_empty

        expect(Alert.count).to eq(1)
        alert = Alert.first
        expect(alert.class_name).to eq("ActiveModel::ForbiddenAttributesError")
        expect(alert.status).to eq(422)
      end
    end

    context "with params in wrong format" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) { { "work" => "10.1371/journal.pone.0036790 2012-05-15 New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail" } }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)
        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq ("Undefined method.")
        expect(response["success"]).to be_nil
        expect(response["data"]).to be_empty

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
        expect(response["success"]).to eq ("Article updated.")
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
        expect(response["error"]).to eq ("No article found.")
        expect(response["success"]).to be_nil
        expect(response["data"]).to be_empty
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
        expect(last_response.status).to eq(422)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq ({"work"=>["parameter is required"]})
        expect(response["success"]).to be_nil
        expect(response["data"]).to be_empty

        expect(Alert.count).to eq(1)
        alert = Alert.first
        expect(alert.class_name).to eq("ActionController::ParameterMissing")
        expect(alert.status).to eq(422)
      end
    end

    context "with missing title and year params" do
      before(:each) { allow(Date).to receive(:today).and_return(Date.new(2013, 9, 5)) }

      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) { { "work" => { "doi" => "10.1371/journal.pone.0036790", "title" => nil, "year" => nil } } }

      it "JSON" do
        put uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq("title"=>["can't be blank"], "year"=>["is not a number", "should be between 1650 and 2014"])
        expect(response["success"]).to be_nil
        expect(response["data"]).to be_empty
      end
    end

    context "with unpermitted params" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) { { "work" => { "foo" => "bar", "baz" => "biz" } } }

      it "JSON" do
        put uri, params, headers
        expect(last_response.status).to eq(422)

        response = JSON.parse(last_response.body)
        expect(response["error"]).to eq({ "foo"=>["unpermitted parameter"], "baz"=>["unpermitted parameter"] })
        expect(response["success"]).to be_nil
        expect(response["data"]).to be_empty

        expect(Alert.count).to eq(1)
        alert = Alert.first
        expect(alert.class_name).to eq("ActiveModel::ForbiddenAttributesError")
        expect(alert.status).to eq(422)
      end
    end
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
        expect(response["success"]).to eq ("Article deleted.")
        expect(response["error"]).to be_nil
        expect(response["data"]["doi"]).to eq (work.doi)
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
        expect(response["error"]).to eq ("No work found.")
        expect(response["success"]).to be_nil
        expect(response["data"]).to be_empty
      end
    end
  end
end
