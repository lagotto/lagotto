require "rails_helper"

describe "/api/v7/works", :type => :api, vcr: true do
  let(:error) { { "meta" => { "status" => "error", "error" => "You are not authorized to access this page." } } }
  let(:user) { FactoryGirl.create(:admin_user) }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version=7",
      "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
  end

  context "create" do
    let(:uri) { "/api/works" }
    let(:params) do

      { "work" => { "pid" => "http://doi.org/10.1371/journal.pone.0036790",
                    "doi" => "10.1371/journal.pone.0036790",
                    "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                    "publisher_id" => "340",
                    "year" => 2012,
                    "month" => 5,
                    "day" => 15 } }
    end

    before(:each) { FactoryGirl.create(:publisher) }

    context "as admin user" do
      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(201)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["status"]).to eq("created")
        expect(response["meta"]["error"]).to be_nil
        expect(response["work"]["DOI"]).to eq (params["work"]["doi"])
        expect(response["work"]["publisher_id"]).to eq (params["work"]["publisher_id"])
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

    context "work exists" do
      let(:work) { FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.pone.0036790", doi: "10.1371/journal.pone.0036790") }
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
        expect(response["meta"]["error"]).to eq("pid"=>["can't be blank"], "doi"=>["has already been taken"])
        expect(response["meta"]["status"]).to eq("error")
        expect(response["work"]).to be_blank
      end
    end

    context "with missing work param" do
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
        expect(response["meta"]["error"]).to eq ("param is missing or the value is empty: work")
        expect(response["meta"]["status"]).to eq("error")
        expect(response["work"]).to be_blank
      end
    end

    context "with missing title and year params" do
      before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

      let(:params) do
        { "work" => { "doi" => "10.1371/journal.pone.0036790",
                      "title" => nil, "year" => nil } }
      end

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(400)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["error"]).to eq("pid"=>["can't be blank"], "title"=>["can't be blank"], "year"=>["is not a number"])
        expect(response["meta"]["status"]).to eq("error")
        expect(response["work"]).to be_blank
      end
    end

    context "with unpermitted params" do
      let(:params) { { "work" => { "foo" => "bar", "baz" => "biz" } } }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["error"]).to eq("found unpermitted parameters: foo, baz")
        expect(response["meta"]["status"]).to eq("error")
        expect(response["work"]).to be_blank

        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("ActionController::UnpermittedParameters")
        expect(notification.status).to eq(422)
      end
    end

    context "with params in wrong format" do
      let(:params) { { "work" => "10.1371/journal.pone.0036790 2012-05-15 New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail" } }

      it "JSON" do
        post uri, params, headers
        expect(last_response.status).to eq(422)
        response = JSON.parse(last_response.body)
        expect(response["meta"]["error"]).to start_with("undefined method")
        expect(response["meta"]["status"]).to eq("error")
        expect(response["work"]).to be_blank

        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("NoMethodError")
        expect(notification.status).to eq(422)
      end
    end
  end

  context "update" do
    let(:work) { FactoryGirl.create(:work) }
    let(:uri) { "/api/works/#{work.pid}" }
    let(:params) do

      { "work" => { "doi" => work.doi,
                    "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                    "year" => 2012,
                    "month" => 5,
                    "day" => 15 } }
    end

    context "as admin user" do
      it "JSON" do
        put uri, params, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["status"]).to eq("updated")
        expect(response["meta"]["error"]).to be_nil
        expect(response["work"]["DOI"]).to eq(work.doi)
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, role: "staff") }

      it "JSON" do
        put uri, params, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, role: "user") }

      it "JSON" do
        put uri, params, headers
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
        put uri, params, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "work not found" do
      let(:uri) { "/api/works/#{work.pid}x" }

      it "JSON" do
        put uri, params, headers
        expect(last_response.status).to eq(404)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["error"]).to eq ("The page you are looking for doesn't exist.")
      end
    end

    context "with missing work param" do
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
        expect(response["meta"]["error"]).to eq ("param is missing or the value is empty: work")

        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("ActionController::ParameterMissing")
        expect(notification.status).to eq(400)
      end
    end

    context "with missing title and year params" do
      before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

      let(:params) { { "work" => { "pid" => "http://doi.org/10.1371/journal.pone.0036790", "doi" => "10.1371/journal.pone.0036790", "title" => nil, "year" => nil } } }

      it "JSON" do
        put uri, params, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["status"]).to eq("updated")
        expect(response["meta"]["error"]).to be_nil
        expect(response["work"]["DOI"]).to eq(params["work"]["doi"])
        expect(response["work"]["author"]).to eq([{"family"=>"Senter", "given"=>"Phil"},
                                                  {"family"=>"Kirkland", "given"=>"James I."},
                                                  {"family"=>"DeBlieux", "given"=>"Donald D."},
                                                  {"family"=>"Madsen", "given"=>"Scott"},
                                                  {"family"=>"Toth", "given"=>"Natalie"}])
      end
    end
  end

  context "destroy" do
    let(:work) { FactoryGirl.create(:work) }
    let(:uri) { "/api/works/#{work.pid}" }

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

    context "work not found" do
      let(:uri) { "/api/works/#{work.pid}x" }

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
