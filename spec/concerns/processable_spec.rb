require "rails_helper"

describe Deposit, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:deposit) }

  describe "process_data" do
    it "datacite_orcid" do
      FactoryGirl.create(:source, :datacite_orcid)
      subject = FactoryGirl.create(:deposit_for_datacite_orcid)
      subject.process_data
      expect(subject.human_state_name).to eq("done")
      expect(subject.error_messages).to be_nil
    end

    # it "contributor" do
    #   subject = FactoryGirl.create(:deposit_for_contributor)
    #   subject.process_data
    #   expect(subject.human_state_name).to eq("done")
    #   expect(subject.error_messages).to be_nil
    # end

    # it "contributor failed" do
    #   source = FactoryGirl.create(:source, :datacite_orcid)
    #   subject = FactoryGirl.create(:deposit_for_contributor, :invalid_orcid)
    #   subject.process_data
    #   expect(subject.human_state_name).to eq("failed")
    #   expect(subject.error_messages).to eq("contributor"=>"Validation failed: Orcid can't be blank, Orcid is invalid")
    # end

    # it "publisher" do
    #   subject = FactoryGirl.create(:deposit_for_publisher)
    #   subject.process_data
    #   expect(subject.human_state_name).to eq("done")
    #   expect(subject.error_messages).to be_nil
    # end

    # it "publisher failed" do
    #   source = FactoryGirl.create(:source, :datacite_datacentre)
    #   subject = FactoryGirl.create(:deposit_for_publisher, :no_publisher_title)
    #   subject.process_data
    #   expect(subject.human_state_name).to eq("failed")
    #   expect(subject.error_messages).to eq("publisher"=>"Validation failed: Title can't be blank")
    # end
  end
end
