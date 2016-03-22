require 'rails_helper'

describe Agent, type: :model, vcr: true do

  context "HTTP" do
    let(:work) { FactoryGirl.create(:work, :with_events) }
    let(:url) { "http://127.0.0.1/api/v3/articles/info:doi/#{work.doi}" }
    let(:data) { { "name" => "Fred" } }
    let(:post_data) { { "name" => "Jack" } }

    context "response" do
      it "get json" do
        stub = stub_request(:get, url).to_return(:body => data.to_json, :status => 200, :headers => { "Content-Type" => "application/json" })
        response = subject.get_result(url)
        expect(response).to eq(data)
      end

      it "get xml" do
        stub = stub_request(:get, url).to_return(:body => data.to_xml, :status => 200, :headers => { "Content-Type" => "application/xml" })
        response = subject.get_result(url, content_type: 'xml')
        expect(response).to eq('hash' => data)
      end

      it "get html" do
        stub = stub_request(:get, url).to_return(:body => data.to_s, :status => 200, :headers => { "Content-Type" => "text/html" })
        response = subject.get_result(url, content_type: 'html')
        expect(response).to eq(data.to_s)
      end

      it "post xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:body => data.to_xml, :status => 200, :headers => { "Content-Type" => "text/html" })
        subject.get_result(url, content_type: 'xml', data: post_data.to_xml) { |response| expect(Hash.from_xml(response.to_s)["hash"]).to eq(data) }
      end
    end

    context "empty response" do
      it "get json" do
        stub = stub_request(:get, url).to_return(:body => nil, :status => 200, :headers => { "Content-Type" => "application/json" })
        response = subject.get_result(url)
        expect(response).to be_nil
      end

      it "get xml" do
        stub = stub_request(:get, url).to_return(:body => nil, :status => 200, :headers => { "Content-Type" => "application/xml" })
        response = subject.get_result(url, content_type: 'xml')
        expect(response).to be_blank
      end

      it "get html" do
        stub = stub_request(:get, url).to_return(:body => nil, :status => 200, :headers => { "Content-Type" => "text/html" })
        response = subject.get_result(url, content_type: 'html')
        expect(response).to be_blank
      end

      it "post xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:body => nil, :status => 200, :headers => { "Content-Type" => "application/xml" })
        subject.get_result(url, content_type: 'xml', data: post_data.to_xml) { |response| expect(response).to be_nil }
      end
    end

    context "not found" do
      let(:error) { { "error" => "Not Found"} }

      it "get json" do
        stub = stub_request(:get, url).to_return(:body => error.to_json, :status => [404], :headers => { "Content-Type" => "application/json" })
        expect(subject.get_result(url)).to eq(error: error['error'], status: 404)
        expect(Notification.count).to eq(0)
      end

      it "get xml" do
        stub = stub_request(:get, url).to_return(:body => error.to_xml, :status => [404], :headers => { "Content-Type" => "application/xml" })
        expect(subject.get_result(url, content_type: 'xml')).to eq(error: { 'hash' => error }, status: 404)
        expect(Notification.count).to eq(0)
      end

      it "get html" do
        stub = stub_request(:get, url).to_return(:body => error.to_s, :status => [404], :headers => { "Content-Type" => "text/html" })
        expect(subject.get_result(url, content_type: 'html')).to eq(error: error.to_s, status: 404)
        expect(Notification.count).to eq(0)
      end

      it "post xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:body => error.to_xml, :status => [404], :headers => { "Content-Type" => "application/xml" })
        subject.get_result(url, content_type: 'xml', data: post_data.to_xml) { |response| expect(Hash.from_xml(response.to_s)["hash"]).to eq(error) }
        expect(Notification.count).to eq(0)
      end
    end

    context "request timeout" do
      it "get json" do
        stub = stub_request(:get, url).to_return(:status => [408])
        response = subject.get_result(url)
        expect(response).to eq(error: "the server responded with status 408 for #{url}", status: 408)
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
        expect(notification.status).to eq(408)
      end

      it "get xml" do
        stub = stub_request(:get, url).to_return(:status => [408])
        response = subject.get_result(url, content_type: 'xml')
        expect(response).to eq(error: "the server responded with status 408 for #{url}", status: 408)
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
        expect(notification.status).to eq(408)
      end

      it "get html" do
        stub = stub_request(:get, url).to_return(:status => [408])
        response = subject.get_result(url, content_type: 'html')
        expect(response).to eq(error: "the server responded with status 408 for #{url}", status: 408)
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
        expect(notification.status).to eq(408)
      end

      it "post xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:status => [408])
        subject.get_result(url, content_type: 'xml', data: post_data.to_xml) { |response| expect(response).to be_nil }
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
        expect(notification.status).to eq(408)
      end
    end

    context "request timeout internal" do
      it "get json" do
        stub = stub_request(:get, url).to_timeout
        response = subject.get_result(url)
        expect(response).to eq(error: "Excon::Errors::Timeout for #{url}", status: 408)
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
        expect(notification.message).to include("Excon::Errors::Timeout")
        expect(notification.status).to eq(408)
      end

      it "get xml" do
        stub = stub_request(:get, url).to_timeout
        response = subject.get_result(url, content_type: 'xml')
        expect(response).to eq(error: "Excon::Errors::Timeout for #{url}", status: 408)
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
        expect(notification.message).to include("Excon::Errors::Timeout")
        expect(notification.status).to eq(408)
      end

      it "get html" do
        stub = stub_request(:get, url).to_timeout
        response = subject.get_result(url, content_type: 'html')
        expect(response).to eq(error: "Excon::Errors::Timeout for #{url}", status: 408)
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
        expect(notification.message).to include("Excon::Errors::Timeout")
        expect(notification.status).to eq(408)
      end

      it "post xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_timeout
        subject.get_result(url, content_type: 'xml', data: post_data.to_xml) { |response| expect(response).to be_nil }
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
        expect(notification.message).to include("Excon::Errors::Timeout")
        expect(notification.status).to eq(408)
      end
    end

    context "too many requests" do
      it "get json" do
        stub = stub_request(:get, url).to_return(:status => [429])
        response = subject.get_result(url)
        expect(response).to eq(error: "the server responded with status 429 for #{url}. Rate-limit  exceeded.", status: 429)
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPTooManyRequests")
        expect(notification.status).to eq(429)
      end

      it "get xml" do
        stub = stub_request(:get, url).to_return(:status => [429])
        response = subject.get_result(url, content_type: 'xml')
        expect(response).to eq(error: "the server responded with status 429 for #{url}. Rate-limit  exceeded.", status: 429)
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPTooManyRequests")
        expect(notification.status).to eq(429)
      end

      it "get html" do
        stub = stub_request(:get, url).to_return(:status => [429])
        response = subject.get_result(url, content_type: 'html')
        expect(response).to eq(error: "the server responded with status 429 for #{url}. Rate-limit  exceeded.", status: 429)
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPTooManyRequests")
        expect(notification.status).to eq(429)
      end

      it "post xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:status => [429])
        subject.get_result(url, content_type: 'xml', data: post_data.to_xml) { |response| expect(response).to be_nil }
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPTooManyRequests")
        expect(notification.status).to eq(429)
      end
    end

    context "redirect requests" do
      let(:redirect_url) { "http://www.example.org" }

      it "redirect" do
        stub_request(:get, url).to_return(status: 301, headers: { location: redirect_url })
        stub_request(:get, redirect_url).to_return(status: 200, body: "Test")
        response = subject.get_result(url)
        expect(response).to eq("Test")
        expect(Notification.count).to eq(0)
      end

      it "redirect four times" do
        stub_request(:get, url).to_return(status: 301, headers: { location: redirect_url })
        stub_request(:get, redirect_url).to_return(status: 301, headers: { location: redirect_url + "/x" })
        stub_request(:get, redirect_url+ "/x").to_return(status: 301, headers: { location: redirect_url + "/y" })
        stub_request(:get, redirect_url+ "/y").to_return(status: 301, headers: { location: redirect_url + "/z" })
        stub_request(:get, redirect_url + "/z").to_return(status: 200, body: "Test")
        response = subject.get_result(url)
        expect(response).to eq("Test")
        expect(Notification.count).to eq(0)
      end

      it "too many requests" do
        stub = stub_request(:get, url).to_return(status: 301, headers: { location: redirect_url })
        response = subject.get_result(url, limit: 0)
        expect(response).to eq(error: "too many redirects; last one to: #{redirect_url} for #{url}", status: nil)
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("FaradayMiddleware::RedirectLimitReached")
        expect(notification.status).to eq(nil)
      end

      it "redirect work" do
        work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000030")
        response = subject.get_result(work.doi_as_url(work.doi), content_type: "html", limit: 10)
        expect(response).to include(work.doi)
        expect(Notification.count).to eq(0)
      end
    end

    context "store agent_id with error" do
      it "get json" do
        stub = stub_request(:get, url).to_return(:status => [429])
        response = subject.get_result(url, agent_id: 1)
        expect(response).to eq(error: "the server responded with status 429 for #{url}. Rate-limit  exceeded.", status: 429)
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPTooManyRequests")
        expect(notification.status).to eq(429)
        expect(notification.agent_id).to eq(1)
      end

      it "get xml" do
        stub = stub_request(:get, url).to_return(:status => [429])
        response = subject.get_result(url, content_type: 'xml', agent_id: 1)
        expect(response).to eq(error: "the server responded with status 429 for #{url}. Rate-limit  exceeded.", status: 429)
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPTooManyRequests")
        expect(notification.agent_id).to eq(1)
      end

      it "get html" do
        stub = stub_request(:get, url).to_return(:status => [429])
        response = subject.get_result(url, content_type: 'html', agent_id: 1)
        expect(response).to eq(error: "the server responded with status 429 for #{url}. Rate-limit  exceeded.", status: 429)
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPTooManyRequests")
        expect(notification.status).to eq(429)
        expect(notification.agent_id).to eq(1)
      end

      it "post xml" do
        stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:status => [429])
        subject.get_result(url, content_type: 'xml', data: post_data.to_xml, agent_id: 1) { |response| expect(response).to be_nil }
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPTooManyRequests")
        expect(notification.agent_id).to eq(1)
      end
    end
  end
end
