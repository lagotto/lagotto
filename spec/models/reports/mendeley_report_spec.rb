require "rails_helper"

describe MendeleyReport do
  subject(:report){ MendeleyReport.new(source) }
  let(:source){ FactoryGirl.create :mendeley }

  let!(:retrieval_statuses){ [
    retrieval_status_with_few_readers,
    retrieval_status_with_many_readers
  ] }

  let(:work_1){ FactoryGirl.create(:work)}
  let(:work_2){ FactoryGirl.create(:work)}

  let(:retrieval_status_with_few_readers){
    FactoryGirl.create(:retrieval_status,
      work: work_1,
      source: source,
      readers: 1,
      total: 3
    )
  }

  let(:retrieval_status_with_many_readers){
    FactoryGirl.create(:retrieval_status,
      work: work_2,
      source: source,
      readers: 1319,
      total: 1420
    )
  }

  describe "#headers" do
    it "returns the column headers for the report" do
      expect(report.headers).to eq(["pid_type", "pid", "readers", "groups", "total"])
    end
  end

  describe "line items" do
    let(:line_items){ items = [] ; report.each_line_item{ |item| items << item } ; items }

    describe "when there are no retrieval_statuses or works" do
      let!(:retrieval_statuses){ [] }

      it "has no line items" do
        expect(line_items).to eq([])
      end
    end

    describe "when there are retrieval_statuses for works" do
      it "yields each line item, one for each retrieval status" do
        items = []
        report.each_line_item{ |item| items << item }
        expect(items.length).to eq(retrieval_statuses.length)
      end

      it "has an array of line items for every retrieval status" do
        expect(report.line_items.length).to eq(retrieval_statuses.length)
      end

      describe "each line item" do
        let(:first_line_item){ line_items[0] }
        let(:second_line_item){ line_items[1] }

        it "has the pid_type" do
          expect(first_line_item.field("pid_type")).to eq("doi")
          expect(second_line_item.field("pid_type")).to eq("doi")
        end

        it "has the pid" do
          expect(first_line_item.field("pid")).to eq(retrieval_status_with_few_readers.work.pid)
          expect(second_line_item.field("pid")).to eq(retrieval_status_with_many_readers.work.pid)
        end

        it "has the readers count" do
          expect(first_line_item.field("readers")).to eq(retrieval_status_with_few_readers.readers)
          expect(second_line_item.field("readers")).to eq(retrieval_status_with_many_readers.readers)
        end

        it "has the total count" do
          expect(first_line_item.field("total")).to eq(retrieval_status_with_few_readers.total)
          expect(second_line_item.field("total")).to eq(retrieval_status_with_many_readers.total)
        end

        context "and the # of readers is 0" do
          before { retrieval_status_with_few_readers.update_attributes readers: 0, total: 8 }

          it "sets the groups count to 0" do
            expect(first_line_item.field("groups")).to eq(0)
          end
        end

        context "and the number of readers is greater than 0" do
          before { retrieval_status_with_few_readers.update_attributes readers: 5, total: 8 }

          it "sets the groups count to difference between the total and readers counts" do
            expect(first_line_item.field("groups")).to eq(3)
          end
        end
      end
    end

    describe "when there are retrieval_statuses for works for sources other sources" do
      let!(:retrieval_statuses){ [
        retrieval_status_for_another_source
      ] }

      let(:retrieval_status_for_another_source){
        FactoryGirl.create(:retrieval_status, :with_work_published_today,
          source: FactoryGirl.create(:source),
          readers: 99,
          total: 44
        )
      }

      it "does not include line item stats for other sources" do
        line_item = line_items.detect{ |item| item.field("pid") == retrieval_status_for_another_source.work.pid }
        expect(line_item).to be(nil)
      end
    end
  end

  describe "#to_csv" do
    let(:expected_csv){ <<-CSV.gsub(/^\s+/, '')
      pid_type,pid,readers,groups,total
      doi,#{work_1.pid},1,2,3
      doi,#{work_2.pid},1319,101,1420
      CSV
    }

    it "returns the report formatted in CSV" do
      expect(CSV.parse(report.to_csv)).to eq(CSV.parse(expected_csv))
    end
  end
end
