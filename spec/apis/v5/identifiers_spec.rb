require "spec_helper"

describe "/api/v5/articles" do
  let(:user) { FactoryGirl.create(:user) }
  let(:api_key) { user.authentication_token }
  let(:error) { { "error" => "Article not found."} }

  context "missing api_key" do
    let(:article) { FactoryGirl.create(:article_with_events) }
    let(:uri) { "/api/v5/articles?ids=#{article.doi_escaped}" }
    let(:missing_key) { { "total" => 0, "total_pages" => 0, "page" => 0, "error" => "Missing or wrong API key.", "data" => [] } }

    it "JSON" do
      get uri, nil, 'HTTP_ACCEPT' => 'application/json'
      last_response.status.should eql(401)
      last_response.body.should eq(missing_key.to_json)
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPUnauthorized")
      alert.message.should include("Missing or wrong API key.")
      alert.content_type.should eq("application/json")
      alert.status.should == 401
    end
  end

  context "index" do
    let(:articles) { FactoryGirl.create_list(:article_with_events, 50) }

    context "articles found via DOI" do
      before(:each) do
        article_list = articles.collect { |article| "#{article.doi_escaped}" }.join(",")
        @uri = "/api/v5/articles?ids=#{article_list}&type=doi&info=summary&api_key=#{api_key}"
      end

      it "no format" do
        get @uri
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"]
        data.length.should == 50
        data.any? do |article|
          article["doi"] == articles[0].doi
          article["issued"]["date_parts"].should eql([articles[0].year, articles[0].month, articles[0].day])
        end.should be_true
      end

      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"]
        data.length.should == 50
        data.any? do |article|
          article["doi"] == articles[0].doi
          article["issued"]["date_parts"].should eql([articles[0].year, articles[0].month, articles[0].day])
        end.should be_true
      end
    end

    context "articles found via PMID" do
      before(:each) do
        article_list = articles.collect { |article| "#{article.pmid}" }.join(",")
        @uri = "/api/v5/articles?ids=#{article_list}&type=pmid&info=summary&api_key=#{api_key}"
      end


      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"]
        data.length.should == 50
        data.any? do |article|
          article["pmid"] == articles[0].pmid
        end.should be_true
      end
    end

    context "articles found via PMCID" do
      before(:each) do
        article_list = articles.collect { |article| "#{article.pmcid}" }.join(",")
        @uri = "/api/v5/articles?ids=#{article_list}&type=pmcid&info=summary&api_key=#{api_key}"
      end


      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"]
        data.length.should == 50
        data.any? do |article|
          article["pmcid"] == "2568856" #articles[0].pmcid
        end.should be_true
      end
    end

    context "articles found via Mendeley" do
      before(:each) do
        article_list = articles.collect { |article| "#{article.mendeley_uuid}" }.join(",")
        @uri = "/api/v5/articles?ids=#{article_list}&type=mendeley_uuid&info=summary&api_key=#{api_key}"
      end


      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"]
        data.length.should == 50
        data.any? do |article|
          article["mendeley_uuid"] == articles[0].mendeley_uuid
        end.should be_true
      end
    end

    context "no identifiers" do
      before(:each) do
        article_list = articles.collect { |article| "#{article.doi_escaped}" }.join(",")
        @uri = "/api/v5/articles?info=summary&api_key=#{api_key}"
      end

      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        response = JSON.parse(last_response.body)
        last_response.status.should == 200

        data = response["data"]
        data.length.should == 50
        data.any? do |article|
          article["doi"] == articles[0].doi
          article["issued"]["date_parts"].should eql([articles[0].year, articles[0].month, articles[0].day])
        end.should be_true
      end
    end

    context "no records found" do
      let(:uri) { "/api/v5/articles?ids=xxx&info=summary&api_key=#{api_key}" }
      let(:nothing_found) { { "total" => 0, "total_pages" => 0, "page" => 0, "error" => nil, "data" => [] } }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200
        last_response.body.should eq(nothing_found.to_json)
      end
    end
  end
end
