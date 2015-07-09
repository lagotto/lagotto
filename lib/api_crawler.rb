require 'net/http'
require 'json'

class ApiCrawler
  attr_reader :url, :output_file

  def self.crawl_works
    output_file = ENV["OUTPUT"] || Rails.root.join("tmp/works.jsondump")
    new(
      url: "http://#{ENV['HOST']}/api/works",
      output_file: output_file,
      benchmark_file: Rails.root.join("#{output_file}.benchmarks")
    ).crawl(
      stop_on_page: 1000
    )
  end

  def initialize(options={})
    @url = options[:url] || raise(ArgumentError, "Must supply :url")
    @output_file = options[:output_file] || raise(ArgumentError, "Must supply :output_file")
    @benchmark_file = options[:benchmark_file]
  end

  def crawl(options={})
    @stop_on_page = options[:stop_on_page] || Float::INFINITY
    @output = File.open(output_file, "wb")
    @output.sync = true

    if @benchmark_file
      @benchmark_output = File.open(@benchmark_file, "wb")
      @benchmark_output.sync = true
    end

    next_uri = URI.parse(@url)

    while next_uri do
      benchmark(next_uri) do
        response_body = Net::HTTP.get(next_uri)
        next_uri = process_response_body_and_get_next_page_uri(response_body)
      end
    end
  ensure
    @output.close if @output
  end

  private

  def benchmark(uri, &blk)
    if @benchmark_output
      n = Time.now
      yield
      duration = Time.now - n
      @benchmark_output.puts "#{uri} took #{duration} seconds"
    else
      yield
    end
  end

  def process_response_body_and_get_next_page_uri(response_body)
    json = JSON.parse(response_body)
    @output.puts response_body

    meta = json["meta"] || raise("Missing meta element in:\n #{json.inspect}")
    page = meta["page"] || raise("Missing page inside of meta element in:\n #{meta.inspect}")
    total_pages = meta["total_pages"] || raise("Missing total_pages inside of meta element in:\n #{meta.inspect}")

    if page <= total_pages && page <= @stop_on_page
      next_uri = URI.parse(@url)
      next_uri.query = "page=#{page+1}"
      next_uri
    else
      nil
    end
  end

end
