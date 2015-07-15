require "rails_helper"

describe FileWriteLog do

  describe ".most_recent_with_name" do
    let!(:record_foo_1){ FileWriteLog.create!(filepath:"/path/foo.txt", created_at: 5.minutes.ago) }
    let!(:record_foo_2){ FileWriteLog.create!(filepath:"/path/foo.txt", created_at: 1.minute.ago) }
    let!(:record_bar_3){ FileWriteLog.create!(filepath:"/path/bar.txt", created_at: 1.minute.ago) }

    it "returns the most recent record whose filename matches the given name" do
      record = FileWriteLog.most_recent_with_name("foo.txt")
      expect(record).to eq(record_foo_2)
    end

    it "only matches on exact filename matches, not partial" do
      record = FileWriteLog.most_recent_with_name("foo")
      expect(record).to be(nil)
    end
  end

  describe "validations" do
    subject(:file_type){ FileWriteLog.new(filepath:"/path/foo") }

    it "is valid" do
      expect(file_type.valid?).to be(true)
    end

    it "requires :filepath" do
      file_type.filepath = nil
      expect(file_type.valid?).to be(false)
    end
  end

end
