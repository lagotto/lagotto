require "rails_helper"

describe Event, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:event) }

  describe "process_data" do
    # it "datacite_orcid" do
    #   FactoryGirl.create(:source, :datacite_orcid)
    #   subject = FactoryGirl.create(:event_for_datacite_orcid)
    #   subject.process_data
    #   expect(subject.human_state_name).to eq("done")
    #   expect(subject.error_messages).to be_nil
    # end
  end

  describe "update_work" do
    it "should be created" do
      work = subject.update_work
      expect(subject.error_messages).to be_nil
      expect(work.pid).to eq("http://www.citeulike.org/user/dbogartoit")
      expect(work.pid).to eq(subject.work.pid)

      expect(Work.count).to eq(1)
      expect(Event.count).to eq(1)
    end
  end

  describe "update_related_work" do
    it "should be created" do
      related_work = subject.update_related_work
      expect(subject.error_messages).to be_nil
      expect(related_work.pid).to eq("https://doi.org/10.1371/journal.pmed.0030186")
      expect(related_work.pid).to eq(subject.related_work.pid)

      expect(Work.count).to eq(1)
      expect(Event.count).to eq(1)
    end
  end
end
