require 'rails_helper'

describe Subscribers, vcr: false, focus: true do
  describe 'notify' do
    context 'an article citation count update includes a subscriber milestone' do
      before do
        @subscriber_url = 'https://example.com/notify-me-of-plosone-crossref-citation-acheivements'
        @citation_source = 'crossref'
        @journal = 'pone'
        subs = [
          {
            journal: @journal,
            source: @citation_source,
            milestones: [1,15],
            url: @subscriber_url,
          }
        ]
        @article_doi = '10.1371/journal.pone.0053745'
        expect(Subscribers).to receive(:get).with(@journal, @citation_source).and_return(subs).at_least(:once)
      end

      it 'notifies subscribers' do
        expect(Faraday).to receive(:get).with(@subscriber_url, {doi: @article_doi, milestone: 1})
        Subscribers.notify(@article_doi, @citation_source, 0, 14)
      end

      context 'multiple milestones were passed' do
        it 'uses the last milestone that was passed' do
          expect(Faraday).to receive(:get).with(@subscriber_url, {doi: @article_doi, milestone: 15})
          Subscribers.notify(@article_doi, @citation_source, 0, 16)
        end
      end

      context 'milestone is exactly the new count' do
        it 'notifies' do
          expect(Faraday).to receive(:get).with(@subscriber_url, {doi: @article_doi, milestone: 1}).exactly(:once)
          Subscribers.notify(@article_doi, @citation_source, 0, 1)
        end
      end

      context 'milestone is exactly the old count' do
        it 'does not notify since it would have been already notified in the previous update' do
          expect(Faraday).not_to receive(:get)
          Subscribers.notify(@article_doi, @citation_source, 1, 4)
        end
      end
    end

    context 'An article citation count update does not include a subscriber milestone' do
      it 'does not notify any subscriber' do
        subs = [
          {
            journal: @journal,
            source: @citation_source,
            milestones: [40, 50],
            url: 'https://example.com/milestones-out-of-range',
          }
        ]
        expect(Subscribers).to receive(:all_subscribers).and_return(subs)

        expect(Faraday).not_to receive(:get)
        Subscribers.notify(@article_doi, @citation_source, 0, 31)
      end
    end
  end

  describe 'get' do
    it 'gets subscribers to notify of a milestone passed by an article' do
      subs = [
        {
          journal: 'pmed',
          source: 'crossref',
          milestones: [1, 15],
          url: 'https://example.com/notify-me-about-xref-changes-for-journal-pmed',
        },
        {
          journal: 'pone',
          source: 'crossref',
          milestones: [1, 15],
          url: 'https://example.com/notify-me-about-xref-changes-for-journal-pone',
        },
        {
          journal: 'pone',
          source: 'scopus',
          milestones: [1, 15],
          url: 'https://example.com/notify-me-about-scopus-changes-for-journal-pone',
        }
      ]
      expect(Subscribers).to receive(:all_subscribers).and_return(subs).exactly(4).times

      expect(Subscribers.get('pone', 'crossref').map{|s| s[:url]}).to eq(['https://example.com/notify-me-about-xref-changes-for-journal-pone'])
      expect(Subscribers.get('pmed', 'crossref').map{|s| s[:url]}).to eq(['https://example.com/notify-me-about-xref-changes-for-journal-pmed'])
      expect(Subscribers.get('pbio', 'crossref')).to eq([])
      expect(Subscribers.get('pone', 'scopus').map{|s| s[:url]}).to eq(['https://example.com/notify-me-about-scopus-changes-for-journal-pone'])
    end
  end
end
