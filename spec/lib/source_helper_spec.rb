require 'spec_helper'

# turn SourceHelper module into a class so that we can talk to it directly
class SourceHelperClass
  extend(SourceHelper)
end

describe SourceHelper do

  subject { SourceHelperClass.new }

  context "HTTP" do
    let(:article) { FactoryGirl.create(:article_with_events) }
    let(:url) { "http://127.0.0.1/api/v3/articles/info:doi/#{article.doi}"}
    let(:data) { { "name" => "Fred" } }
    let(:post_data) { { "name" => "Jack" } }

    context "response" do
      it "get_json" do
        stub = stub_request(:get, url).to_return(:body => data.to_json, :status => 200, :headers => { "Content-Type" => "application/json" })
        response = subject.get_json(url)
        response.should eq(data)
      end

      it "get_xml" do
        stub = stub_request(:get, url).to_return(:body => data.to_xml, :status => 200, :headers => { "Content-Type" => "application/xml" })
        subject.get_xml(url) { |response| Nori.new.parse(response.to_s)["hash"].should eq(data) }
      end

      it "post_xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:body => data.to_xml, :content_type => 'application/xml', :status => 200)
        subject.post_xml(url, data: post_data.to_xml) { |response| Nori.new.parse(response.to_s)["hash"].should eq(data) }
      end
    end

    context "empty response" do
      it "get_json" do
        stub = stub_request(:get, url).to_return(:body => nil, :status => 200, :headers => { "Content-Type" => "application/json" })
        response = subject.get_json(url)
        response.should be_nil
      end

      it "get_xml" do
        stub = stub_request(:get, url).to_return(:body => nil, :status => 200, :headers => { "Content-Type" => "application/xml" })
        subject.get_xml(url) { |response| response.should be_nil }
      end

      it "post_xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:body => nil, :status => 200, :headers => { "Content-Type" => "application/xml" })
        subject.post_xml(url, data: post_data.to_xml) { |response| response.should be_nil }
      end
    end

    context "not found" do
      let(:error) { { "error" => "Not Found"} }

      it "get_json" do
        stub = stub_request(:get, url).to_return(:body => error.to_json, :status => [404], :headers => { "Content-Type" => "application/json" })
        subject.get_json(url).should eq(error)
        Alert.count.should == 0
      end

      it "get_xml" do
        stub = stub_request(:get, url).to_return(:body => error.to_xml, :status => [404], :headers => { "Content-Type" => "application/xml" })
        subject.get_xml(url) { |response| Nori.new.parse(response.to_s)["hash"].should eq(error) }
        Alert.count.should == 0
      end

      it "post_xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:body => error.to_xml, :status => [404], :headers => { "Content-Type" => "application/xml" })
        subject.post_xml(url, data: post_data.to_xml) { |response| Nori.new.parse(response.to_s)["hash"].should eq(error) }
        Alert.count.should == 0
      end
    end

    context "request timeout" do

      it "get_json" do
        stub = stub_request(:get, url).to_return(:status => [408])
        subject.get_json(url).should be_nil
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.status.should == 408
      end

      it "get_xml" do
        stub = stub_request(:get, url).to_return(:status => [408])
        subject.get_xml(url) { |response| response.should be_nil }
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.status.should == 408
      end

      it "post_xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:status => [408])
        subject.post_xml(url, data: post_data.to_xml) { |response| response.should be_nil }
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.status.should == 408
      end
    end

    context "request timeout internal" do

      it "get_json" do
        stub = stub_request(:get, url).to_timeout
        subject.get_json(url).should be_nil
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.message.should include("execution expired")
        alert.status.should == 408
      end

      it "get_xml" do
        stub = stub_request(:get, url).to_timeout
        subject.get_xml(url) { |response| response.should be_nil }
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.message.should include("execution expired")
        alert.status.should == 408
      end

      it "post_xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_timeout
        subject.post_xml(url, data: post_data.to_xml) { |response| response.should be_nil }
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.message.should include("execution expired")
        alert.status.should == 408
      end
    end

    context "too many requests" do

      it "get_json" do
        stub = stub_request(:get, url).to_return(:status => [429])
        subject.get_json(url).should be_nil
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPClientError")
        alert.status.should == 429
      end

      it "get_xml" do
        stub = stub_request(:get, url).to_return(:status => [429])
        subject.get_xml(url) { |response| response.should be_nil }
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPClientError")
        alert.status.should == 429
      end

      it "post_xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:status => [429])
        subject.post_xml(url, data: post_data.to_xml) { |response| response.should be_nil }
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPClientError")
        alert.status.should == 429
      end
    end

    context "store source_id with error" do

      it "get_json" do
        stub = stub_request(:get, url).to_return(:status => [429])
        subject.get_json(url, source_id: 1).should be_nil
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPClientError")
        alert.status.should == 429
        alert.source_id.should == 1
      end

      it "get_xml" do
        stub = stub_request(:get, url).to_return(:status => [429])
        subject.get_xml(url, source_id: 1) { |response| response.should be_nil }
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPClientError")
        alert.source_id.should == 1
      end

      it "post_xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:status => [429])
        subject.post_xml(url, data: post_data.to_xml, source_id: 1) { |response| response.should be_nil }
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPClientError")
        alert.source_id.should == 1
      end
    end

    context "original URL" do

      it "get_original_url" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1371/journal.pone.0000030")
        url = "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000030"
        stub = stub_request(:head, "http://dx.doi.org/#{article.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:head, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_original_url(article.doi_as_url)
        response.should eq(url)
        Alert.count.should == 0
        stub.should have_been_requested
      end

      it "get_original_url with cookies" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1080/10629360600569196")
        url = "http://www.tandfonline.com/doi/abs/10.1080/10629360600569196"
        stub = stub_request(:head, "http://dx.doi.org/#{article.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:head, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_original_url(article.doi_as_url)
        response.should eq(url)
        Alert.count.should == 0
        stub.should have_been_requested
      end

      it "get_original_url with not found error" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1371/journal.pone.0000030")
        stub = stub_request(:head, "http://dx.doi.org/#{article.doi}").to_return(:status => 404)
        response = subject.get_original_url(article.doi_as_url)
        response.should be_nil
        Alert.count.should == 0
        stub.should have_been_requested
      end

      it "get_original_url unauthorized error" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1371/journal.pone.0000030")
        stub = stub_request(:head, "http://dx.doi.org/#{article.doi}").to_return(:status => 401)
        response = subject.get_original_url(article.doi_as_url)
        response.should be_nil
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPUnauthorized")
        alert.status.should == 401
        stub.should have_been_requested
      end

      it "get_original_url with timeout error" do
        article = FactoryGirl.create(:article_with_events, :doi => "10.1371/journal.pone.0000030")
        stub = stub_request(:head, "http://dx.doi.org/#{article.doi}").to_return(:status => [408])
        response = subject.get_original_url(article.doi_as_url)
        response.should be_nil
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.status.should == 408
        stub.should have_been_requested
      end
    end
  end

  context "CouchDB" do
    before(:each) do
      subject.put_alm_database
    end

    after(:each) do
      subject.delete_alm_database
    end

    let(:id) { "test" }
    let(:url) { "#{APP_CONFIG['couchdb_url']}#{id}" }
    let(:data) { { "name" => "Fred"} }
    let(:error) { {"error"=>"not_found", "reason"=>"missing"} }

    it "get database info" do
      rev = subject.put_alm_data(url, data: data)

      get_info = subject.get_alm_database
      db_name = Addressable::URI.parse(APP_CONFIG['couchdb_url']).path[1..-2]
      get_info["db_name"].should eq(db_name)
      get_info["disk_size"].should be > 0
      get_info["doc_count"].should eq(1)
    end

    it "put, get and delete data" do
      rev = subject.put_alm_data(url, data: data)
      rev.should_not be_nil

      get_response = subject.get_alm_data(id)
      get_response.should include("_id" => id, "_rev" => rev)

      new_rev = subject.save_alm_data(id, data: data)
      new_rev.should_not be_nil
      new_rev.should_not eq(rev)

      get_response = subject.get_alm_data(id)
      get_response.should include("_id" => id, "_rev" => new_rev)

      delete_rev = subject.remove_alm_data(id, new_rev)
      delete_rev.should_not be_nil
      delete_rev.should_not eq(rev)
      delete_rev.should include("3-")
    end

    it "get correct revision" do
      rev = subject.put_alm_data(url, data: data)
      rev.should_not be_nil

      new_rev = subject.get_alm_rev(id)
      new_rev.should_not be_nil
      new_rev.should eq(rev)
    end

    it "get nil for missing id" do
      rev = subject.get_alm_rev("xxx")
      rev.should be_nil
    end

    it "get correct revision" do
      rev = @source_helper_class.save_alm_data(id, data)
      new_rev = @source_helper_class.get_alm_rev(id)
      new_rev.should eq(rev)
    end

    it "get nil for missing id" do
      rev = @source_helper_class.get_alm_rev("xxx")
      rev.should be_nil
    end

    it "handle revisions" do
      rev = subject.save_alm_data(id, data: data)
      new_rev = subject.save_alm_data(id, data: data)
      new_rev.should_not be_nil
      new_rev.should_not eq(rev)
      delete_rev = subject.remove_alm_data(id, new_rev)
      delete_rev.should_not eq(new_rev)
    end

    it "revision conflict" do
      rev = subject.put_alm_data(url, data: data)
      new_rev = subject.put_alm_data(url, data: data)

      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPConflict")
      alert.status.should == 409
    end

    it "handle missing data" do
      get_response = subject.get_alm_data(id)
      get_response.should eq(error)
      Alert.count.should == 0
    end
  end
end
