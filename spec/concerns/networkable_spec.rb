require 'spec_helper'

describe Source do

  context "HTTP" do
    let(:article) { FactoryGirl.create(:article_with_events) }
    let(:url) { "http://127.0.0.1/api/v3/articles/info:doi/#{article.doi}" }
    let(:data) { { "name" => "Fred" } }
    let(:post_data) { { "name" => "Jack" } }

    context "response" do
      it "get json" do
        stub = stub_request(:get, url).to_return(:body => data.to_json, :status => 200, :headers => { "Content-Type" => "application/json" })
        response = subject.get_result(url)
        response.should eq(data)
      end

      it "get xml" do
        stub = stub_request(:get, url).to_return(:body => data.to_xml, :status => 200, :headers => { "Content-Type" => "application/xml" })
        response = subject.get_result(url, content_type: 'xml')
        response.should eq('hash' => data)
      end

      it "get html" do
        stub = stub_request(:get, url).to_return(:body => data.to_s, :status => 200, :headers => { "Content-Type" => "text/html" })
        response = subject.get_result(url, content_type: 'html')
        response.should eq(data.to_s)
      end

      it "post xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:body => data.to_xml, :content_type => 'application/xml', :status => 200)
        subject.get_result(url, content_type: 'xml', data: post_data.to_xml) { |response| Hash.from_xml(response.to_s)["hash"].should eq(data) }
      end
    end

    context "empty response" do
      it "get json" do
        stub = stub_request(:get, url).to_return(:body => nil, :status => 200, :headers => { "Content-Type" => "application/json" })
        response = subject.get_result(url)
        response.should be_nil
      end

      it "get xml" do
        stub = stub_request(:get, url).to_return(:body => nil, :status => 200, :headers => { "Content-Type" => "application/xml" })
        response = subject.get_result(url, content_type: 'xml')
        response.should be_blank
      end

      it "get html" do
        stub = stub_request(:get, url).to_return(:body => nil, :status => 200, :headers => { "Content-Type" => "text/html" })
        response = subject.get_result(url, content_type: 'html')
        response.should be_blank
      end

      it "post xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:body => nil, :status => 200, :headers => { "Content-Type" => "application/xml" })
        subject.get_result(url, content_type: 'xml', data: post_data.to_xml) { |response| response.should be_nil }
      end
    end

    context "not found" do
      let(:error) { { "error" => "Not Found"} }

      it "get json" do
        stub = stub_request(:get, url).to_return(:body => error.to_json, :status => [404], :headers => { "Content-Type" => "application/json" })
        subject.get_result(url).should eq(error: error['error'])
        Alert.count.should == 0
      end

      it "get xml" do
        stub = stub_request(:get, url).to_return(:body => error.to_xml, :status => [404], :headers => { "Content-Type" => "application/xml" })
        subject.get_result(url, content_type: 'xml').should eq(error: { 'hash' => error })
        Alert.count.should == 0
      end

      it "get html" do
        stub = stub_request(:get, url).to_return(:body => error.to_s, :status => [404], :headers => { "Content-Type" => "text/html" })
        subject.get_result(url, content_type: 'html').should eq(error: error.to_s)
        Alert.count.should == 0
      end

      it "post xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:body => error.to_xml, :status => [404], :headers => { "Content-Type" => "application/xml" })
        subject.get_result(url, content_type: 'xml', data: post_data.to_xml) { |response| Hash.from_xml(response.to_s)["hash"].should eq(error) }
        Alert.count.should == 0
      end
    end

    context "request timeout" do
      it "get json" do
        stub = stub_request(:get, url).to_return(:status => [408])
        response = subject.get_result(url)
        response.should eq(error: "the server responded with status 408 for #{url}")
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.status.should == 408
      end

      it "get xml" do
        stub = stub_request(:get, url).to_return(:status => [408])
        response = subject.get_result(url, content_type: 'xml')
        response.should eq(error: "the server responded with status 408 for #{url}")
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.status.should == 408
      end

      it "get html" do
        stub = stub_request(:get, url).to_return(:status => [408])
        response = subject.get_result(url, content_type: 'html')
        response.should eq(error: "the server responded with status 408 for #{url}")
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.status.should == 408
      end

      it "post xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:status => [408])
        subject.get_result(url, content_type: 'xml', data: post_data.to_xml) { |response| response.should be_nil }
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.status.should == 408
      end
    end

    context "request timeout internal" do
      it "get json" do
        stub = stub_request(:get, url).to_timeout
        response = subject.get_result(url)
        response.should eq(error: "request timed out for #{url}")
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.message.should include("request timed out")
        alert.status.should == 408
      end

      it "get xml" do
        stub = stub_request(:get, url).to_timeout
        response = subject.get_result(url, content_type: 'xml')
        response.should eq(error: "request timed out for #{url}")
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.message.should include("request timed out")
        alert.status.should == 408
      end

      it "get html" do
        stub = stub_request(:get, url).to_timeout
        response = subject.get_result(url, content_type: 'html')
        response.should eq(error: "request timed out for #{url}")
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.message.should include("request timed out")
        alert.status.should == 408
      end

      it "post xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_timeout
        subject.get_result(url, content_type: 'xml', data: post_data.to_xml) { |response| response.should be_nil }
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.message.should include("request timed out")
        alert.status.should == 408
      end
    end

    context "too many requests" do
      it "get json" do
        stub = stub_request(:get, url).to_return(:status => [429])
        response = subject.get_result(url)
        response.should eq(error: "the server responded with status 429 for #{url}")
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPClientError")
        alert.status.should == 429
      end

      it "get xml" do
        stub = stub_request(:get, url).to_return(:status => [429])
        response = subject.get_result(url, content_type: 'xml')
        response.should eq(error: "the server responded with status 429 for #{url}")
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPClientError")
        alert.status.should == 429
      end

      it "get html" do
        stub = stub_request(:get, url).to_return(:status => [429])
        response = subject.get_result(url, content_type: 'html')
        response.should eq(error: "the server responded with status 429 for #{url}")
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPClientError")
        alert.status.should == 429
      end

      it "post xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:status => [429])
        subject.get_result(url, content_type: 'xml', data: post_data.to_xml) { |response| response.should be_nil }
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPClientError")
        alert.status.should == 429
      end
    end

    context "store source_id with error" do
      it "get json" do
        stub = stub_request(:get, url).to_return(:status => [429])
        response = subject.get_result(url, source_id: 1)
        response.should eq(error: "the server responded with status 429 for #{url}")
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPClientError")
        alert.status.should == 429
        alert.source_id.should == 1
      end

      it "get xml" do
        stub = stub_request(:get, url).to_return(:status => [429])
        response = subject.get_result(url, content_type: 'xml', source_id: 1)
        response.should eq(error: "the server responded with status 429 for #{url}")
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPClientError")
        alert.source_id.should == 1
      end

      it "get html" do
        stub = stub_request(:get, url).to_return(:status => [429])
        response = subject.get_result(url, content_type: 'html', source_id: 1)
        response.should eq(error: "the server responded with status 429 for #{url}")
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPClientError")
        alert.status.should == 429
        alert.source_id.should == 1
      end

      it "post xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:status => [429])
        subject.get_result(url, content_type: 'xml', data: post_data.to_xml, source_id: 1) { |response| response.should be_nil }
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPClientError")
        alert.source_id.should == 1
      end
    end

    context "save to file" do
      it "save contents from url" do
        url = "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000030"
        filename = "test"
        stub = stub_request(:get, url).to_return(:status => 200, :body => "Test")
        response = subject.save_to_file(url, filename)
        response.should eq(filename)
        Alert.count.should == 0
      end

      it "should catch errors fetching a file" do
        url = "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000030"
        filename = "test"
        stub = stub_request(:get, url).to_return(:status => [408])
        response = subject.save_to_file(url, filename)
        response.should eq(error: "the server responded with status 408 for #{url}")
        stub.should have_been_requested
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.status.should == 408
      end

      it "should catch errors saving a file" do
        url = "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000030"
        filename = ""
        stub = stub_request(:get, url).to_return(:status => 200, :body => "Test")
        response = subject.save_to_file(url, filename)
        response.should be_nil
        stub.should have_been_requested
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Errno::EISDIR")
        alert.message.should include("Is a directory")
        alert.status.should == 500
      end
    end

    context "read from file" do
      let(:filename) { 'test.xml'}
      let(:content) { [{ 'a' => 1 }, { 'b' => 2 }, { 'c' => 3 }] }

      before(:each) { File.open("#{Rails.root}/data/#{filename}", 'w') { |file| file.write(content.to_xml) } }

      it "read XML file" do
        response = subject.read_from_file(filename)
        response.should eq('objects' => content)
        Alert.count.should == 0
      end

      it "should catch errors reading a missing file" do
        File.delete("#{Rails.root}/data/#{filename}")
        response = subject.read_from_file(filename)
        response.should be_nil
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Errno::ENOENT")
        alert.message.should start_with "No such file or directory"
      end
    end
  end
end
