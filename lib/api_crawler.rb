require 'net/http'
require 'json'

class ApiCrawler
  attr_reader :num_pages, :pageno, :start_page, :stop_page, :total_pages, :url

  def initialize(options={})
    @benchmark_output = options[:benchmark_output]
    @output = options[:output]
    @num_pages = options[:num_pages] || Float::INFINITY
    @num_pages_processed = 0
    @start_page = options[:start_page]
    @stop_page = options[:stop_page] || Float::INFINITY
    @url = options[:url] || raise(ArgumentError, "Must supply :url")
    @pageno = options[:start_page] || 0
  end

  def crawl(options={})
    @start_page = options[:start_page] if options[:start_page]
    @stop_page = options[:stop_page] if options[:stop_page]

    next_uri = URI.parse(@url)
    next_uri.query = {page: @start_page}.to_query if @start_page

    while next_uri do
      benchmark(next_uri) do
        http = Net::HTTP.new(next_uri.host, next_uri.port)
        http.open_timeout = 3600
        http.read_timeout = 3600
        response = http.start do |http|
          path = if next_uri.query
            next_uri.path.to_s + "?" + next_uri.query
          else
            next_uri.path.to_s
          end
          http.get path
        end
        next_uri = process_response_body_and_get_next_page_uri(next_uri, response.body)
      end
    end
  end

  def pages_left?
    raise "Cannot inquire about the API until you've crawled it!" unless @total_pages

    if limit_paging? && pageno >= stop_page
      false
    elsif pageno >= total_pages
      false
    else
      true
    end
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

  def limit_paging?
    @stop_page != Float::INFINITY
  end

  def process_response_body_and_get_next_page_uri(request_uri, response_body)
    json = JSON.parse(response_body)
    @output.puts response_body
    @num_pages_processed += 1

    meta = json["meta"] || raise("Missing meta element in:\n #{json.inspect}")
    @pageno = meta["page"] || raise("Missing page inside of meta element in:\n #{meta.inspect}")
    @total_pages = meta["total_pages"] || raise("Missing total_pages inside of meta element in:\n #{meta.inspect}")

    if @pageno <= @total_pages && @pageno <= @stop_page && @num_pages_processed <= @num_pages
      next_uri = URI.parse(@url)
      next_uri.query = {page: @pageno+1}.to_query
      next_uri
    else
      nil
    end
  end

end
