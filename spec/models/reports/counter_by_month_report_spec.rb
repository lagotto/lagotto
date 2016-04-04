require "rails_helper"

describe "Running a SourceByMonthReport for Counter" do
  include_examples "SourceByMonthReport examples",
    source_factory: :counter_html,
    report_class: CounterByMonthReport

  subject(:report){ CounterByMonthReport.new(source, format: format, year: year, month: month) }
  let(:source){ FactoryGirl.create(:source, :counter_html) }

  describe "#line_items" do
    describe "when there are months (with stats) for a set of Work(s)" do
      let!(:works){ [ work_abc ] }
      let!(:work_abc){ FactoryGirl.create(:work) }
      let!(:november_2014_abc){ FactoryGirl.create(:month, :with_work, work: work_abc, year: 2014, month: Date.parse("2014-11-01").month, source: source) }

      describe "each line item" do
        let(:line_items){ report.line_items }
        let(:work_abc_line_item){
          line_items.detect{ |i| i.field("pid") == work_abc.pid }
        }

        context "when there is data for a given year-month" do
          let(:format){ :total }
          it "has the count which is made up of: total - (pdf + html)" do
            november_2014_abc.update_attributes total: 22
            expect(work_abc_line_item.field("2014-11")).to eq(22)
          end
        end
      end
    end
  end

end
