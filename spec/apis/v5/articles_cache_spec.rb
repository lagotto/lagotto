require "rails_helper"

describe "/api/v5/articles", :type => :api do
  let(:user) { FactoryGirl.create(:user) }
  let(:api_key) { user.authentication_token }

  context "caching", :caching => true do

    context "index" do
      let(:articles) { FactoryGirl.create_list(:article_with_events, 2) }
      let(:article_list) { articles.map { |article| "#{article.doi_escaped}" }.join(",") }
      let(:uri) { "http://#{ENV['HOSTNAME']}/api/v5/articles?ids=#{article_list}&type=doi&api_key=#{api_key}" }

      it "can cache articles" do
        articles.all? do |article|
          key = article.decorate(:context => { source: 'citeulike' }).cache_key
          expect(Rails.cache.exist?("jbuilder/v5/#{key}")).to be false
        end
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        sleep 1

        article = articles.first
        key = article.decorate(:context => { source: 'citeulike' }).cache_key
        response = Rails.cache.read("jbuilder/v5/#{key}")
        response_source = response["sources"][0]
        expect(response["doi"]).to eql(article.doi)
        expect(response["issued"]["date-parts"][0]).to eql([article.year, article.month, article.day])
        expect(response_source["metrics"]["total"].to_i).to eql(article.retrieval_statuses.first.event_count)
        expect(response_source["events"]).to be_nil
      end

      # it "can cache an article" do
      #   Rails.cache.exist?("jbuilder/v5/#{cache_key_list}//hash").should_not be true
      #   get uri, nil, 'HTTP_ACCEPT' => 'application/json'
      #   last_response.status.should == 200

      #   sleep 1

      #   article = articles.first
      #   response = Rails.cache.read("jbuilder/v5/#{article.decorate(:context => { :source => [1] }).cache_key}//hash").first
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
      let(:key) { "jbuilder/v5/#{article.decorate(:context => { source: 'citeulike' }).cache_key}" }
      let(:title) { "Foo" }
      let(:event_count) { 75 }

      it "does not use a stale cache when an article is updated" do
        expect(Rails.cache.exist?(key)).to be false
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        sleep 1

        expect(Rails.cache.exist?(key)).to be true
        response = Rails.cache.read(key)
        expect(response["title"]).to eql(article.title)
        expect(response["title"]).not_to eql(title)

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        article.update_attributes!(title: title)

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)
        cache_key = "jbuilder/v5/#{article.decorate(:context => { source: 'citeulike' }).cache_key}"
        expect(cache_key).not_to eql(key)
        expect(Rails.cache.exist?(cache_key)).to be true
        response = Rails.cache.read(cache_key)
        expect(response["title"]).to eql(article.title)
        expect(response["title"]).to eql(title)
      end

      it "does not use a stale cache when a source is updated" do
        expect(Rails.cache.exist?(key)).to be false
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        sleep 1

        expect(Rails.cache.exist?(key)).to be true
        response = Rails.cache.read(key)
        update_date = response["update_date"]

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        article.retrieval_statuses.first.update_attributes!(event_count: event_count)
        # TODO: make sure that touch works in production
        article.touch

        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)
        cache_key = "jbuilder/v5/#{article.decorate(:context => { source: 'citeulike' }).cache_key}"
        expect(cache_key).not_to eql(key)
        expect(Rails.cache.exist?(cache_key)).to be true
        response = Rails.cache.read(cache_key)
        expect(response["update_date"]).to be > update_date
      end

      it "does not use a stale cache when the source query parameter changes" do
        expect(Rails.cache.exist?(key)).to be false
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        sleep 1

        response = Rails.cache.read(key)
        expect(response["sources"].size).to eq(1)

        source_uri = "#{uri}&source=crossref"
        get source_uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["total"]).to eq(1)
        item = response["data"].first
        expect(item["doi"]).to eql(article.doi)
        expect(item["issued"]["date-parts"][0]).to eql([article.year, article.month, article.day])
        expect(item["sources"]).to be_empty
      end

      it "does not use a stale cache when the info query parameter changes" do
        expect(Rails.cache.exist?(key)).to be false
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        sleep 1

        detail_uri = "#{uri}&info=detail"
        get detail_uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"][0]
        expect(data["doi"]).to eql(article.doi)
        expect(data["issued"]["date-parts"][0]).to eql([article.year, article.month, article.day])

        response_source = data["sources"][0]
        expect(response_source["metrics"]["total"]).to eq(article.retrieval_statuses.first.event_count)
        expect(response_source["metrics"]["readers"]).to eq(article.retrieval_statuses.first.event_count)
        expect(response_source["events"]).not_to be_nil

        summary_uri = "#{uri}&info=summary"
        get summary_uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"][0]
        expect(data["sources"]).to be_nil
        expect(data["doi"]).to eql(article.doi)
        expect(data["issued"]["date-parts"][0]).to eql([article.year, article.month, article.day])
      end
    end
  end
end
