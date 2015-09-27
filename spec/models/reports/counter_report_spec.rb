require "rails_helper"

describe "Running a SourceReport for Counter" do
  include_examples "SourceReport examples",
    source_factory: :counter,
    report_class: CounterReport

  subject(:report){ CounterReport.new(source) }
  let(:source){ FactoryGirl.create(:source, :counter) }

  describe "#headers" do
    subject(:headers){ report.headers }
    it { should include("xml")}
  end

  describe "#line_items" do
    describe "when there are events for works" do
      let!(:events){ [
        event_with_readers
      ] }

      let(:event_with_readers){
        FactoryGirl.create(:event, :with_work_published_today,
          source: source,
          html: 6,
          pdf: 7,
          total: 30
        )
      }

      describe "each line item" do
        let(:first_line_item){ report.line_items[0] }

        it "has an xml count which is (total - (pdf + html))" do
          expect(first_line_item.field("xml")).to eq(17)
        end
      end
    end
  end

end
