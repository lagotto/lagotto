require "rails_helper"

describe ApiSnapshot do
  subject(:api_snapshot){ FactoryGirl.build(:api_snapshot, attrs) }
  let(:attrs){ {} }

  describe ".default_snapshot_dir" do
    let!(:original_snapshot_dir){ ApiSnapshot.snapshot_dir }

    after do
      ApiSnapshot.snapshot_dir = original_snapshot_dir
    end

    it "returns the default directory where snapshots should be stored based on today's date" do
      expected_path = Rails.root.join("tmp/snapshots/snapshot_#{Time.zone.now.to_date}")
      expect(ApiSnapshot.default_snapshot_dir).to eq(expected_path)
    end

    it "can be changed by setting ApiSnapshot.snapshot_dir" do
      expected_path = Rails.root.join("foobarbaz/snapshot_#{Time.zone.now.to_date}")
      expect {
        ApiSnapshot.snapshot_dir = Rails.root.join("foobarbaz")
      }.to change(ApiSnapshot, :default_snapshot_dir).to eq(expected_path)
    end

    it "affects the #snapshot_filepath" do
      attrs[:url] = "http://example.com/api/events"
      ApiSnapshot.snapshot_dir = Rails.root.join("foobarbaz")
      expected_path = Rails.root.join("foobarbaz/snapshot_#{Time.zone.now.to_date}").join("api_events_#{Time.zone.now.to_date}.jsondump")
      expect(api_snapshot.snapshot_filepath).to eq(expected_path.to_s)
    end
  end

  describe "validations" do
    it "is valid" do
      expect(api_snapshot.valid?).to be(true)
    end

    it "requires :name" do
      api_snapshot.name = nil
      expect(api_snapshot.valid?).to be(false)
    end

    it "requires :url" do
      api_snapshot.url = nil
      expect(api_snapshot.valid?).to be(false)
    end
  end

  describe "defaults" do
    it "isn't benchmarking" do
      expect(api_snapshot.benchmark).to be(false)
    end

    it "isn't finished" do
      expect(api_snapshot.finished?).to be(false)
    end

    it "has a snapshot_filepath based on the path portion of the given URL" do
      attrs[:url] = "http://example.com/api/works"
      expected_path = ApiSnapshot.default_snapshot_dir.join("api_works_#{Time.zone.now.to_date}.jsondump")
      expect(api_snapshot.snapshot_filepath).to eq(expected_path.to_s)
    end

    it "has a zip_filepath representing where its zip file should exist; be named" do
      attrs[:url] = "http://example.com/api/events/foo/bar"
      expected_path = ApiSnapshot.default_snapshot_dir.join("api_events_foo_bar_#{Time.zone.now.to_date}.zip")
      expect(api_snapshot.zip_filepath).to eq(expected_path.to_s)
    end

    it "is set to snapshot 10 pages at a time" do
      expect(api_snapshot.num_pages).to eq(10)
    end
  end

  describe "#export! / #snapshot!" do
    subject(:api_snapshot){ FactoryGirl.create(:api_snapshot, attrs) }
    let(:attrs){ {
      url: "http://example.com/foo/bars",
      num_pages: 2,
      start_page: 3,
      stop_page: 5
    } }
    let(:api_crawler_factory){ double("ApiCrawler class", new:api_crawler) }
    let(:api_crawler){ double("ApiCrawler", crawl:nil, pageno:nil, pages_left?:true) }

    let!(:original_snapshot_dir){ ApiSnapshot.snapshot_dir }

    before { ApiSnapshot.snapshot_dir = Rails.root.join("tmp/snapshots") }
    after { ApiSnapshot.snapshot_dir = original_snapshot_dir }

    def perform_snapshot
      api_snapshot.snapshot! api_crawler_factory:api_crawler_factory
    end

    it "updates the :started_exporting_at timestamp" do
      expect {
        perform_snapshot
      }.to change(api_snapshot, :started_exporting_at).to be_within(5.seconds).of(Time.zone.now)
    end

    it "creates an ApiCrawler to crawl the API" do
      expect(api_crawler_factory).to receive(:new) do |args|
        expect(args[:benchmark_output]).to be(nil)
        expect(args[:output]).to be_kind_of(Tempfile)
        expect(args[:num_pages]).to be(2)
        expect(args[:start_page]).to be(3)
        expect(args[:stop_page]).to be(5)
        expect(args[:url]).to eq("http://example.com/foo/bars")

        api_crawler
      end
      expect(api_crawler).to receive(:crawl)

      perform_snapshot
    end

    context "and benchmarking" do
      before do
        attrs[:benchmark] = true
      end

      it "passes in a :benchmark_output file to the ApiCrawler" do
        expect(api_crawler_factory).to receive(:new) do |args|
          expect(args[:benchmark_output]).to be_kind_of(File)

          expected_path = ApiSnapshot.default_snapshot_dir.join("foo_bars_#{Time.zone.now.to_date}.jsondump.benchmark").to_s
          expect(args[:benchmark_output].path).to eq(expected_path)

          api_crawler
        end

        perform_snapshot
      end
    end

    it "updates the #pageno to the last paged crawled by the API" do
      allow(api_crawler).to receive(:pageno).and_return 99
      expect{
        perform_snapshot
      }.to change(api_snapshot, :pageno).to eq(99)
    end

    it "constructs a ReportWritelog of the API snapshot" do
      expect{
        perform_snapshot
      }.to change(FileWriteLog, :count).by(1)
      expect(FileWriteLog.last.filepath).to eq(api_snapshot.snapshot_filepath)
      expect(FileWriteLog.last.file_type).to eq(ApiSnapshot.name)
    end

    context "and the over-arching API is not finshed being crawled" do
      it "doesn't update the finished_exporting_at datetime" do
        expect {
          perform_snapshot
        }.to_not change(api_snapshot, :finished_exporting_at)
      end
    end

    context "and the over-arching API is finshed being crawled" do
      it "updates the finished_exporting_at datetime" do
        allow(api_crawler).to receive(:pages_left?).and_return false
        expect {
          perform_snapshot
        }.to change(api_snapshot, :finished_exporting_at).to be_within(5.seconds).of(Time.zone.now)
      end
    end

    context "and an exception is raised during snapshotting" do
      before do
        allow(api_crawler).to receive(:crawl).and_raise "BOOM!"
      end

      def perform_snapshot
        expect {
          api_snapshot.export!(api_crawler_factory: api_crawler_factory)
        }.to raise_error("BOOM!")
      end

      it "updates the #failed_at datetime and re-raises the exception" do
        expect {
          perform_snapshot
        }.to change(api_snapshot, :failed_at).to be_within(5.seconds).of(Time.zone.now)
      end
    end
  end

end
