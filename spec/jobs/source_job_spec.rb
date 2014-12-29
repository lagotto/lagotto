require 'rails_helper'

RSpec.describe SourceJob, :type => :job do
  let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }
  let(:source) { FactoryGirl.create(:source) }
  let(:rs_id) { "#{retrieval_status.source.name}:#{retrieval_status.article.doi_escaped}" }

  subject { SourceJob.new([retrieval_status.id], source.id) }

  before(:each) { subject.put_lagotto_database }
  after(:each) { subject.delete_lagotto_database }

  context "error" do
    it "should create an alert on error" do
      exception = StandardError.new
      puts subject.inspect
      subject.error(job, exception)

      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("StandardError")
      expect(alert.source_id).to eq(source.id)
    end

    it "should not create an alert if source is not in working state" do
      exception = SourceInactiveError.new
      subject.error(job, exception)

      expect(Alert.count).to eq(0)
    end

    it "should not create an alert if not enough workers available for source" do
      exception = NotEnoughWorkersError.new
      subject.error(job, exception)

      expect(Alert.count).to eq(0)
    end
  end
end
