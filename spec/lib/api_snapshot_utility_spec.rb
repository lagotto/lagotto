require "rails_helper"

describe ApiSnapshotUtility do
  def with_env(env)
    before = env.inject({}) { |h, (k, _)| h[k] = ENV[k]; h }
    env.each { |k, v| ENV[k] = v }
    yield
  ensure
    before.each { |k, v| ENV[k] = v }
  end

  describe ".snapshot_later" do
    include ActiveJob::TestHelper

    def snapshot_later(*args)
      ApiSnapshotUtility.snapshot_later *args
    end

    it "creates an ApiSnapshot for a single given endpoint" do
      expect {
        snapshot_later "/api/foo"
      }.to change(ApiSnapshot, :count).by(1)
    end

    it "can create an ApiSnapshot for a multiple given endpoints" do
      expect {
        snapshot_later ["/api/foo", "/api/bar"]
      }.to change(ApiSnapshot, :count).by(2)
    end

    it "enqueues an ApiSnapshotJob for later processing of the created ApiSnapshot" do
      expect{
        snapshot_later "/api/bar"
      }.to change(enqueued_jobs, :size).by(1)
    end

    context "the constructed snapshot" do
      subject(:api_snapshot){ snapshot_later "/api/foo", options ; ApiSnapshot.last }
      let(:options){ {} }

      describe "#benchmark" do
        it "isn't benchmarking by default" do
          expect(api_snapshot.benchmark).to eq(false)
        end

        it "is benchmarking when :benchmark is passed in as an option" do
          options[:benchmark] = true
          expect(api_snapshot.benchmark).to eq(true)
        end

        it "is benchmarking when the BENCHMARK env variable is set" do
          with_env("BENCHMARK" => "1") do
            expect(api_snapshot.benchmark).to eq(true)
          end
        end
      end

      describe "#filename_ext" do
        it "sets the filename extension to the default ApiSnapshot::FILENAME_EXT" do
          expect(api_snapshot.filename_ext).to eq(ApiSnapshot::FILENAME_EXT)
        end

        it "uses the :filename_ext when passed in as an option" do
          options[:filename_ext] = "foobar"
          expect(File.extname(api_snapshot.snapshot_filename)).to eq(".foobar")
        end

        it "uses FILENAME_EXT env when it is set" do
          with_env("FILENAME_EXT" => "jazz") do
            expect(File.extname(api_snapshot.snapshot_filename)).to eq(".jazz")
          end
        end
      end

      describe "#num_pages" do
        it "sets the number of pages to process to 10 by default" do
          expect(api_snapshot.num_pages).to eq(10)
        end

        it "sets the number of pages to the given :pages_per_job option" do
          options[:pages_per_job] = 100
          expect(api_snapshot.num_pages).to eq(100)
        end

        it "uses PAGES_PER_JOB env when it is set" do
          with_env("PAGES_PER_JOB" => "99") do
            expect(api_snapshot.num_pages).to eq(99)
          end
        end
      end

      describe "#snapshot_dir" do
        it "sets the snapshot_dir to ApiSnapshot.default_snapshot_dir by default" do
          expect(api_snapshot.snapshot_dir).to eq(ApiSnapshot.default_snapshot_dir.to_s)
        end

        it "uses the :snapshot_dir option when provided" do
          options[:snapshot_dir] = "/tmp/foo"
          expect(api_snapshot.snapshot_dir).to eq("/tmp/foo")
        end

        it "uses SNAPSHOT_DIR env when it is set" do
          with_env("SNAPSHOT_DIR" => "/tmp/bar") do
            expect(api_snapshot.snapshot_dir).to eq("/tmp/bar")
          end
        end
      end

      describe "#start_page" do
        it "sets the start_page to nil by default" do
          expect(api_snapshot.start_page).to be(nil)
        end

        it "uses the :start_page option when provided" do
          options[:start_page] = 1
          expect(api_snapshot.start_page).to eq(1)
        end

        it "uses START_PAGE env when it is set" do
          with_env("START_PAGE" => "66") do
            expect(api_snapshot.start_page).to eq(66)
          end
        end
      end

      describe "#stop_page" do
        it "sets the stop_page to nil by default" do
          expect(api_snapshot.stop_page).to be(nil)
        end

        it "uses the :stop_page option when provided" do
          options[:stop_page] = 33
          expect(api_snapshot.stop_page).to eq(33)
        end

        it "uses STOP_PAGE env when it is set" do
          with_env("STOP_PAGE" => "75") do
            expect(api_snapshot.stop_page).to eq(75)
          end
        end
      end

      describe "#mode" do
        it "sets the mode to ApiSnapshot::CREATE_MODE by default" do
          expect(api_snapshot.mode).to eq(ApiSnapshot::CREATE_MODE)
        end

        it "uses the :mode option when provided" do
          options[:mode] = ApiSnapshot::APPEND_MODE
          expect(api_snapshot.mode).to eq(ApiSnapshot::APPEND_MODE)
        end
      end

      describe "#url" do
        it "sets the url to the given endpoint" do
          expect(api_snapshot.url).to_not be(nil)
        end

        it "prefixes the HTTP protocol when NOT provided by the SERVERNAME env variable" do
          with_env("SERVERNAME" => "foobar.com") do
            expect(api_snapshot.url).to eq("http://#{ENV['SERVERNAME']}/api/foo")
          end
        end

        it "doesn't prefix when the HTTP protocol is provided by the SERVERNAME env variable" do
          with_env("SERVERNAME" => "http://foobar.com") do
            expect(api_snapshot.url).to eq("http://foobar.com/api/foo")
          end
        end

        it "doesn't prefix when the HTTPS protocol is provided by the SERVERNAME env variable" do
          with_env("SERVERNAME" => "https://foobar.com") do
            expect(api_snapshot.url).to eq("https://foobar.com/api/foo")
          end
        end
      end

    end
  end

  describe ".zip" do
    let!(:snapshot_dir){ Rails.root.join("tmp/sample_snapshots_dir") }
    let(:api_snapshot){ FactoryGirl.create(:api_snapshot) }
    let(:snapshot_contents){ "foo\nbar\nbaz" }

    before do
      @original_data_dir = ApiSnapshot.snapshot_dir
      ApiSnapshot.snapshot_dir = snapshot_dir

      dir = File.dirname(api_snapshot.snapshot_filepath)
      FileUtils.mkdir_p dir unless File.exists?(dir)

      File.write(api_snapshot.snapshot_filepath, snapshot_contents)
    end

    after do
      ApiSnapshot.snapshot_dir = @original_data_dir
      FileUtils.rm_rf snapshot_dir if File.exists?(snapshot_dir)
    end

    it "zips the given snapshot" do
      ApiSnapshotUtility.zip(api_snapshot)
      expect(File.exists?(api_snapshot.zip_filepath)).to be(true)
    end

    it "writes a record of the zip file to the ReportWriteLog" do
      expect {
        ApiSnapshotUtility.zip(api_snapshot)
      }.to change(ReportWriteLog, :count).by(1)
      expect(ReportWriteLog.last.filepath).to eq(api_snapshot.zip_filepath)
      expect(ReportWriteLog.last.report_type).to eq("ZipFile")
    end

    it "adds docs/readmes/api_snapshot.md to the zip file as the README file" do
      zip_filepath = ApiSnapshotUtility.zip(api_snapshot)
      zip_file = Zip::File.open(zip_filepath)
      expect(zip_file.get_entry("README.md")).to_not be(nil)
    end

    it "adds the API snapshot file to the zip file" do
      zip_filepath = ApiSnapshotUtility.zip(api_snapshot)
      zip_file = Zip::File.open(zip_filepath)
      expect(zip_file.get_entry(api_snapshot.snapshot_filename)).to_not be(nil)
    end

  end

  describe ".export_to_zenodo" do
    include ActiveJob::TestHelper

    let(:api_snapshot){ FactoryGirl.create(:api_snapshot) }

    def perform_export
      ApiSnapshotUtility.export_to_zenodo(api_snapshot)
    end

    it "constructs a ZenodoDataExport; enqueues a DataExportJob to process it" do
      expect {
        perform_export
      }.to change(ZenodoDataExport, :count).by(1)
    end

    describe "the ZenodoDataExport" do
      subject(:data_export){ perform_export ; ZenodoDataExport.last }

      it "sets the name" do
        expect(data_export.name).to eq("api_snapshot")
      end

      it "sets the files" do
        expect(data_export.files).to eq([api_snapshot.zip_filepath])
      end

      it "sets the publication_date to the ApiSnapshot's snapshot_date" do
        expect(data_export.publication_date).to eq(api_snapshot.created_at.to_date)
      end

      it "sets the title" do
        expect(data_export.title).to eq("API Snapshot of #{api_snapshot.url} on #{api_snapshot.snapshot_date}")
      end

      it "sets the description" do
        with_env "SITENAMELONG" => "Public Library of Science" do
          expect(data_export.description).to eq <<-EOS.gsub(/^\s*/, '').gsub(/\s*\n\s*/, " ")
            Article-Level Metrics (ALM) measure the reach and online engagement of scholarly works.
            This #{ENV['SITENAMELONG']} API snapshot contains the entirety of the #{api_snapshot.url}
            end_point at the time it was generated on #{api_snapshot.created_at.to_date}.
            Data are generated by the Lagotto open source software.
            Go to the Lagotto forum for questions or comments.
          EOS
        end
      end

      it "sets the creator to the CREATOR env variable" do
        with_env "CREATOR" => "PLOS" do
          expect(data_export.creators).to eq(["PLOS"])
        end
      end

      it "sets the keywords" do
        expect(data_export.keywords).to eq(ZENODO_KEYWORDS)
      end

      it "sets the code_repostory_url to the GITHUB_URL env variable" do
        with_env "GITHUB_URL" => "http://example.com/lagotto" do
          expect(data_export.code_repository_url).to eq("http://example.com/lagotto")
        end
      end
    end

    it "enqueues a DataExportJob to later process the ZenodoDataExport in the background" do
      expect {
        ApiSnapshotUtility.export_to_zenodo(api_snapshot)
      }.to change(enqueued_jobs, :size).by(1)
    end
  end

end
