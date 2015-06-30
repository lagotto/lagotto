require "rails_helper"

describe AlmStatsReport do
  subject(:report){ described_class.new(sources) }
  let(:sources){ [
      source_mendeley,
      source_pmc,
      source_counter
  ] }

  let(:source_mendeley){ FactoryGirl.create :mendeley }
  let(:source_pmc){ FactoryGirl.create :pmc }
  let(:source_counter){ FactoryGirl.create :counter }

  describe "#headers" do
    subject(:headers){ report.headers }
    it { should include("pid")}
    it { should include("publication_date")}
    it { should include("title")}

    it "includes all of the source names as individual columns" do
      sources.each do |source|
        expect(headers).to include(source.name)
      end
    end
  end

  describe "#line_items" do
    describe "when there are no retrieval_statuses or works" do
      it "returns an empty array" do
        expect(report.line_items).to eq([])
      end
    end

    describe "when there are retrieval_statuses for works" do
      let!(:retrieval_statuses){ [
        retrieval_status_with_mendeley_work,
        retrieval_status_with_with_pmc_work
      ] }

      let(:mendeley_work){ FactoryGirl.create(:work) }
      let(:pmc_work){ FactoryGirl.create(:work) }

      let(:retrieval_status_with_mendeley_work){
        FactoryGirl.create(:retrieval_status,
          work: mendeley_work,
          source: source_mendeley,
          total: 3
        )
      }

      let(:retrieval_status_with_with_pmc_work){
        FactoryGirl.create(:retrieval_status, :with_work_published_today,
          work: pmc_work,
          source: source_pmc,
          total: 1420
        )
      }

      it "returns an array of line items for every retrieval status" do
        expect(report.line_items.length).to eq(retrieval_statuses.length)
      end

      describe "each line item" do
        let(:first_line_item){ report.line_items[0] }
        let(:second_line_item){ report.line_items[1] }

        it "has the pid" do
          expect(first_line_item.field("pid")).to eq(retrieval_status_with_mendeley_work.work.pid)
          expect(second_line_item.field("pid")).to eq(retrieval_status_with_with_pmc_work.work.pid)
        end

        it "has the publication_date" do
          expect(first_line_item.field("publication_date")).to eq(retrieval_status_with_mendeley_work.work.published_on)
          expect(second_line_item.field("publication_date")).to eq(retrieval_status_with_with_pmc_work.work.published_on)
        end

        it "has the title" do
          expect(first_line_item.field("title")).to eq(retrieval_status_with_mendeley_work.work.title)
          expect(second_line_item.field("title")).to eq(retrieval_status_with_with_pmc_work.work.title)
        end

        it "has the total count for each source for the work" do
          expect(first_line_item.field("mendeley")).to eq(retrieval_status_with_mendeley_work.total)
          expect(second_line_item.field("pmc")).to eq(retrieval_status_with_with_pmc_work.total)
        end

        it "defaults the count to 0 when there is no count for a source/work" do
          retrieval_status_with_with_pmc_work.destroy
          expect(second_line_item.field("pmc")).to eq(0)
        end
      end

      context "and there are multiple retrieval_statuses for one work across sources" do
        let!(:retrieval_statuses){ [
          retrieval_status_with_mendeley_work,
          retrieval_status_for_same_work_but_for_pmc,
          retrieval_status_for_same_work_but_for_counter
        ] }

        let!(:retrieval_status_for_same_work_but_for_pmc){
          FactoryGirl.create(:retrieval_status,
            work: retrieval_status_with_mendeley_work.work,
            source: source_pmc,
            total: 14
          )
        }

        let!(:retrieval_status_for_same_work_but_for_counter){
          FactoryGirl.create(:retrieval_status,
            work: retrieval_status_with_mendeley_work.work,
            source: source_counter,
            total: 13
          )
        }

        let(:line_items_for_work){
          report.line_items.select{ |i| i.field("pid") == retrieval_status_with_mendeley_work.work.pid }
        }
        let!(:line_item){ line_items_for_work.first }

        it "groups the retrieval statuses for the work into a single line item" do
          expect(line_items_for_work.length).to eq(1)
        end

        it "includes the totals for each source as fields on the line item" do
          expect(line_item.field("mendeley")).to eq(retrieval_status_with_mendeley_work.total)
          expect(line_item.field("pmc")).to      eq(retrieval_status_for_same_work_but_for_pmc.total)
          expect(line_item.field("counter")).to  eq(retrieval_status_for_same_work_but_for_counter.total)
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
          total: 44
        )
      }

      it "includes them in the report" do
        line_item = report.line_items.detect{ |item| item.field("pid") == retrieval_status_for_another_source.work.pid }
        expect(line_item).to_not be(nil)
      end
    end
  end


end
