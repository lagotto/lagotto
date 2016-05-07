require "rails_helper"

describe Deposit, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:deposit) }

  let!(:registration_agency) { FactoryGirl.create(:registration_agency) }
  let!(:registration_agency_datacite) { FactoryGirl.create(:registration_agency, name: "datacite", title: "DataCite") }

  describe "update_publishers" do
    it "update" do
      subject = FactoryGirl.create(:deposit_for_publisher)
      expect(subject.update_publishers).to be true
      expect(subject.error_messages).to be_nil

      expect(Publisher.count).to eq(1)

      publisher = Publisher.first
      expect(publisher.name).to eq("ANDS.CENTRE-1")
      expect(publisher.title).to eq("Griffith University")
      expect(publisher.checked_at.utc.iso8601).to eq("2006-06-13T16:14:19Z")
    end

    it "update missing title" do
      subject = FactoryGirl.create(:deposit_for_publisher, :no_publisher_title)
      expect(subject.update_publishers).to be false
      expect(subject.error_messages).to eq("publisher"=>"Validation failed: Title can't be blank")

      expect(Publisher.count).to eq(0)
    end
  end
end
