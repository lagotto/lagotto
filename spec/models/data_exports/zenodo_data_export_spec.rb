require "rails_helper"

describe ZenodoDataExport do
  subject(:data_export){ FactoryGirl.build(:zenodo_data_export) }

  describe "validations" do
    it "is valid" do
      expect(data_export.valid?).to be(true)
    end

    it "requires :name" do
      data_export.name = nil
      expect(data_export.valid?).to be(false)
    end

    it "requires :files" do
      data_export.files = []
      expect(data_export.valid?).to be(false)
    end

    it "requires :publication_date" do
      data_export.publication_date = nil
      expect(data_export.valid?).to be(false)
    end

    it "requires :title" do
      data_export.title = nil
      expect(data_export.valid?).to be(false)
    end

    it "requires :description" do
      data_export.description = nil
      expect(data_export.valid?).to be(false)
    end

    it "requires :creators" do
      data_export.creators = nil
      expect(data_export.valid?).to be(false)
    end

    it "requires :keywords" do
      data_export.keywords = nil
      expect(data_export.valid?).to be(false)
    end

    it "requires :code_repository_url" do
      data_export.code_repository_url = nil
      expect(data_export.valid?).to be(false)
    end
  end

  describe "#export!" do
    subject(:data_export){ FactoryGirl.create(:zenodo_data_export,
      publication_date: "2015-03-01".to_date,
      files: files
    )}

    let(:data_dir){ Rails.root.join("sample_data") }
    let(:files){ [file_1, file_2] }
    let(:file_1){ data_dir.join("file1.txt").to_s }
    let(:file_2){ data_dir.join("file2.txt").to_s }

    let(:zenodo_client_factory){ double("Zenodo::Client factory double", build: zenodo_client) }
    let(:zenodo_client){ double("Zenodo::Client double",
      create_deposition: zenodo_deposition,
      create_deposition_file: nil,
      publish_deposition: nil,
      get_deposition: zenodo_deposition
    )}
    let(:zenodo_deposition){ double("Zenodo::Deposition double",
      :[] => nil,
      :to_h => {}
    )}

    before do
      FileUtils.mkdir(data_dir)
      File.write(file_1, "sample contents")
      File.write(file_2, "sample contents")
    end

    after do
      FileUtils.rm_rf(data_dir) if File.exists?(data_dir)
    end

    it "exports the files to Zenodo" do
      expect {
        data_export.export!(zenodo_client_factory: zenodo_client_factory)
      }.to_not raise_error
    end

    context "exporting to Zenodo" do
      before do
        allow(zenodo_deposition).to receive(:[]).with('id').and_return 999
      end

      it "creates a Zenodo deposition for the export" do
        expect(zenodo_client).to receive(:create_deposition).with(
          deposition: data_export.to_zenodo_deposition_attributes
        )
        data_export.export!(zenodo_client_factory: zenodo_client_factory)
      end

      it "creates a Zenodo deposition file for each file on the export" do

        expect(zenodo_client).to receive(:create_deposition_file).with(
          id: 999,
          file_or_io: file_1)
        expect(zenodo_client).to receive(:create_deposition_file).with(
          id: 999,
          file_or_io: file_2)

        data_export.export!(zenodo_client_factory: zenodo_client_factory)
      end

      it "publishes the deposition, then retrieves the latest deposition" do
        expect(zenodo_client).to receive(:publish_deposition).with(id: 999).ordered
        expect(zenodo_client).to receive(:get_deposition).with(id: 999).ordered
        data_export.export!(zenodo_client_factory: zenodo_client_factory)
      end

      it "updates its URL with the Zenodo deposition URL" do
        allow(zenodo_deposition).to receive(:[]).with("record_url").and_return "www.example.com/123"
        expect {
          data_export.export!(zenodo_client_factory: zenodo_client_factory)
        }.to change(data_export, :url).to "www.example.com/123"
      end

      it "sets its remote_deposition to a Hash serialized version of the remote Zenodo deposition" do
        allow(zenodo_deposition).to receive(:to_h).and_return(serialized_hash: "here")
        expect {
          data_export.export!(zenodo_client_factory: zenodo_client_factory)
        }.to change{ data_export.remote_deposition }.to eq(serialized_hash: "here")
      end
    end

    it "updates its started_exporting_at timestamp" do
      expect {
        data_export.export!(zenodo_client_factory: zenodo_client_factory)
      }.to change(data_export, :started_exporting_at).from(nil)
    end

    it "updates its finished_exporting_at timestamp" do
      expect {
        data_export.export!(zenodo_client_factory: zenodo_client_factory)
      }.to change(data_export, :finished_exporting_at).from(nil)
    end

    context "and an error is raised during the export" do
      before do
        allow(zenodo_client).to receive(:create_deposition).and_raise("BOOM")
      end

      def perform_export
        expect {
          data_export.export!(zenodo_client_factory: zenodo_client_factory)
        }.to raise_error
      end

      it "doesn't update its started_exporting_at timestamp" do
        perform_export
        expect(data_export.started_exporting_at).to be(nil)
      end

      it "doesn't update its finished_exporting_at timestamp" do
        perform_export
        expect(data_export.finished_exporting_at).to be(nil)
      end

      it "sets the failed_at datetime" do
        expect {
          perform_export
        }.to change(data_export, :failed_at).to be_within(5.seconds).of(Time.zone.now)

      end
    end

    context "and a file does not exist locally" do
      before { FileUtils.rm file_1 }

      it "raises a FileNotFoundError" do
        expect {
          data_export.export!(zenodo_client_factory: zenodo_client_factory)
        }.to raise_error(ZenodoDataExport::FileNotFoundError)
      end

      it "doesn't try to upload to Zenodo" do
        expect(zenodo_client).to_not receive(:create_deposition)

        begin
          data_export.export!(zenodo_client_factory: zenodo_client_factory)
        rescue
        end
      end
    end

    context "and the export is already finished" do
      before { data_export.update_attribute :finished_exporting_at, 1.day.ago }

      it "does not try to upload to Zenodo again" do
        expect(zenodo_client_factory).to_not receive(:build)
        data_export.export!(zenodo_client_factory: zenodo_client_factory)
      end
    end
  end

  describe "#to_zenodo_deposition_attributes" do
    let(:metadata){ data_export.to_zenodo_deposition_attributes["metadata"] }

    it "returns the Zenodo deposition attributes representation of this export as Hash" do
      expect(data_export.to_zenodo_deposition_attributes).to be_kind_of(Hash)
    end

    it "has a title" do
      data_export.title = "My title"
      expect(metadata).to include("title" => "My title")
    end

    it "has a description" do
      data_export.description = "My description"
      expect(metadata).to include("description" => "My description")
    end

    it "has a publication_date" do
      data_export.publication_date = "2015-07-01".to_date
      expect(metadata).to include("publication_date" => "2015-07-01")
    end

    it "has creators" do
      data_export.creators = ["John Smith", "Margaret Swift"]
      expect(metadata).to include("creators" => [{"name" => "John Smith"}, {"name" => "Margaret Swift"}])
    end

    it "has keywords" do
      data_export.keywords = ["Palladium", "Silver"]
      expect(metadata).to include("keywords" => ["Palladium", "Silver"])
    end

    it "has an access_right" do
      expect(metadata).to include("access_right" => "open")
    end

    it "has a license" do
      expect(metadata).to include("license" => "cc-zero")
    end

    it "has an attribution to the code repository" do
      data_export.code_repository_url = "http://somecoderepository"
      expect(metadata["related_identifiers"]).to include(
        { "relation" => "isSupplementTo", "identifier" => "http://somecoderepository" }
      )
    end

    it "has an attribute to a related publication" do
      expect(metadata["related_identifiers"]).to include(
        { "relation" => "isSupplementTo", "identifier" => "10.3789/isqv25no2.2013.04" }
      )
    end

    context "and there was a previous export with the same name" do
      subject(:data_export){ FactoryGirl.build(:zenodo_data_export, name: previous_export.name) }

      let!(:previous_export){ FactoryGirl.create(:zenodo_data_export,
        name: "LagottoMonthlyReport",
        publication_date: 1.week.ago.to_date,
        created_at: 1.week.ago,
        remote_deposition: { "doi" => "10.5072/zenodo.188" }
      )}

      let(:attrs){ data_export.to_zenodo_deposition_attributes }

      context "and the previous export finished" do
        before { previous_export.update_attribute :finished_exporting_at, 1.week.ago }

        it "includes sets the related_identifiers for the Zenodo deposition" do
          expect(attrs["metadata"]["related_identifiers"]).to include(
            "relation" => "isNewVersionOf", "identifier" => previous_export.remote_deposition["doi"]
          )
        end
      end

      context "and the previous export did not finish" do
        before { previous_export.update_attribute :finished_exporting_at, nil }

        it "doesn't include related_identifier for a previous version information" do
          expect(attrs["metadata"]).to_not have_key("relation")
        end
      end
    end
  end
end
