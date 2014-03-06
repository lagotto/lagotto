require "spec_helper"

describe "/api/v4/articles" do
  let(:error) {{ "total"=>0, "total_pages"=>0, "page"=>0, "success"=>nil, "error"=>"You are not authorized to access this page.", "data"=>nil }}

  context "create" do
    let(:uri) { "/api/v4/articles"}
    let(:params) {{ "article" => { "doi" => "10.1371/journal.pone.0036790",
                                   "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                                   "year" => 2012,
                                   "month" => 5,
                                   "day" => 15 }}}

    context "as admin user" do
      let(:user) { FactoryGirl.create(:admin_user) }

      it "JSON" do
        post uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should eql(201)

        response = JSON.parse(last_response.body)
        response["success"].should eq ("Article created.")
        response["error"].should be_nil
        response["data"]["doi"].should eq (params["article"]["doi"])
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, :role => "staff") }

      it "JSON" do
        post uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should eql(201)

        response = JSON.parse(last_response.body)
        response["success"].should eq ("Article created.")
        response["error"].should be_nil
        response["data"]["doi"].should eq (params["article"]["doi"])
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }

      it "JSON" do
        post uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 401

        response = JSON.parse(last_response.body)
        response.should eq (error)
      end
    end

    context "with wrong password" do
      let(:user) { FactoryGirl.create(:admin_user) }

      it "JSON" do
        post uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:123458") }
        last_response.status.should == 401

        response = JSON.parse(last_response.body)
        response.should eq (error)
      end
    end

    context "article exists" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:article) { FactoryGirl.create(:article) }
      let(:params) {{ "article" => { "doi" => article.doi,
                                   "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                                   "year" => 2012,
                                   "month" => 5,
                                   "day" => 15 }}}

      it "JSON" do
        post uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 400

        response = JSON.parse(last_response.body)
        response["error"].should eq ({"doi"=>["has already been taken"]})
        response["success"].should be_nil
        response["data"]["doi"].should eq (params["article"]["doi"])
      end
    end

    context "with missing article param" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) {{ "data" => { "doi" => "10.1371/journal.pone.0036790",
                                  "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                                  "year" => 2012,
                                   "month" => 5,
                                   "day" => 15 }}}

      it "JSON" do
        post uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 422

        response = JSON.parse(last_response.body)
        response["error"].should eq ({"article"=>["parameter is required"]})
        response["success"].should be_nil
        response["data"].should be_nil
      end
    end

    context "with missing title and year params" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) {{ "article" => { "doi" => "10.1371/journal.pone.0036790",
                                     "title" => nil,
                                     "year" => nil }}}

      it "JSON" do
        post uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 400

        response = JSON.parse(last_response.body)
        response["error"].should eq ({"title"=>["can't be blank"], "year"=>["can't be blank", "is not a number", "should be between 1660 and 2015"]})
        response["success"].should be_nil
        response["data"]["doi"].should eq (params["article"]["doi"])
        response["data"]["title"].should be_nil
      end
    end

    context "with unpermitted params" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) {{ "article" => { "foo" => "bar", "baz" => "biz" }}}

      it "JSON" do
        post uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 422

        response = JSON.parse(last_response.body)
        response["error"].should eq ({"foo"=>["unpermitted parameter"], "baz"=>["unpermitted parameter"]})
        response["success"].should be_nil
        response["data"].should be_nil
      end
    end

    context "with params in wrong format" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) {{ "article" => "10.1371/journal.pone.0036790 2012-05-15 New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail" }}

      it "JSON" do
        post uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 422
        response = JSON.parse(last_response.body)
        response["error"].should eq ("Undefined method.")
        response["success"].should be_nil
        response["data"].should be_nil
      end
    end
  end

  context "update" do
    let(:article) { FactoryGirl.create(:article) }
    let(:uri) { "/api/v4/articles/info:doi/#{article.doi}"}
    let(:params) {{ "article" => { "doi" => article.doi,
                                   "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                                   "year" => 2012,
                                   "month" => 5,
                                   "day" => 15 }}}

    context "as admin user" do
      let(:user) { FactoryGirl.create(:admin_user) }

      it "JSON" do
        put uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        response["success"].should eq ("Article updated.")
        response["error"].should be_nil
        response["data"]["doi"].should eq (article.doi)
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, :role => "staff") }

      it "JSON" do
        put uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 401

        response = JSON.parse(last_response.body)
        response.should eq (error)
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }

      it "JSON" do
        put uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 401

        response = JSON.parse(last_response.body)
        response.should eq (error)
      end
    end

    context "with wrong password" do
      let(:user) { FactoryGirl.create(:admin_user) }

      it "JSON" do
        put uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:123458") }
        last_response.status.should == 401

        response = JSON.parse(last_response.body)
        response.should eq (error)
      end
    end

    context "article not found" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/v4/articles/info:doi/#{article.doi}x"}

      it "JSON" do
        put uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 404

        response = JSON.parse(last_response.body)
        response["error"].should eq ("No article found.")
        response["success"].should be_nil
        response["data"].should be_nil
      end
    end

    context "with missing article param" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) {{ "data" => { "doi" => "10.1371/journal.pone.0036790",
                                  "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                                  "year" => 2012,
                                  "month" => 5,
                                  "day" => 15 }}}

      it "JSON" do
        put uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 422

        response = JSON.parse(last_response.body)
        response["error"].should eq ({"article"=>["parameter is required"]})
        response["success"].should be_nil
        response["data"].should be_nil
      end
    end

    context "with missing title and year params" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) {{ "article" => { "doi" => "10.1371/journal.pone.0036790",
                                     "title" => nil,
                                     "year" => nil }}}

      it "JSON" do
        put uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 400

        response = JSON.parse(last_response.body)
        response["error"].should eq ({"title"=>["can't be blank"], "year"=>["can't be blank", "is not a number", "should be between 1660 and 2015"] })
        response["success"].should be_nil
        response["data"]["doi"].should eq (params["article"]["doi"])
        response["data"]["title"].should be_nil
      end
    end

    context "with unpermitted params" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:params) {{ "article" => { "foo" => "bar", "baz" => "biz" }}}

      it "JSON" do
        put uri, params, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 422

        response = JSON.parse(last_response.body)
        response["error"].should eq ({"foo"=>["unpermitted parameter"], "baz"=>["unpermitted parameter"]})
        response["success"].should be_nil
        response["data"].should be_nil
      end
    end
  end

  context "destroy" do
    let(:article) { FactoryGirl.create(:article) }
    let(:uri) { "/api/v4/articles/info:doi/#{article.doi}"}

    context "as admin user" do
      let(:user) { FactoryGirl.create(:admin_user) }

      it "JSON" do
        delete uri, nil, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        response["success"].should eq ("Article deleted.")
        response["error"].should be_nil
        response["data"]["doi"].should eq (article.doi)
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, :role => "staff") }

      it "JSON" do
        delete uri, nil, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 401

        response = JSON.parse(last_response.body)
        response.should eq (error)
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }

      it "JSON" do
        delete uri, nil, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 401

        response = JSON.parse(last_response.body)
        response.should eq (error)
      end
    end

    context "with wrong password" do
      let(:user) { FactoryGirl.create(:admin_user) }

      it "JSON" do
        delete uri, nil, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:123458") }
        last_response.status.should == 401

        response = JSON.parse(last_response.body)
        response.should eq (error)
      end
    end

    context "article not found" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/v4/articles/info:doi/#{article.doi}x"}

      it "JSON" do
        delete uri, nil, { 'HTTP_ACCEPT' => "application/json", 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{CGI.escape(user.username)}:#{user.password}") }
        last_response.status.should == 404

        response = JSON.parse(last_response.body)
        response["error"].should eq ("No article found.")
        response["success"].should be_nil
        response["data"].should be_nil
      end
    end
  end
end