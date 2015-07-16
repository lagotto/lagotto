require "rails_helper"
require "stringio"

describe ApiCrawler do
  include WebMock::API

  before do
    WebMock.disable_net_connect!
  end

  after do
    WebMock.allow_net_connect!
  end

  let(:api_crawler){ ApiCrawler.new(crawler_options) }
  let(:crawler_options){
    {
      benchmark_output: nil,
      output: output,
      num_pages: nil,
      start_page: nil,
      stop_page: nil,
      url: "www.example.com"
    }
  }

  let(:output){ StringIO.new }

  def build_response_with_body(options)
    {
      status: options.fetch(:status, 200),
      body: {
        meta: {
          status: options.fetch(:status, "ok"),
          total: options.fetch(:total, 1),
          total_pages: options.fetch(:total_pages, 1),
          page: options.fetch(:page, 1),
        },
        items: options.fetch(:items, [1,2,3])
      }.to_json
    }
  end

  describe "constructing" do
    it "prepends http:// when not provided" do
      expect(ApiCrawler.new(url:"foo.com").url).to eq("http://foo.com")
    end

    it "leaves the url alone when http:// is present" do
      expect(ApiCrawler.new(url:"http://foo.com").url).to eq("http://foo.com")
    end

    it "leaves the url alone when https:// is present" do
      expect(ApiCrawler.new(url:"https://foo.com").url).to eq("https://foo.com")
    end
  end

  describe '#crawl' do
    context "and there is only one page" do
      let(:page_1_response){ build_response_with_body(total_pages:1, page: 1) }
      let(:page_1_response_with_query_params){ build_response_with_body(total_pages:1, page: 1, items: ["query", "params"]) }

      before do
        stub_request(:get, "www.example.com").to_return page_1_response
        stub_request(:get, "www.example.com?foo=bar&baz=2").to_return page_1_response_with_query_params
      end

      it "crawls the page writing the response to :output" do
        api_crawler.crawl
        output.rewind
        expect(output.read).to eq("#{page_1_response[:body]}\n")
      end

      it "writes benchmark information when :benchmark_output is supplied as an IO" do
        benchmark_output = StringIO.new
        crawler_options[:benchmark_output] = benchmark_output
        api_crawler.crawl
        benchmark_output.rewind
        expect(benchmark_output.read).to match(/^http:\/\/www.example.com took \d+.\d+ seconds$/)
      end

      it "respects any passed in query params" do
        crawler_options[:url] = "http://www.example.com?foo=bar&baz=2"
        api_crawler.crawl
        output.rewind
        expect(output.read).to eq("#{page_1_response_with_query_params[:body]}\n")
      end
    end

    context "and there are multiple pages" do
      let(:page_1_response){ build_response_with_body(page:1, total_pages:3) }
      let(:page_2_response){ build_response_with_body(page:2, total_pages:3) }
      let(:page_3_response){ build_response_with_body(page:3, total_pages:3) }
      let(:page_1_response_with_query_params){ build_response_with_body(page: 1, total_pages:3, items: ["query", "params"]) }
      let(:page_2_response_with_query_params){ build_response_with_body(page: 2, total_pages:3, items: ["query", "params"]) }
      let(:page_3_response_with_query_params){ build_response_with_body(page: 3, total_pages:3, items: ["query", "params"]) }

      before do
        stub_request(:get, "www.example.com").to_return page_1_response
        stub_request(:get, "www.example.com").with(query: hash_including(page:'2')).to_return page_2_response
        stub_request(:get, "www.example.com").with(query: hash_including(page:'3')).to_return page_3_response
        stub_request(:get, "www.example.com").with(query: {foo:'bar', baz:'1'}).to_return page_1_response_with_query_params
        stub_request(:get, "www.example.com").with(query: hash_including(foo:'bar', baz:'1', page:'2')).to_return page_2_response_with_query_params
        stub_request(:get, "www.example.com").with(query: hash_including(foo:'bar', baz:'1', page:'3')).to_return page_3_response_with_query_params
      end

      it "crawls all of the pages writing each response to its own line in :output" do
        api_crawler.crawl
        output.rewind
        expect(output.read).to eq([
          page_1_response[:body],
          page_2_response[:body],
          page_3_response[:body]
        ].join("\n") + "\n")
      end

      it "writes benchmark information when :benchmark_output is supplied as an IO" do
        benchmark_output = StringIO.new
        crawler_options[:benchmark_output] = benchmark_output
        api_crawler.crawl
        benchmark_output.rewind
      end

      it "tells us that there are no more pages to crawl after all have been crawled" do
        expect {
          api_crawler.crawl
        }.to change(api_crawler, :pages_left?).to(false)
      end

      it "respects any passed in query params and continues to pass them along in each request" do
        crawler_options[:url] = "http://www.example.com/?baz=1&foo=bar"
        api_crawler.crawl
        output.rewind
        expect(output.read).to eq([
          page_1_response_with_query_params[:body],
          page_2_response_with_query_params[:body],
          page_3_response_with_query_params[:body]
        ].join("\n") + "\n")
      end
    end

    context "and the responses include newlines" do
      it "removes the newlines when writing to :output" do
      end
    end

    context "and we've been asked to stop before we run out of pages" do
      let(:page_1_response){ build_response_with_body(page:1, total_pages:3) }
      let(:page_2_response){ build_response_with_body(page:2, total_pages:3) }

      before do
        crawler_options[:stop_page] = 2

        stub_request(:get, "www.example.com").to_return page_1_response
        stub_request(:get, "www.example.com").with(query: hash_including(page:'2')).to_return page_2_response
      end

      it "crawls only up to :stop_page" do
        api_crawler.crawl
        output.rewind
        expect(output.read).to eq([
          page_1_response[:body],
          page_2_response[:body]
        ].join("\n") + "\n")
      end

      it "tell us that there are no more pages to crawl since we've reached the specified stop_page" do
        expect {
          api_crawler.crawl
        }.to change(api_crawler, :pages_left?).to(false)
      end
    end

    context "and we've been told to crawl a specific number of pages" do
      let(:page_1_response){ build_response_with_body(page:1, total_pages:3) }
      let(:page_2_response){ build_response_with_body(page:2, total_pages:3) }

      before do
        crawler_options[:num_pages] = 2

        stub_request(:get, "www.example.com").to_return page_1_response
        stub_request(:get, "www.example.com").with(query: hash_including(page:'2')).to_return page_2_response
      end

      it "crawls only the specified :num_pages writing each response to its own line in :output" do
        api_crawler.crawl
        output.rewind
        expect(output.read).to eq([
          page_1_response[:body],
          page_2_response[:body],
        ].join("\n") + "\n")
      end

      it "tells us that there are more pages to crawl after all have been crawled" do
        api_crawler.crawl
        expect(api_crawler.pages_left?).to be(true)
      end
    end

    context "and we've been asked to start on a page besides the first one" do
      let(:page_2_response){ build_response_with_body(page:2, total_pages:3) }
      let(:page_3_response){ build_response_with_body(page:3, total_pages:3) }

      before do
        crawler_options[:start_page] = 2

        stub_request(:get, "www.example.com").with(query: hash_including(page:'2')).to_return page_2_response
        stub_request(:get, "www.example.com").with(query: hash_including(page:'3')).to_return page_3_response
      end

      it "crawls all of the pages writing each response to its own line in :output" do
        api_crawler.crawl
        output.rewind
        expect(output.read).to eq([
          page_2_response[:body],
          page_3_response[:body]
        ].join("\n") + "\n")
      end
    end

    context "and an API page returns a malformed response body" do
      it "raises an error when the response is missing the meta element" do
        page_1_response = { status:200, body: {}.to_json }
        stub_request(:get, "www.example.com").to_return page_1_response
        expect{
          api_crawler.crawl
        }.to raise_error(ApiCrawler::MalformedResponseError, "Missing meta element in:\n #{page_1_response[:body]}")
      end

      it "raises an error when the response is missing the total_pages property" do
        page_1_response = { status:200, body: {meta: {page: 1}}.to_json }
        stub_request(:get, "www.example.com").to_return page_1_response
        expect{
          api_crawler.crawl
        }.to raise_error(ApiCrawler::MalformedResponseError, "Missing total_pages property in the meta element in:\n #{page_1_response[:body]}")
      end

      it "raises an error when the response is missing the page property" do
        page_1_response = { status:200, body: {meta: {total_pages: 1}}.to_json }
        stub_request(:get, "www.example.com").to_return page_1_response
        expect{
          api_crawler.crawl
        }.to raise_error(ApiCrawler::MalformedResponseError, "Missing page property in the meta element in:\n #{page_1_response[:body]}")
      end

      it "raises an error when the response is not valid JSON" do
        page_1_response = { status:200, body: "This is not JSON." }
        stub_request(:get, "www.example.com").to_return page_1_response
        expect{
          api_crawler.crawl
        }.to raise_error(ApiCrawler::MalformedResponseError, "Response body was not valid JSON in:\n #{page_1_response[:body]}")
      end
    end

    context "and an API page returns a non-200" do
      let(:page_1_response){ build_response_with_body(total_pages: 1, page: 1)}

      it "it doesn't care if it returns a parseable response body" do
        stub_request(:get, "www.example.com").to_return page_1_response
        expect{ api_crawler.crawl }.to_not raise_error
        output.rewind
        expect(output.read).to eq("#{page_1_response[:body]}\n")
      end
    end
  end


end
