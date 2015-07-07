require "rails_helper"

describe ZenodoDataExport do
    subject(:data_export){ ZenodoDataExport.new }

  describe "#export!" do
    subject(:data_export){ ZenodoDataExport.create!(
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

      # allow(zenodo_deposit)
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

      it "updates its data to a Hash serialized version of the Zenodo deposition" do
        allow(zenodo_deposition).to receive(:to_h).and_return(serialized_hash: "here")
        expect {
          data_export.export!(zenodo_client_factory: zenodo_client_factory)
        }.to change(data_export, :data).to(serialized_hash: "here")
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

        expect {
          data_export.export!(zenodo_client_factory: zenodo_client_factory)
        }.to raise_error
      end

      it "doesn't update its started_exporting_at timestamp" do
        expect(data_export.started_exporting_at).to be(nil)
      end

      it "doesn't update its finished_exporting_at timestamp" do
        expect(data_export.finished_exporting_at).to be(nil)
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

  end

  describe "#to_zenodo_deposition_attributes" do
    it "returns the Zenodo deposition attributes representation of this export" do
      expect(data_export.to_zenodo_deposition_attributes).to eq({
        'metadata' => {
          'title' => '(TEST) Monthly Stats Report',
          'upload_type' => 'dataset',
          'description' => '(TEST) Monthly Stats Report',
          'creators' =>[{'name' => 'Zach Dennis'}]
        }
      })
    end
  end
end
