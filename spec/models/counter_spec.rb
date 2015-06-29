require 'rails_helper'

describe Counter, type: :model, vcr: true do

  subject { FactoryGirl.create(:counter) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776") }

  describe "#to_csv" do
    let(:source){ FactoryGirl.create(:counter) }

    let!(:retrieval_statuses){ [
      retrieval_status_with_few_readers,
      retrieval_status_with_many_readers
    ] }

    let(:retrieval_status_with_few_readers){
      FactoryGirl.create(:retrieval_status, :with_work_published_today,
        source: source,
        html: 1,
        pdf: 2,
        total: 3
      )
    }

    let(:retrieval_status_with_many_readers){
      FactoryGirl.create(:retrieval_status, :with_work_published_today,
        source: source,
        html: 1319,
        pdf: 100,
        total: 1420
      )
    }

    it "generates a CSV report" do
      expect { CSV.parse(source.to_csv) }.to_not raise_error
    end

    describe "contents of the CSV report" do
      let(:csv){ CSV.parse(source.to_csv, headers: true) }

      it "has the proper column headers" do
        expect(csv.headers).to eq ["pid_type", "pid", "html", "pdf", "total"]
      end

      it "includes a row for every associated retrieval status" do
        expect(csv.length).to eq(retrieval_statuses.length)
      end

      describe "each row" do
        it "has the pid_type" do
          expect(csv[0].field("pid_type")).to eq("doi")
          expect(csv[1].field("pid_type")).to eq("doi")
        end

        it "has the pid" do
          expect(csv[0].field("pid")).to eq(retrieval_status_with_few_readers.work.pid)
          expect(csv[1].field("pid")).to eq(retrieval_status_with_many_readers.work.pid)
        end

        it "has the html count" do
          expect(csv[0].field("html")).to eq(retrieval_status_with_few_readers.html.to_s)
          expect(csv[1].field("html")).to eq(retrieval_status_with_many_readers.html.to_s)
        end

        it "has the pdf count" do
          expect(csv[0].field("pdf")).to eq(retrieval_status_with_few_readers.pdf.to_s)
          expect(csv[1].field("pdf")).to eq(retrieval_status_with_many_readers.pdf.to_s)
        end

        it "has the total count" do
          expect(csv[0].field("total")).to eq(retrieval_status_with_few_readers.total.to_s)
          expect(csv[1].field("total")).to eq(retrieval_status_with_many_readers.total.to_s)
        end
      end
    end

    context "and provided a :format option" do
      let!(:months) { [
        november_2014,
        december_2014,
        january_2015,
        february_2015
      ]}

      let!(:november_2014){ FactoryGirl.create(:month, :with_work, year: 2014, month: Date.parse("2014-11-01").month, source: source) }
      let!(:december_2014){ FactoryGirl.create(:month, :with_work, year: 2014, month: Date.parse("2014-12-01").month, source: source) }
      let!(:january_2015 ){ FactoryGirl.create(:month, :with_work, year: 2015, month: Date.parse("2015-01-01").month, source: source) }
      let!(:february_2015){ FactoryGirl.create(:month, :with_work, year: 2015, month: Date.parse("2015-02-01").month, source: source) }

      let!(:november_2014_work){ november_2014.work }
      let!(:december_2014_work){ december_2014.work }
      let!(:january_2015_work ){ january_2015.work }
      let!(:february_2015_work){ february_2015.work }

      it "generates a CSV report" do
        expect{ CSV.parse(source.to_csv(format: "pdf")) }.to_not raise_error
      end

      describe "contents of the CSV report" do
        include Dateable

        let(:format){ "pdf" }
        let(:year){ 2014 }
        let(:month){ 11 }

        let(:csv){ CSV.parse(source.to_csv(format: format, year: year, month: month), headers: true) }

        it "has the column headers reflect the year-month in ascending order from the given year/month to the current year/month" do
          dates = date_range(year:year, month:month)
          formatted_dates = dates.map { |date| "#{date[:year]}-#{date[:month]}" }
          expect(csv.headers).to eq ["pid_type", "pid"].concat formatted_dates
        end

        describe "it has a row for each work" do
          let(:works){ Month.all.map(&:work) }

          it "has the pid_type" do
            expect(csv[0].field("pid_type")).to eq("doi")
          end

          it "has the pid" do
            expect(csv[0].field("pid")).to eq(works[0].pid)
          end

          context "when there is data for a given year-month" do
            it "has count for the given format" do
              november_2014.update_attribute :pdf, 22
              csv = CSV.parse(source.to_csv(format: "pdf", year: year, month: month), headers: true)

              row = csv.detect{ |r| r.field("pid") == november_2014_work.pid }
              expect(row.field("2014-11")).to eq("22")

              february_2015.update_attribute :html, 49
              csv = CSV.parse(source.to_csv(format: "html", year: year, month: month), headers: true)
              row = csv.detect{ |r| r.field("pid") == february_2015_work.pid }
              expect(row.field("2015-2")).to eq("49")
            end
          end

          context "when there is no data for a given year-month" do
            it "has 0 for the given format" do
              november_2014.destroy
              csv = CSV.parse(source.to_csv(format: "html", year: year, month: month), headers: true)
              row = csv.detect{ |r| r.field("pid") == november_2014_work.pid }
              expect(csv[0].field("2014-11")).to eq("0")
            end
          end

        end
      end
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.create(:work, :doi => "10.5194/acp-12-12021-2012")
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the Counter API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'counter_nil.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(response['rest']['response']['results']['item']).to be_nil
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the Counter API" do
      response = subject.get_data(work)
      expect(response["rest"]["response"]["criteria"]).to eq("year"=>"all", "month"=>"all", "journal"=>"all", "doi"=>work.doi)
      expect(response["rest"]["response"]["results"]["total"]["total"]).to eq("5844")
      expect(response["rest"]["response"]["results"]["item"].length).to eq(66)
    end

    it "should catch timeout errors with the Counter API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, source_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.plosreports.org/services/rest?method=usage.stats&doi=#{work.doi_escaped}", status: 408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(events: { source: "counter", work: work.pid, pdf: 0, html: 0, total: 0, extra: [], months: [] })
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.create(:work, :doi => "10.5194/acp-12-12021-2012")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(events: { source: "counter", work: work.pid, pdf: 0, html: 0, total: 0, extra: [], months: [] })
    end

    it "should report if there are no events returned by the Counter API" do
      body = File.read(fixture_path + 'counter_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(events: { source: "counter", work: work.pid, pdf: 0, html: 0, total: 0, extra: [], months: [] })
    end

    it "should report if there are events returned by the Counter API" do
      body = File.read(fixture_path + 'counter.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events][:total]).to eq(3387)
      expect(response[:events][:pdf]).to eq(447)
      expect(response[:events][:html]).to eq(2919)
      expect(response[:events][:extra].length).to eq(37)
      expect(response[:events][:months].length).to eq(37)
      expect(response[:events][:months].first).to eq(month: 1, year: 2010, html: 299, pdf: 90, total: 390)
      expect(response[:events][:events_url]).to be_nil
    end

    it "should catch timeout errors with the Counter API" do
      result = { error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
