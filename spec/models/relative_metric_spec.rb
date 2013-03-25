require 'spec_helper'

describe RelativeMetric do
  let(:relative_metric) {FactoryGirl.create(:relative_metric)}

  it "should return the Subject Areas via Solr API" do
    article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0005723")

    stub_request(:get, "#{relative_metric.solr_url}?fl=id,subject_hierarchy&fq=doc_type:full&q=id:%2210.1371/journal.pone.0005723%22&wt=json").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => File.read("#{fixture_path}relative_metric_subject_areas.json"), :headers => {})

    subject_areas = relative_metric.get_subject_areas(article)

    subject_areas.should eq(["/Biology and life sciences", "/Biology and life sciences/Anatomy and physiology", "/Biology and life sciences/Zoology", "/Research and analysis methods", "/Research and analysis methods/Imaging techniques"].to_set)
  end

  it "should not return any subject area data because the article doesn't exist" do
    doi = "10.1371/journal.pone.0005723555"
    article = FactoryGirl.build(:article, :doi => doi)

    stub_request(:get, "#{relative_metric.solr_url}?fl=id,subject_hierarchy&fq=doc_type:full&q=id:%22#{doi}%22&wt=json").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => File.read("#{fixture_path}relative_metric_no_subject_areas.json"), :headers => {})

    subject_areas = relative_metric.get_subject_areas(article)

    subject_areas.should eq(Set.new)
  end

  it "should not return any subject area data because the article doesn't have any subject areas" do
    article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020041")

    stub_request(:get, "#{relative_metric.solr_url}?fl=id,subject_hierarchy&fq=doc_type:full&q=id:%2210.1371/journal.pmed.0020041%22&wt=json").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => File.read("#{fixture_path}relative_metric_no_subject_areas2.json"), :headers => {})

    subject_areas = relative_metric.get_subject_areas(article)

    subject_areas.should eq(Set.new)
  end  

  it "should return start year" do
    article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0005723", :published_on => Date.new(2009, 5, 19))
    year = relative_metric.get_start_year(article)
    year.should eq(2009)
  end

  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    relative_metric.get_data(article_without_doi).should eq({ :events => [], :event_count => nil })
  end

  it "should report that there are no events if the doi is not is_publisher" do
    article_not_processed = FactoryGirl.build(:article, :doi => "10.4084/MJHID.2013.016")
    relative_metric.get_data(article_not_processed).should eq({ :events => [], :event_count => nil })
  end

  it "should get relative metric average usage data" do
    article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0005723", :published_on => Date.new(2009, 5, 19))

    stub_request(:get, "#{relative_metric.solr_url}?fl=id,subject_hierarchy&fq=doc_type:full&q=id:%2210.1371/journal.pone.0005723%22&wt=json").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => File.read("#{fixture_path}relative_metric_subject_areas_small.json"), :headers => {})

    key = ["/Biology and life sciences", 2009]
    url = relative_metric.url % { :key => CGI.escape(key.to_json) }
    stub_request(:get, "#{url}").to_return(:body => File.read("#{fixture_path}relative_metric_biology.json"))

    data = relative_metric.get_data(article)

    events = {
      :start_date => "2009-01-01T00:00:00Z",
      :end_date => "2011-12-31T00:00:00Z",
      :subject_areas => [{ :subject_area => "/Biology and life sciences", :average_usage => [1129,2005,2240,2408,2566,2715,2855,2993,3128,3257,3386,3511,3628,3733,3835,3932,4027,4120,4210,4299,4389,4472,4552,4632,4710,4791,4862,4934,5010,5086,5165,5246,5330,5416,5496,5590,5678,5763,5841,5922,6004,6075,6159,6235,6314,6401,6487,6552,6626,6668,6677]}]
    }

    total = 237060
    event_metrics = { :pdf => nil,
                      :html => nil,
                      :shares => nil,
                      :groups => nil,
                      :comments => nil,
                      :likes => nil,
                      :citations => nil,
                      :total => total }

    events_data = {
      :events => events,
      :event_count => total,
      :event_metrics => event_metrics
    }

    data.should eq(events_data)
  end

end
