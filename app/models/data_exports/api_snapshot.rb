require 'tempfile'

class ApiSnapshot < DataExport
  APPEND_MODE = 'append'
  CREATE_MODE = 'create'
  ALLOWED_MODES = [APPEND_MODE, CREATE_MODE]

  FILENAME_EXT = 'jsondump'

  # +data_dir+ determines where all of the reports are written to.
  class_attribute :snapshot_dir

  self.snapshot_dir = Rails.root.join("tmp/snapshots")

  def self.default_snapshot_dir
    snapshot_dir.join("snapshot_#{Time.zone.now.to_date}")
  end

  data_attribute :benchmark
  data_attribute :filename_ext
  data_attribute :mode
  data_attribute :num_pages
  data_attribute :pageno
  data_attribute :pages_per_job
  data_attribute :snapshot_dir
  data_attribute :snapshot_date
  data_attribute :start_page
  data_attribute :stop_page

  validates :url, presence: true

  def initialize(attrs={})
    attrs[:benchmark] = attrs[:benchmark] ? true : false
    super(attrs.reverse_merge(
      name: "api_snapshot",
      filename_ext: FILENAME_EXT,
      mode: CREATE_MODE,
      num_pages: 10,
      pageno: 0,
      snapshot_date: Time.zone.now.to_date,
      snapshot_dir: self.class.default_snapshot_dir,
      start_page: 1,
      stop_page: nil
    ))
  end

  def finished?
    return false unless @api_crawler
    !@api_crawler.pages_left?
  end

  def snapshot_filename
    @snapshot_filename ||= File.basename(snapshot_filepath)
  end

  def snapshot_filepath
    @snapshot_filepath ||= begin
      snapshot_filename = uri.path.gsub(/^\/*/, '').gsub('/', '_')
      "#{Pathname.new(snapshot_dir).join(snapshot_filename)}.#{filename_ext}"
    end
  end

  def zip_filepath
    @zip_filepath ||= Pathname.new("#{snapshot_filepath}.zip").to_s
  end

  def export!(options={})
    api_crawler_factory = options[:api_crawler_factory] || ApiCrawler

    touch(:started_exporting_at) unless started_exporting_at

    FileUtils.mkdir_p snapshot_dir unless Dir.exists?(snapshot_dir)

    if creating? && File.exists?(snapshot_filepath)
      FileUtils.rm snapshot_filepath
    end

    if benchmarking?
      benchmark_filepath = "#{snapshot_filepath}.benchmark"
      if creating? && File.exists?(benchmark_filepath)
        FileUtils.rm benchmark_filepath
      end

      benchmark_output = File.open(benchmark_filepath, "ab")
      benchmark_output.sync = true
    end

    # Write to a temporary file and then if we complete without error
    # we will create/append to the real output file. This is to avoid getting
    # partial writes when snapshotting if an error were to occur.
    in_progress_tempfile = Tempfile.new(snapshot_filename)
    in_progress_tempfile.binmode

    @api_crawler = api_crawler_factory.new(
      benchmark_output: benchmark_output,
      output: in_progress_tempfile,
      num_pages: num_pages,
      start_page: start_page,
      stop_page: stop_page,
      url: url
    )

    @api_crawler.crawl

    self.update_attribute :pageno, @api_crawler.pageno

    File.open(snapshot_filepath, "ab") do |output|
      output.puts File.read(in_progress_tempfile.path)
    end

    ReportWriteLog.create! filepath: snapshot_filepath, report_type: "ApiSnapshot"

    if finished?
      touch(:finished_exporting_at)
    end
  rescue Exception => ex
    touch(:failed_at)
    raise ex
  ensure
    if in_progress_tempfile
      in_progress_tempfile.close unless in_progress_tempfile.closed?
      in_progress_tempfile.unlink
    end

    if benchmark_output
      benchmark_output.closed? unless benchmark_output.closed?
    end
  end
  alias :snapshot! :export!

  private

  def benchmarking?
    !!benchmark
  end

  def creating?
    mode == CREATE_MODE
  end

  def uri
    @uri ||= URI.parse(url)
  end

end
