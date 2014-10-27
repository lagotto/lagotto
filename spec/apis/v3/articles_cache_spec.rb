require "spec_helper"

describe "/api/v3/articles" do
  let(:user) { FactoryGirl.create(:user) }
  let(:api_key) { user.authentication_token }

  context "caching", :caching => true do

    context "index" do
      let(:articles) { FactoryGirl.create_list(:article_with_events, 2) }
      let(:article_list) { articles.map { |article| "#{article.doi_escaped}" }.join(",") }
      let(:cache_key_list) { articles.map { |article| "#{article.decorate.cache_key}" }.join("/") }

      before(:each) do
        @uri = "/api/v3/articles?ids=#{article_list}&type=doi&api_key=#{api_key}"
      end

      it "can cache articles in JSON" do
        Rails.cache.exist?("rabl/v3/#{cache_key_list}//json").should_not be_true
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        article = articles.first
        response = Rails.cache.read("rabl/v3/#{cache_key_list}//json")
        response = JSON.parse(response).first
        response_source = response["sources"][0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eql(article.retrieval_statuses.first.event_count)
        response_source["events"].should be_nil
      end

      it "can cache articles in XML" do
        Rails.cache.exist?("rabl/v3/#{cache_key_list}//xml").should_not be_true
        get @uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        last_response.status.should == 200

        sleep 1

        article = articles.first
        response = Rails.cache.read("rabl/v3/#{cache_key_list}//xml")
        response = Hash.from_xml(response)
        response = response["articles"]["article"][0]
        response_source = response["sources"]["source"]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].to_i.should eq(article.retrieval_statuses.first.event_count)
        response_source["events"].should be_nil
      end
    end

    context "show" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?api_key=#{api_key}" }
      let(:key) { "rabl/v3/#{ArticleDecorator.decorate(article).cache_key}" }
      let(:title) { "Foo" }
      let(:event_count) { 75 }

      it "can cache an article in JSON" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true

        response = Rails.cache.read("#{key}//json")
        response = JSON.parse(response).first
        response_source = response["sources"][0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eql(article.retrieval_statuses.first.event_count)
        response_source["events"].should be_nil
      end

      it "can cache an article in XML" do
        Rails.cache.exist?("#{key}//xml").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//xml").should be_true

        response = Rails.cache.read("#{key}//xml")
        response = Hash.from_xml(response)
        response = response["articles"]["article"]
        response_source = response["sources"]["source"]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].to_i.should eq(article.retrieval_statuses.first.event_count)
        response_source["events"].should be_nil
      end

      it "can cache JSON and XML separately" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//json").should_not be_true
        Rails.cache.exist?("#{key}//xml").should be_true
      end

      it "can make API requests 2x faster" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200
        ApiRequest.count.should eql(2)
        ApiRequest.last.view_duration.should be < 0.5 * ApiRequest.first.view_duration
      end

      it "does not use a stale cache when an article is updated" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true
        response = Rails.cache.read("#{key}//json")
        response = JSON.parse(response).first
        response["title"].should eql(article.title)
        response["title"].should_not eql(title)

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        article.update_attributes!(title: title)

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200
        cache_key = "rabl/v3/#{ArticleDecorator.decorate(article).cache_key}"
        cache_key.should_not eql(key)
        Rails.cache.exist?("#{cache_key}//json").should be_true
        response = Rails.cache.read("#{cache_key}//json")
        response = JSON.parse(response).first
        response["title"].should eql(article.title)
        response["title"].should eql(title)
      end

      it "does not use a stale cache when a source is updated" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true
        response = Rails.cache.read("#{key}//json")
        response = JSON.parse(response).first
        update_date = response["update_date"]

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        article.retrieval_statuses.first.update_attributes!(event_count: event_count)
        # TODO: make sure that touch works in production
        article.touch

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200
        cache_key = "rabl/v3/#{ArticleDecorator.decorate(article).cache_key}"
        cache_key.should_not eql(key)
        Rails.cache.exist?("#{cache_key}//json").should be_true
        response = Rails.cache.read("#{cache_key}//json")
        response = JSON.parse(response).first
        response["update_date"].should be > update_date
      end

      it "does not use a stale cache when the source query parameter changes" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true
        response = Rails.cache.read("#{key}//json")
        response = JSON.parse(response).first
        response["sources"].size.should eql(1)

        source_uri = "#{uri}&source=crossref"
        get source_uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should eql(404)
        JSON.parse(last_response.body).should eql("error" => "Source not found.")
      end

      it "does not use a stale cache when the info query parameter changes" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true

        history_uri = "#{uri}&info=history"
        get history_uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        response_source["metrics"]["shares"].should eq(article.retrieval_statuses.first.event_count)
        response_source["events"].should be_nil

        summary_uri = "#{uri}&info=summary"
        get summary_uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)[0]
        response["sources"].should be_nil
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
      end
    end
  end
end
