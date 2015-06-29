require "rails_helper"

describe PmcReport do
  subject(:report){ PmcReport.new(source) }
  let(:source){ FactoryGirl.create(:pmc) }

  describe "#headers" do
    it "returns the column headers for the report" do
      expect(report.headers).to eq(["pid_type", "pid", "html", "pdf", "total"])
    end
  end

  describe "#line_items" do
    describe "when there are no Pmc retrieval_statuses or works" do
      it "returns an empty array" do
        expect(report.line_items).to eq([])
      end
    end

    describe "when there are Pmc retrieval_statuses for works" do
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

      it "returns an array of line items for every retrieval status" do
        expect(report.line_items.length).to eq(retrieval_statuses.length)
      end

      describe "each line item" do
        let(:first_line_item){ report.line_items[0] }
        let(:second_line_item){ report.line_items[1] }

        it "has the pid_type" do
          expect(first_line_item.field("pid_type")).to eq("doi")
          expect(second_line_item.field("pid_type")).to eq("doi")
        end

        it "has the pid" do
          expect(first_line_item.field("pid")).to eq(retrieval_status_with_few_readers.work.pid)
          expect(second_line_item.field("pid")).to eq(retrieval_status_with_many_readers.work.pid)
        end

        it "has the html count" do
          expect(first_line_item.field("html")).to eq(retrieval_status_with_few_readers.html)
          expect(second_line_item.field("html")).to eq(retrieval_status_with_many_readers.html)
        end

        it "has the pdf count" do
          expect(first_line_item.field("pdf")).to eq(retrieval_status_with_few_readers.pdf)
          expect(second_line_item.field("pdf")).to eq(retrieval_status_with_many_readers.pdf)
        end

        it "has the total count" do
          expect(first_line_item.field("total")).to eq(retrieval_status_with_few_readers.total)
          expect(second_line_item.field("total")).to eq(retrieval_status_with_many_readers.total)
        end
      end
    end

    describe "when there are retrieval_statuses for works for sources other than Pmc" do
      let!(:retrieval_statuses){ [
        retrieval_status_for_another_source
      ] }

      let(:retrieval_status_for_another_source){
        FactoryGirl.create(:retrieval_status, :with_work_published_today,
          source: FactoryGirl.create(:source),
          html: 99,
          pdf: 33,
          total: 44
        )
      }

      it "does not include non-Pmc sources" do
        line_item = report.line_items.detect{ |item| item.field("pid") == retrieval_status_for_another_source.work.pid }
        expect(line_item).to be(nil)
      end
    end
  end
end
