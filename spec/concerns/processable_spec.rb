require "rails_helper"

describe Deposit, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:deposit) }

  let!(:registration_agency) { FactoryGirl.create(:registration_agency) }
  let!(:registration_agency_datacite) { FactoryGirl.create(:registration_agency, name: "datacite", title: "DataCite") }

  describe "process_data" do
    it "datacite_orcid" do
      FactoryGirl.create(:source, :datacite_orcid)
      subject = FactoryGirl.create(:deposit_for_datacite_orcid)
      subject.process_data
      expect(subject.human_state_name).to eq("done")
      expect(subject.error_messages).to be_nil
    end

    it "contributor" do
      subject = FactoryGirl.create(:deposit_for_contributor)
      subject.process_data
      expect(subject.human_state_name).to eq("done")
      expect(subject.error_messages).to be_nil
    end

    it "contributor failed" do
      source = FactoryGirl.create(:source, :datacite_orcid)
      subject = FactoryGirl.create(:deposit_for_contributor, :invalid_orcid)
      subject.process_data
      expect(subject.human_state_name).to eq("failed")
      expect(subject.error_messages).to eq("contributor"=>"Validation failed: Orcid can't be blank, Orcid is invalid")

      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.message).to eq("Validation failed: Orcid can't be blank, Orcid is invalid for contributor 555-1212")
      expect(notification.source_id).to eq(source.id)
    end

    it "publisher" do
      subject = FactoryGirl.create(:deposit_for_publisher)
      subject.process_data
      expect(subject.human_state_name).to eq("done")
      expect(subject.error_messages).to be_nil
    end

    it "publisher failed" do
      source = FactoryGirl.create(:source, :datacite_datacentre)
      subject = FactoryGirl.create(:deposit_for_publisher, :no_publisher_title)
      subject.process_data
      expect(subject.human_state_name).to eq("failed")
      expect(subject.error_messages).to eq("publisher"=>"Validation failed: Title can't be blank")

      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.message).to eq("Validation failed: Title can't be blank for publisher ANDS.CENTRE-1")
      expect(notification.source_id).to eq(source.id)
    end
  end
end
