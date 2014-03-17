require "spec_helper"

describe "/api/v5/articles" do
  let(:user) { FactoryGirl.create(:user) }
  let(:api_key) { user.authentication_token }

  context "index" do

    context "more than 50 articles in query" do
      let(:articles) { FactoryGirl.create_list(:article_with_events, 55) }

      before(:each) do
        article_list = articles.collect { |article| "#{article.doi_escaped}" }.join(",")
        @uri = "/api/v5/articles?ids=#{article_list}&type=doi&api_key=#{api_key}"
      end

      it "JSON" do
        get @uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"]
        data.length.should == 50
        data.any? do |article|
          article["doi"] == articles[0].doi
          article["issued"]["date_parts"] == [articles[0].year, articles[0].month, articles[0].day]
        end.should be_true
      end
    end

    context "summary information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v5/articles?ids=#{article.doi_escaped}&type=doi&info=summary&api_key=#{api_key}"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        response["total"].should == 1
        item = response["data"].first
        item["doi"].should eq(article.doi)
        item["issued"]["date_parts"].should eq([article.year, article.month, article.day])
        item["sources"].should be_nil
      end
    end

    context "detail information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v5/articles?ids=#{article.doi_escaped}&info=detail&api_key=#{api_key}"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        response["total"].should == 1
        item = response["data"].first
        item["doi"].should eq(article.doi)
        item["issued"]["date_parts"].should eq([article.year, article.month, article.day])

        item_source = item["sources"][0]
        item_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        item_source["metrics"]["shares"].should eq(article.retrieval_statuses.first.event_count)
        item_source["events"].should_not be_nil
      end
    end
  end
end