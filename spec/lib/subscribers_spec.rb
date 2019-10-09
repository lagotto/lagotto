require 'rails_helper'

describe Subscribers, vcr: false, focus: true do
  describe 'notify' do
    context 'a subscriber milestone has been passed' do
      before do
        subs = [
          {
            journal: 'pone',
            source: 'crossref',
            milestones: [1,15],
            url: 'https://example.com',
          }
        ]
        expect(Subscribers).to receive(:get).with('10.1371/journal.pone.0053745', 'crossref').and_return(subs).at_least(:once)
      end

      it 'notifies subscribers' do
        expect(Faraday).to receive(:get).with('https://example.com', {doi: '10.1371/journal.pone.0053745', milestone: 1})
        Subscribers.notify('10.1371/journal.pone.0053745', 'crossref', 0, 14)
      end

      it 'uses the last milestone that was passed' do
        expect(Faraday).to receive(:get).with('https://example.com', {doi: '10.1371/journal.pone.0053745', milestone: 15})
        Subscribers.notify('10.1371/journal.pone.0053745', 'crossref', 0, 16)
      end

      it 'notifies once per milestone that was passed' do
        expect(Faraday).to receive(:get).with('https://example.com', {doi: '10.1371/journal.pone.0053745', milestone: 1}).exactly(:once)
        expect(Faraday).to receive(:get).with('https://example.com', {doi: '10.1371/journal.pone.0053745', milestone: 15}).exactly(:once)
        Subscribers.notify('10.1371/journal.pone.0053745', 'crossref', 0, 15)
        Subscribers.notify('10.1371/journal.pone.0053745', 'crossref', 15, 20)
      end
    end

    context 'a subscriber milestone has NOT been passed' do
      it 'does not notify subscribers' do
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
        expect(Subscribers).to receive(:get_from_config).and_return(subs)

        expect(Faraday).not_to receive(:get)
        Subscribers.notify('10.1371/journal.pone.0053745', 'crossref', 0, 31)
      end
    end
  end

  describe 'get' do
    it 'matches on journal and source' do
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
      expect(Subscribers).to receive(:get_from_config).and_return(subs).exactly(4).times
      expect(Subscribers.get('10.1371/journal.pone.7', 'crossref').map{|s| s[:url]}).to eq(['https://example.com/pone-xref'])
      expect(Subscribers.get('10.1371/journal.pone.7', 'mendeley').map{|s| s[:url]}).to eq(['https://example.com/pone-mend'])
      expect(Subscribers.get('10.1371/journal.pmed.7', 'crossref').map{|s| s[:url]}).to eq(['https://example.com/pmed-xref'])
      expect(Subscribers.get('10.1371/journal.pbio.7', 'crossref')).to eq([])
    end
  end
end
