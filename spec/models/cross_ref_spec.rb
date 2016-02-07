require 'rails_helper'

describe CrossRef, type: :model, vcr: true do
  subject { FactoryGirl.create(:crossref) }

  let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0043007", canonical_url: "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007", :publisher_id => 340) }

  it "should report that there are no events if the doi is missing" do
    work = FactoryGirl.build(:work, :doi => nil)
    expect(subject.get_data(work_id: work.id)).to eq({})
  end

  context "publisher_configs" do
    it "all publisher_configs" do
      config = subject.publisher_configs.first[1]
      expect(config.username).to eq("username")
      expect(config.password).to eq("password")
    end

    it "for specific publisher" do
      config = subject.publisher_config(work.publisher_id)
      expect(config.username).to eq("username")
      expect(config.password).to eq("password")
    end
  end

  context "get_query_url" do
    it "with username and password" do
      expect(subject.get_query_url(work_id: work.id)).to eq("http://doi.crossref.org/servlet/getForwardLinks?usr=username&pwd=password&doi=10.1371%2Fjournal.pone.0043007")
    end

    it "without password" do
      crossref = FactoryGirl.create(:crossref_without_password)
      expect { crossref.get_query_url(work_id: work.id) }.to raise_error(ArgumentError, "CrossRef username or password is missing.")
    end

    it "without publisher" do
      work = FactoryGirl.create(:work, doi: "10.1007/s00248-010-9734-2", canonical_url: "http://link.springer.com/article/10.1007%2Fs00248-010-9734-2#page-1", publisher_id: nil)
      expect(subject.get_query_url(work_id: work.id)).to eq("http://www.crossref.org/openurl/?pid=openurl_username&id=doi:10.1007%2Fs00248-010-9734-2&noredirect=true")
    end
  end

  context "get_data from the CrossRef API" do
    it "should report if there are no events returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref_nil.xml')
      url = subject.get_query_url(work_id: work.id)
      stub = stub_request(:get, url).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref.xml')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the CrossRef API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://doi.crossref.org/servlet/getForwardLinks?usr=username&pwd=password&doi=#{work.doi_escaped}", status: 408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "use the CrossRef OpenURL API" do
    let(:work) { FactoryGirl.create(:work, doi: "10.1007/s00248-010-9734-2", canonical_url: "http://link.springer.com/work/10.1007%2Fs00248-010-9734-2#page-1", publisher_id: nil) }
    let(:url) { url = subject.get_query_url(work_id: work.id) }

    it "should use the OpenURL API" do
      expect(url).to eq("http://www.crossref.org/openurl/?pid=openurl_username&id=doi:#{work.doi_escaped}&noredirect=true")
    end

    it "should report if there is an event count of zero returned by the CrossRef OpenURL API" do
      body = File.read(fixture_path + 'cross_ref_openurl_nil.xml')

      stub = stub_request(:get, url).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there is an event count greater than zero returned by the CrossRef OpenURL API" do
      body = File.read(fixture_path + 'cross_ref_openurl.xml')
      stub = stub_request(:get, url).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the CrossRef OpenURL API" do
      stub = stub_request(:get, url).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.crossref.org/openurl/?pid=openurl_username&id=doi:#{work.doi_escaped}&noredirect=true", status: 408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data from the CrossRef API" do
    let(:null_response) { { works: [], events: [{ source_id: "crossref", work_id: work.pid, total: 0, extra: [] }] } }

    it "should report if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      result = { error: "DOI is missing." }
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq(error: "DOI is missing.")
    end

    it "should report if there are no events returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(null_response)
    end

    it "should report if there are events returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      event = response[:events].first
      expect(event[:source_id]).to eq("crossref")
      expect(event[:work_id]).to eq(work.pid)
      expect(event[:total]).to eq(31)

      expect(response[:works].length).to eq(31)
      related_work = response[:works].first
      expect(related_work["DOI"]).to eq("10.3758/s13423-011-0070-4")
      expect(related_work['author']).to eq([{"family"=>"Occelli", "given"=>"Valeria"}, {"family"=>"Spence", "given"=>"Charles"}, {"family"=>"Zampini", "given"=>"Massimiliano"}])
      expect(related_work['title']).to eq("Audiotactile interactions in temporal perception")
      expect(related_work['container-title']).to eq("Psychonomic Bulletin & Review")
      expect(related_work['issued']).to eq("date-parts"=>[[2011, 3, 12]])
      expect(related_work['volume']).to eq("18")
      expect(related_work['issue']).to eq("3")
      expect(related_work['page']).to eq("429-454")
      expect(related_work['type']).to eq("article-journal")
      expect(related_work['related_works']).to eq([{"pid"=> work.pid, "source_id"=>"crossref", "relation_type_id"=>"cites"}])

      event = response[:works].first
      expect(event["DOI"]).to eq("10.3758/s13423-011-0070-4")
      expect(event['author']).to eq([{"affiliation"=>[], "family"=>"Occelli", "given"=>"Valeria"}, {"affiliation"=>[], "family"=>"Spence", "given"=>"Charles"}, {"affiliation"=>[], "family"=>"Zampini", "given"=>"Massimiliano"}])
      expect(event['title']).to eq("Audiotactile interactions in temporal perception")
      expect(event['container-title']).to eq("Psychonomic Bulletin & Review")
      expect(event['issued']).to eq("date-parts"=>[[2011, 3, 12]])
      expect(event['volume']).to eq("18")
      expect(event['issue']).to eq("3")
      expect(event['page']).to eq("429-454")
      expect(event['type']).to eq("article-journal")
      expect(event['related_works']).to eq([{"pid"=> work.pid, "source_id"=>"crossref", "relation_type_id"=>"cites"}])

      extra = response[:events][:extra].first
      expect(extra[:event_url]).to eq("http://doi.org/#{extra[:event]['doi']}")
      expect(extra[:event_csl]['author']).to eq([{"family"=>"Occelli", "given"=>"Valeria"}, {"family"=>"Spence", "given"=>"Charles"}, {"family"=>"Zampini", "given"=>"Massimiliano"}])
      expect(extra[:event_csl]['title']).to eq("Audiotactile Interactions In Temporal Perception")
      expect(extra[:event_csl]['container-title']).to eq("Psychonomic Bulletin & Review")
      expect(extra[:event_csl]['issued']).to eq("date-parts"=>[[2011]])
      expect(extra[:event_csl]['type']).to eq("article-journal")
    end

    it "should report if there is one event returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      event = response[:events].first
      expect(event[:source_id]).to eq("crossref")
      expect(event[:work_id]).to eq(work.pid)
      expect(event[:total]).to eq(1)

      expect(response[:works].length).to eq(1)
      related_work = response[:works].first
      expect(related_work["DOI"]).to eq("10.3758/s13423-011-0070-4")
      expect(related_work['author']).to eq([{"family"=>"Occelli", "given"=>"Valeria"}, {"family"=>"Spence", "given"=>"Charles"}, {"family"=>"Zampini", "given"=>"Massimiliano"}])
      expect(related_work['title']).to eq("Audiotactile interactions in temporal perception")
      expect(related_work['container-title']).to eq("Psychonomic Bulletin & Review")
      expect(related_work['issued']).to eq("date-parts"=>[[2011, 3, 12]])
      expect(related_work['volume']).to eq("18")
      expect(related_work['issue']).to eq("3")
      expect(related_work['page']).to eq("429-454")
      expect(related_work['type']).to eq("article-journal")
      expect(related_work['related_works']).to eq([{"pid"=> work.pid, "source_id"=>"crossref", "relation_type_id"=>"cites"}])

      extra = event[:extra].first
      expect(extra[:event_url]).to eq("http://doi.org/#{extra[:event]['doi']}")
      expect(extra[:event_csl]['author']).to eq([{"family"=>"Occelli", "given"=>"Valeria"}, {"family"=>"Spence", "given"=>"Charles"}, {"family"=>"Zampini", "given"=>"Massimiliano"}])
      expect(extra[:event_csl]['title']).to eq("Audiotactile Interactions In Temporal Perception")
      expect(extra[:event_csl]['container-title']).to eq("Psychonomic Bulletin & Review")
      expect(extra[:event_csl]['issued']).to eq("date-parts"=>[[2011]])
      expect(extra[:event_csl]['type']).to eq("article-journal")
    end

    it "should catch timeout errors with the CrossRef API" do
      result = { error: "the server responded with status 408 for http://www.crossref.org/openurl/?pid=username&id=doi:#{work.doi_escaped}&noredirect=true", :status=>408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(result)
    end
  end

  context "parse_data from the CrossRef OpenURL API" do
    let(:work) { FactoryGirl.create(:work, doi: "10.1007/s00248-010-9734-2", canonical_url: "http://link.springer.com/work/10.1007%2Fs00248-010-9734-2#page-1", publisher_id: nil) }
    let(:null_response) { { works: [], events: [{ source_id: "crossref", work_id: work.pid, total: 0, extra: [] }] } }

    it "should report if the doi is missing" do
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq(null_response)
    end

    it "should report if there is an event count of zero returned by the CrossRef OpenURL API" do
      body = File.read(fixture_path + 'cross_ref_openurl_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(null_response)
    end

    it "should report if there is an event count greater than zero returned by the CrossRef OpenURL API" do
      body = File.read(fixture_path + 'cross_ref_openurl.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      event = response[:events].first
      expect(event[:total]).to eq(13)
    end

    it "should catch timeout errors with the CrossRef OpenURL API" do
      result = { error: "the server responded with status 408 for http://www.crossref.org/openurl/?pid=username&id=doi:#{work.doi_escaped}&noredirect=true", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(result)
    end
  end
end
