require "rails_helper"

describe ZipUtility do
  let(:zip_filepath){ Rails.root.join("tmp/sample.zip").to_s }
  let(:sample_filepath){ Rails.root.join("tmp/sample.txt").to_s }

  before do
    File.write(sample_filepath, "sample contents")
  end

  after do
    FileUtils.rm(sample_filepath) if File.exists?(sample_filepath)
    FileUtils.rm(zip_filepath) if File.exists?(zip_filepath)
  end

  describe '.zip! - creating a zip archive with a block' do
    before do
      expect(File.exists?(zip_filepath)).to be(false)

      ZipUtility.zip! zip_filepath do |zip_utility|
        zip_utility.add "foo.txt", sample_filepath
      end
    end

    it "can be used to create a zip archive with a block" do
      expect(File.exists?(zip_filepath)).to be(true)
    end
  end

  describe 'creating a zip archive with #add and #zip!' do
    subject(:zip_utility){ ZipUtility.new(options) }
    let(:options){ { filepath:zip_filepath } }

    before do
      expect(File.exists?(zip_filepath)).to be(false)

      zip_utility.add "foo.txt", sample_filepath
      zip_utility.zip!
    end

    it "creates a zip archive" do
      expect(File.exists?(zip_filepath)).to be(true)
    end

    it "defaults the zip file's permissions to 0755" do
      actual_permissions = "%#o" % (File.stat(zip_filepath).mode & 0755)
      expect(actual_permissions).to eq("0755")
    end

    context "and :permissions options is being used" do
      let(:options){ { filepath:zip_filepath, permissions: 0740 } }

      it "sets the zip file's permission to those passed in" do
        actual_permissions = "%#o" % (File.stat(zip_filepath).mode & 0740)
        expect(actual_permissions).to eq("0740")
      end
    end
  end

end
