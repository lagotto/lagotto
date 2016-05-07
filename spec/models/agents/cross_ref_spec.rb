require 'rails_helper'

describe CrossRef, type: :model, vcr: true do
  subject { FactoryGirl.create(:crossref) }

  let(:publisher) { FactoryGirl.create(:publisher) }
  let!(:publisher_option) { FactoryGirl.create(:publisher_option, agent: subject, publisher: publisher) }
  let(:work) { FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.pone.0043007", doi: "10.1371/journal.pone.0043007", canonical_url: "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007", publisher: publisher) }

  it "should report that there are no events if the doi is missing" do
    work = FactoryGirl.create(:work, :doi => nil)
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
      publisher_option = FactoryGirl.create(:publisher_option, agent: subject, publisher: publisher, password: nil)
      expect { subject.get_query_url(work_id: work.id) }.to raise_error(ArgumentError, "CrossRef username or password is missing.")
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
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://doi.crossref.org/servlet/getForwardLinks?usr=username&pwd=password&doi=#{work.doi_escaped}", status: 408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
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
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.crossref.org/openurl/?pid=openurl_username&id=doi:#{work.doi_escaped}&noredirect=true", status: 408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data from the CrossRef API" do
    let(:null_response) { { works: [], events: [{ source_id: "crossref", work_id: work.pid, total: 0, extra: [] }] } }

    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = { error: "DOI is missing." }
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq([result])
    end

    it "should report if there are no events returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(31)
      expect(response.first[:prefix]).to eq("10.1371")
      expect(response.first[:relation]).to eq("subj_id"=>"http://doi.org/10.3758/s13423-011-0070-4",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"cites",
                                              "source_id"=>"crossref",
                                              "publisher_id"=>"297")

      expect(response.first[:subj]).to eq("pid"=>"http://doi.org/10.3758/s13423-011-0070-4",
                                          "author"=>[{"family"=>"Occelli", "given"=>"Valeria"},
                                                     {"family"=>"Spence", "given"=>"Charles"},
                                                     {"family"=>"Zampini", "given"=>"Massimiliano"}],
                                          "title"=>"Audiotactile interactions in temporal perception",
                                          "container-title"=>"Psychonomic Bulletin & Review",
                                          "issued"=>"2011-03-12",
                                          "volume"=>"18",
                                          "issue"=>"3",
                                          "page"=>"429-454",
                                          "DOI"=>"10.3758/s13423-011-0070-4",
                                          "type"=>"article-journal",
                                          "tracked"=>false,
                                          "publisher_id"=>"297",
                                          "registration_agency_id"=>"crossref")
    end

    it "should report if there is one event returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(1)
      expect(response.first[:prefix]).to eq("10.1371")
      expect(response.first[:relation]).to eq("subj_id"=>"http://doi.org/10.3758/s13423-011-0070-4",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"cites",
                                              "source_id"=>"crossref",
                                              "publisher_id"=>"297")

      expect(response.first[:subj]).to eq("pid"=>"http://doi.org/10.3758/s13423-011-0070-4",
                                          "author"=>[{"family"=>"Occelli", "given"=>"Valeria"},
                                                     {"family"=>"Spence", "given"=>"Charles"},
                                                     {"family"=>"Zampini", "given"=>"Massimiliano"}],
                                          "title"=>"Audiotactile interactions in temporal perception",
                                          "container-title"=>"Psychonomic Bulletin & Review",
                                          "issued"=>"2011-03-12",
                                          "volume"=>"18",
                                          "issue"=>"3",
                                          "page"=>"429-454",
                                          "DOI"=>"10.3758/s13423-011-0070-4",
                                          "type"=>"article-journal",
                                          "tracked"=>false,
                                          "publisher_id"=>"297",
                                          "registration_agency_id"=>"crossref")
    end

    it "should catch timeout errors with the CrossRef API" do
      result = { error: "the server responded with status 408 for http://www.crossref.org/openurl/?pid=username&id=doi:#{work.doi_escaped}&noredirect=true", :status=>408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end

  context "parse_data from the CrossRef OpenURL API" do
    let(:work) { FactoryGirl.create(:work, doi: "10.1007/s00248-010-9734-2", canonical_url: "http://link.springer.com/work/10.1007%2Fs00248-010-9734-2#page-1", publisher_id: nil) }
    let(:null_response) { { works: [], events: [{ source_id: "crossref", work_id: work.pid, total: 0, extra: [] }] } }

    it "should report if the doi is missing" do
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there is an event count of zero returned by the CrossRef OpenURL API" do
      body = File.read(fixture_path + 'cross_ref_openurl_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there is an event count greater than zero returned by the CrossRef OpenURL API" do
      body = File.read(fixture_path + 'cross_ref_openurl.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(1)
      expect(response.first[:relation]).to eq("subj_id"=>"https://crossref.org",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"cites",
                                              "total"=>13,
                                              "source_id"=>"crossref")
    end

    it "should catch timeout errors with the CrossRef OpenURL API" do
      result = { error: "the server responded with status 408 for http://www.crossref.org/openurl/?pid=username&id=doi:#{work.doi_escaped}&noredirect=true", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
