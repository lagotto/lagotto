require "rails_helper"

describe CounterByMonthReport do
  include Dateable

  subject(:report){ CounterByMonthReport.new(source, format:format, year:year, month:month) }
  let(:source){ FactoryGirl.create(:counter) }

  let(:format){ "pdf" }
  let(:year){ 2014 }
  let(:month){ 11 }

  it "must be constructed with a :format, :year, and :month" do
    expect {
      CounterByMonthReport.new
    }.to raise_error(ArgumentError, /missing keywords.*format.*year.*month/)

    expect {
      CounterByMonthReport.new(source, format:format, year:year, month:month)
    }.to_not raise_error
  end

  describe "#headers" do
    let(:dates){ date_range(year:year, month:month) }
    let(:formatted_dates){ dates.map { |date| "#{date[:year]}-#{date[:month]}" } }

    it "returns the headers including year-month ascending order from the given year/month to the current year/month" do
      expect(report.headers).to eq ["pid_type", "pid"].concat formatted_dates
    end
  end

  describe "#line_items" do
    describe "when there are no Counter months or works" do
      it "returns an empty array" do
        expect(report.line_items).to eq([])
      end
    end

    describe "when there are months (with stats) for a set of Work(s)" do
      let!(:works){ [
        work_abc,
        work_def
      ] }

      let!(:work_abc){ FactoryGirl.create(:work) }
      let!(:work_def){ FactoryGirl.create(:work) }

      let!(:november_2014_abc){ FactoryGirl.create(:month, :with_work, work: work_abc, year: 2014, month: Date.parse("2014-11-01").month, source: source) }
      let!(:december_2014_abc){ FactoryGirl.create(:month, :with_work, work: work_abc, year: 2014, month: Date.parse("2014-12-01").month, source: source) }
      let!(:january_2015_abc ){ FactoryGirl.create(:month, :with_work, work: work_abc, year: 2015, month: Date.parse("2015-01-01").month, source: source) }
      let!(:february_2015_abc){ FactoryGirl.create(:month, :with_work, work: work_abc, year: 2015, month: Date.parse("2015-02-01").month, source: source) }

      let!(:november_2014_def){ FactoryGirl.create(:month, :with_work, work: work_def, year: 2014, month: Date.parse("2014-11-01").month, source: source) }
      let!(:december_2014_def){ FactoryGirl.create(:month, :with_work, work: work_def, year: 2014, month: Date.parse("2014-12-01").month, source: source) }
      let!(:january_2015_def ){ FactoryGirl.create(:month, :with_work, work: work_def, year: 2015, month: Date.parse("2015-01-01").month, source: source) }

      it "returns an array of line items for every month for the corresponding work item" do
        expect(report.line_items.length).to eq(Month.all.group_by(&:work_id).count)
      end

      describe "each line item" do
        let(:line_items){ report.line_items }
        let(:work_abc_line_item){
          line_items.detect{ |i| i.field("pid") == work_abc.pid }
        }
        let(:work_def_line_item){
          line_items.detect{ |i| i.field("pid") == work_def.pid }
        }

        it "has the pid_type" do
          expect(work_abc_line_item.field("pid_type")).to eq("doi")
          expect(work_def_line_item.field("pid_type")).to eq("doi")
        end

        it "has the pid" do
          expect(work_abc_line_item.field("pid")).to eq(work_abc.pid)
          expect(work_def_line_item.field("pid")).to eq(work_def.pid)
        end

        context "when there is data for a given year-month for the given format" do
          context "and the specified format is :pdf" do
            let(:format){ :pdf }
            it "has the count" do
              november_2014_abc.update_attribute :pdf, 22
              expect(work_abc_line_item.field("2014-11")).to eq(22)
            end
          end

          context "and the specified format is :html" do
            let(:format){ :html }
            it "has the count" do
              november_2014_abc.update_attribute :html, 99
              expect(work_abc_line_item.field("2014-11")).to eq(99)
            end
          end

          context "and the specified format is :combined" do
            let(:format){ :combined }
            it "has the count as the sum of :pdf and :html counts" do
              november_2014_abc.update_attributes html: 99, pdf: 11
              expect(work_abc_line_item.field("2014-11")).to eq(110)
            end
          end
        end

        context "when there is no data for a given year-month" do
          it "has 0 for the given format" do
            expect(work_abc_line_item.field("2014-11")).to eq(0)
          end
        end
      end
    end

  end
end
