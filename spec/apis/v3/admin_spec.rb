require "spec_helper"

describe "/api/v3/articles" do
  
  context "create" do
    context "as admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:params) {{ "article" => { "doi" => "10.1371/journal.pone.0036790",
                                     "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                                     "published_on" => "2012-05-15" }}}
      let(:uri) { "/api/v3/articles?api_key=#{user.authentication_token}"}

      it "JSON" do
        post uri, params, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(201)

        response = JSON.parse(last_response.body)
        response["article"].should eq (params["article"])
        response["success"].should eq ("Article created.")
      end
    
      it "XML" do
        post uri, params, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(201)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)["hash"]
        response["article"].should eq (params["article"])
        response["success"].should eq ("Article created.")
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:api_user) }
      let(:params) {{ "article" => { "doi" => "10.1371/journal.pone.0036790",
                                     "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                                     "published_on" => "2012-05-15" }}}
      let(:uri) { "/api/v3/articles?api_key=#{user.authentication_token}"}
      let(:error) {{"error"=>"You are not authorized to access this page."}}

      it "JSON" do
        post uri, params, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(401)

        response = JSON.parse(last_response.body)
        response.should eq (error)
      end
    
      it "XML" do
        post uri, params, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(401)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)["hash"]
        response.should eq (error)
      end
    end

    context "with wrong API key" do
      let(:user) { FactoryGirl.create(:user) }
      let(:params) {{ "article" => { "doi" => "10.1371/journal.pone.0036790",
                                     "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                                     "published_on" => "2012-05-15" }}}
      let(:uri) { "/api/v3/articles?api_key=12345"}
      let(:error) {{"error"=>"You are not authorized to access this page."}}

      it "JSON" do
        post uri, params, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(401)

        response = JSON.parse(last_response.body)
        response.should eq (error)
      end
    
      it "XML" do
        post uri, params, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(401)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)["hash"]
        response.should eq (error)
      end
    end

    context "with missing title" do
      let(:user) { FactoryGirl.create(:user) }
      let(:params) {{ "article" => { "doi" => "10.1371/journal.pone.0036790",
                                     "title" => nil,
                                     "published_on" => "2012-05-15" }}}
      let(:uri) { "/api/v3/articles?api_key=#{user.authentication_token}"}

      it "JSON" do
        post uri, params, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(400)

        response = JSON.parse(last_response.body)
        response["article"].should eq (params["article"])
        response["error"].should eq ({"title"=>["can't be blank"]})
      end
    
      it "XML" do
        post uri, params, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(400)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)["hash"]
        response["article"].should eq (params["article"])
        response["error"].should eq ({"error"=>"Title can't be blank"})
      end
    end
  end
  
  context "update" do
    context "as admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:article) { FactoryGirl.create(:article) }
      let(:params) {{ "article" => { "doi" => article.doi,
                                     "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                                     "published_on" => "2012-05-15" }}}
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?api_key=#{user.authentication_token}"}

      it "JSON" do
        put uri, params, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)
        response["article"].should eq ({ "doi" => article.doi })
        response["success"].should eq ("Article updated.")
      end
    
      it "XML" do
        put uri, params, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)["hash"]
        response["article"].should eq ({ "doi" => article.doi })
        response["success"].should eq ("Article updated.")
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:api_user) }
      let(:article) { FactoryGirl.create(:article) }
      let(:params) {{ "article" => { "doi" => article.doi,
                                     "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                                     "published_on" => "2012-05-15" }}}
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?api_key=#{user.authentication_token}"}
      let(:error) {{"error"=>"You are not authorized to access this page."}}

      it "JSON" do
        put uri, params, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(401)

        response = JSON.parse(last_response.body)
        response.should eq (error)
      end
    
      it "XML" do
        put uri, params, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(401)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)["hash"]
        response.should eq (error)
      end
    end

    context "with wrong API key" do
      let(:user) { FactoryGirl.create(:user) }
      let(:article) { FactoryGirl.create(:article) }
      let(:params) {{ "article" => { "doi" => article.doi,
                                     "title" => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
                                     "published_on" => "2012-05-15" }}}
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?api_key=#{user.authentication_token}"}
      let(:error) {{"error"=>"You are not authorized to access this page."}}

      it "JSON" do
        put uri, params, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(401)

        response = JSON.parse(last_response.body)
        response.should eq (error)
      end
    
      it "XML" do
        put uri, params, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(401)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)["hash"]
        response.should eq (error)
      end
    end
  end

  context "destroy" do
    context "as admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:article) { FactoryGirl.create(:article) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?api_key=#{user.authentication_token}"}

      it "JSON" do
        delete uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)
        response["article"].should eq ({ "doi" => article.doi })
        response["success"].should eq ("Article deleted.")
      end
    
      it "XML" do
        delete uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)["hash"]
        response["article"].should eq ({ "doi" => article.doi })
        response["success"].should eq ("Article deleted.")
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:api_user) }
      let(:article) { FactoryGirl.create(:article) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?api_key=#{user.authentication_token}"}
      let(:error) {{"error"=>"You are not authorized to access this page."}}

      it "JSON" do
        delete uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(401)

        response = JSON.parse(last_response.body)
        response.should eq (error)
      end
    
      it "XML" do
        delete uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(401)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)["hash"]
        response.should eq (error)
      end
    end

    context "with wrong API key" do
      let(:user) { FactoryGirl.create(:user) }
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?api_key=#{user.authentication_token}"}
      let(:error) {{"error"=>"You are not authorized to access this page."}}

      it "JSON" do
        delete uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(401)

        response = JSON.parse(last_response.body)
        response.should eq (error)
      end
    
      it "XML" do
        delete uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(401)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)["hash"]
        response.should eq (error)
      end
    end
  end
end