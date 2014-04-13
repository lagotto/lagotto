require 'spec_helper'

describe Article do

  context "HTTP" do
    let(:article) { FactoryGirl.create(:article_with_events) }
    let(:url) { "http://127.0.0.1/api/v3/articles/info:doi/#{article.doi}" }
    let(:data) { { "name" => "Fred" } }
    let(:post_data) { { "name" => "Jack" } }

    context "canonical URL" do

      it "get_canonical_url" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1371/journal.pone.0000030")
        url = "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000030"
        stub = stub_request(:get, "http://dx.doi.org/#{article.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_canonical_url(article.doi_as_url)
        response.should eq(url)
        Alert.count.should == 0
        stub.should have_been_requested
      end

      it "get_canonical_url with jsessionid" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1371/journal.pone.0000030")
        url = "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000030;jsessionid=5362E4D61F1953ADA2CB3F746E58AAC2.f01t03"
        clean_url = "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000030"
        stub = stub_request(:get, "http://dx.doi.org/#{article.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_canonical_url(article.doi_as_url)
        response.should eq(clean_url)
        Alert.count.should == 0
        stub.should have_been_requested
      end

      it "get_canonical_url with cookies" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1080/10629360600569196")
        url = "http://www.tandfonline.com/doi/abs/10.1080/10629360600569196"
        stub = stub_request(:get, "http://dx.doi.org/#{article.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_canonical_url(article.doi_as_url)
        response.should eq(url)
        Alert.count.should == 0
        stub.should have_been_requested
      end

      it "get_canonical_url with <link rel='canonical'/>" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1371/journal.pone.0000030")
        url = "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000030"
        stub = stub_request(:get, "http://dx.doi.org/#{article.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url }, :body => File.read(fixture_path + 'article_canonical.html'))
        response = subject.get_canonical_url(article.doi_as_url)
        response.should eq(url)
        Alert.count.should == 0
        stub.should have_been_requested
      end

      it "get_canonical_url with <meta property='og:url'/>" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1371/journal.pone.0000030")
        url = "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000030"
        stub = stub_request(:get, "http://dx.doi.org/#{article.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url }, :body => File.read(fixture_path + 'article_opengraph.html'))
        response = subject.get_canonical_url(article.doi_as_url)
        response.should eq(url)
        Alert.count.should == 0
        stub.should have_been_requested
      end

      it "get_canonical_url with <link rel='canonical'/> mismatch" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1371/journal.pone.0000030")
        url = "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000030"
        stub = stub_request(:get, "http://dx.doi.org/#{article.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url }, :body => File.read(fixture_path + 'article.html'))
        response = subject.get_canonical_url(article.doi_as_url)
        response.should be_nil
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPBadRequest")
        alert.status.should == 400
        alert.message.should eq("Canonical URL mismatch: http://dx.plos.org/10.1371/journal.pone.0000030 for #{url}")
        stub.should have_been_requested
      end

      it "get_canonical_url with not found error" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1371/journal.pone.0000030")
        stub = stub_request(:get, "http://dx.doi.org/#{article.doi}").to_return(:status => 404, :body => File.read(fixture_path + 'doi_not_found.html'))
        response = subject.get_canonical_url(article.doi_as_url)
        response.should be_blank
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Faraday::Error::ResourceNotFound")
        alert.status.should == 404
        stub.should have_been_requested
      end

      it "get_canonical_url unauthorized error" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1371/journal.pone.0000030")
        stub = stub_request(:get, "http://dx.doi.org/#{article.doi}").to_return(:status => 401)
        response = subject.get_canonical_url(article.doi_as_url)
        response.should be_nil
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPUnauthorized")
        alert.status.should == 401
        stub.should have_been_requested
      end

      it "get_canonical_url with timeout error" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1371/journal.pone.0000030")
        stub = stub_request(:get, "http://dx.doi.org/#{article.doi}").to_return(:status => [408])
        response = subject.get_canonical_url(article.doi_as_url)
        response.should be_nil
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.status.should == 408
        stub.should have_been_requested
      end
    end
  end
end
