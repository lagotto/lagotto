require "spec_helper"

describe "/api/v5/articles" do
  let(:user) { FactoryGirl.create(:user) }
  let(:api_key) { user.authentication_token }

  context "caching", :caching => true do

    context "index" do
      let(:articles) { FactoryGirl.create_list(:article_with_events, 2) }
      let(:article_list) { articles.map { |article| "#{article.doi_escaped}" }.join(",") }
      let(:cache_key_list) { articles.map { |article| "#{article.decorate(:context => { source: 'citeulike' }).cache_key}" }.join("/") }
      let(:uri) { "http://#{ENV['HOSTNAME']}/api/v5/articles?ids=#{article_list}&type=doi&api_key=#{api_key}" }

      it "can cache articles" do
        Rails.cache.exist?("rabl/v5/#{cache_key_list}//hash").should be false
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        article = articles.first
        response = Rails.cache.read("rabl/v5/#{cache_key_list}//hash").first
        response_source = response[:sources][0]
        response[:doi].should eql(article.doi)
        response[:issued]["date-parts"][0].should eql([article.year, article.month, article.day])
        response_source[:metrics][:total].to_i.should eql(article.retrieval_statuses.first.event_count)
        response_source[:events].should be_nil
      end

      # it "can cache an article" do
      #   Rails.cache.exist?("rabl/v5/#{cache_key_list}//hash").should_not be true
      #   get uri, nil, 'HTTP_ACCEPT' => 'application/json'
      #   last_response.status.should == 200

      #   sleep 1

      #   article = articles.first
      #   response = Rails.cache.read("rabl/v5/#{article.decorate(:context => { :source => [1] }).cache_key}//hash").first
      #   response_source = response[:sources][0]
      #   response[:doi].should eql(article.doi)
      #   response[:issued]["date-parts"][0].should eql([article.year, article.month, article.day])
      #   response_source[:metrics][:total].to_i.should eql(article.retrieval_statuses.first.event_count)
      #   response_source[:events].should be_nil
      # end
    end

    context "article is updated" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "http://#{ENV['HOSTNAME']}/api/v5/articles?ids=#{article.doi_escaped}&api_key=#{api_key}" }
      let(:key) { "rabl/v5/#{article.decorate(:context => { source: 'citeulike' }).cache_key}" }
      let(:title) { "Foo" }
      let(:event_count) { 75 }

      it "does not use a stale cache when an article is updated" do
        Rails.cache.exist?("#{key}//hash").should be false
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//hash").should be true
        response = Rails.cache.read("#{key}//hash").first
        response[:title].should eql(article.title)
        response[:title].should_not eql(title)

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        article.update_attributes!(title: title)

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200
        cache_key = "rabl/v5/#{article.decorate(:context => { source: 'citeulike' }).cache_key}"
        cache_key.should_not eql(key)
        Rails.cache.exist?("#{cache_key}//hash").should be true
        response = Rails.cache.read("#{cache_key}//hash").first
        response[:title].should eql(article.title)
        response[:title].should eql(title)
      end

      it "does not use a stale cache when a source is updated" do
        Rails.cache.exist?("#{key}//hash").should be false
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//hash").should be true
        response = Rails.cache.read("#{key}//hash").first
        update_date = response[:update_date]

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        article.retrieval_statuses.first.update_attributes!(event_count: event_count)
        # TODO: make sure that touch works in production
        article.touch

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200
        cache_key = "rabl/v5/#{article.decorate(:context => { source: 'citeulike' }).cache_key}"
        cache_key.should_not eql(key)
        Rails.cache.exist?("#{cache_key}//hash").should be true
        response = Rails.cache.read("#{cache_key}//hash").first
        response[:update_date].should be > update_date
      end

      it "does not use a stale cache when the source query parameter changes" do
        Rails.cache.exist?("#{key}//hash").should be false
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        response = Rails.cache.read("#{key}//hash").first
        response[:sources].size.should == 1

        source_uri = "#{uri}&source=crossref"
        get source_uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        response["total"].should == 1
        item = response["data"].first
        item["doi"].should eql(article.doi)
        item["issued"]["date-parts"][0].should eql([article.year, article.month, article.day])
        item["sources"].should be_empty
      end

      it "does not use a stale cache when the info query parameter changes" do
        Rails.cache.exist?("#{key}//hash").should be false
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        sleep 1

        detail_uri = "#{uri}&info=detail"
        get detail_uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"][0]
        data["doi"].should eql(article.doi)
        data["issued"]["date-parts"][0].should eql([article.year, article.month, article.day])

        response_source = data["sources"][0]
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        response_source["metrics"]["readers"].should eq(article.retrieval_statuses.first.event_count)
        response_source["events"].should_not be_nil

        summary_uri = "#{uri}&info=summary"
        get summary_uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"][0]
        data["sources"].should be_nil
        data["doi"].should eql(article.doi)
        data["issued"]["date-parts"][0].should eql([article.year, article.month, article.day])
      end
    end
  end
end
