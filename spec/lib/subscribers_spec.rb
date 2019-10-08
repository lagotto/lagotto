require 'rails_helper'

describe Subscribers do
  describe "notify_subscribers" do
    context "a subscriber milestone has been passed" do
      before do
        @subs = [
          {
            journal: 'pone',
            source: 'crossref',
            milestones: [1,15],
            url: 'https://example.com',
          }
        ]
        expect(Subscribers).to receive(:get_subscribers).with('pone', 'crossref').and_return(subs)
      end

      it "notifies subscribers" do
        expect(Subscribers).to receive(:notify_subscriber).with('https://example.com', "10.1371/journal.pone.0053745", 15)
        Subscribers.notify_subscribers("10.1371/journal.pone.0053745", 'pone', 'crossref', 20, 31)
      end

      it "uses the first milestone that was passed" do
        expect(Subscribers).to receive(:notify_subscriber).with('https://example.com', "10.1371/journal.pone.0053745", 1)
        Subscribers.notify_subscribers("10.1371/journal.pone.0053745", 'pone', 'crossref', 0, 17)
      end
    end

    context "a subscriber milestone has NOT been passed" do
      it "does not notify subscribers" do
        subs = [
          {
            journal: 'pone',
            source: 'crossref',
            milestones: [40, 50],
            url: 'https://example-milestone-mismatch.com',
          },
          {
            journal: 'pmed',
            source: 'crossref',
            milestones: [1, 15],
            url: 'https://example-journal-mismatch.com',
          },
          {
            journal: 'pone',
            source: 'mendeley',
            milestones: [1, 15],
            url: 'https://example-source-mismatch.com',
          }
        ]
        expect(Subscribers).not_to receive(:notify_subscriber)
        expect(Subscribers).to receive(:get_subscribers).with('pone', 'crossref').and_return(subs)
        Subscribers.notify_subscribers("10.1371/journal.pone.0053745", 'pone', 'crossref', 0, 31)
      end
    end
  end

  describe "notify_subscriber" do
    it 'sends a request with relevant query params' do
      expect(Faraday).to receive(:get).with('https://example.com/subscriber', {doi: '10.1371/pone.1234567', milestone: 42})
      Subscribers.notify_subscriber('https://example.com/subscriber', '10.1371/pone.1234567', 42)
    end
  end

  describe "get_subscribers" do
    it "matches on journal and source" do
      subs = [
        {
          journal: 'pmed',
          source: 'crossref',
          milestones: [1, 15],
          url: 'https://example.com/pmed-xref',
        },
        {
          journal: 'pone',
          source: 'crossref',
          milestones: [1, 15],
          url: 'https://example.com/pone-xref',
        },
        {
          journal: 'pone',
          source: 'mendeley',
          milestones: [1, 15],
          url: 'https://example.com/pone-mend',
        }
      ]
      ::SUBSCRIBERS_CONFIG = {subscribers: subs}
      expect(Subscribers.get_subscribers('pone', 'crossref').map{|s| s[:url]}).to eq(['https://example.com/pone-xref'])
      expect(Subscribers.get_subscribers('pone', 'mendeley').map{|s| s[:url]}).to eq(['https://example.com/pone-mend'])
      expect(Subscribers.get_subscribers('pmed', 'crossref').map{|s| s[:url]}).to eq(['https://example.com/pmed-xref'])
      expect(Subscribers.get_subscribers('pbio', 'crossref')).to eq([])
    end
  end
end