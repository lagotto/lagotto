require "spec_helper"

describe "/api/v3/articles" do

  context "index" do
    let(:articles) { FactoryGirl.create_list(:article_with_events, 55) }

    context "more than 50 articles in query" do
      before(:each) do
        article_list = articles.collect { |article| "#{article.doi_escaped}" }.join(",")
        @uri = "/api/v3/articles?ids=#{article_list}&type=doi&api_key=12345"
      end

      it "JSON" do
        get @uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)
        response.length.should eql(50)
        response.any? do |article|
          article["doi"] == articles[0].doi
          article["publication_date"] == articles[0].published_on.to_time.utc.iso8601
        end.should be_true
      end

      it "XML" do
        get @uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)
        response = response["articles"]["article"]
        response.length.should eql(50)
        response.any? do |article|
          article["doi"] == articles[0].doi
          article["publication_date"] == articles[0].published_on.to_time.utc.iso8601
        end.should be_true
      end
    end
  end

  context "show" do

    context "show summary information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?info=summary&api_key=12345"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)[0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response["sources"].should be_nil
      end

      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)
        response = response["articles"]["article"]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response["sources"].should be_nil
      end
    end

    context "historical data after 30 days" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?days=30&api_key=12345"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.after_days(30).last.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end

      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)
        response = response["articles"]["article"]
        response_source = response["sources"]["source"]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].to_i.should eq(article.retrieval_statuses.first.retrieval_histories.after_days(30).last.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end

    end

    context "historical data after 6 months" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?months=6&api_key=12345"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.after_months(6).last.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end

      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)
        response = response["articles"]["article"]
        response_source = response["sources"]["source"]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].to_i.should eq(article.retrieval_statuses.first.retrieval_histories.after_months(6).last.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end
    end

    context "historical data until 2012" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?year=2012&api_key=12345"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.until_year(2012).last.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end

      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)
        response = response["articles"]["article"]
        response_source = response["sources"]["source"]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].to_i.should eq(article.retrieval_statuses.first.retrieval_histories.until_year(2012).last.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end
    end

    context "show detail information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?info=detail&api_key=12345"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        response_source["metrics"]["shares"].should eq(article.retrieval_statuses.first.event_count)
        #response_source["events"].should_not be_nil
        response_source["histories"].should_not be_nil

      end

      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)
        response = response["articles"]["article"]
        response_source = response["sources"]["source"]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].to_i.should eq(article.retrieval_statuses.first.event_count)
        #response_source["events"].should_not be_nil
        response_source["histories"].should_not be_nil
      end

    end

    context "show history information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?info=history&api_key=12345"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should_not be_nil
      end

      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)
        response = response["articles"]["article"]
        response_source = response["sources"]["source"]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].to_i.should eq(article.retrieval_statuses.first.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should_not be_nil
      end

    end

    context "show event information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?info=event&api_key=12345"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        response_source["metrics"]["shares"].should eq(article.retrieval_statuses.first.event_count)
        #response_source["events"].should_not be_nil
        response_source["histories"].should be_nil

      end

      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response = Nori.new(:advanced_typecasting => false).parse(last_response.body)
        response = response["articles"]["article"]
        response_source = response["sources"]["source"]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].to_i.should eq(article.retrieval_statuses.first.event_count)
        #response_source["events"].should_not be_nil
        response_source["histories"].should be_nil
      end
    end
  end
end
