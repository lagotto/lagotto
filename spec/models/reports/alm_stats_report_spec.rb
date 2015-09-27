require "rails_helper"

describe AlmStatsReport do
  subject(:report){ described_class.new(sources) }
  let(:sources){ [
      source_mendeley,
      source_pmc,
      source_counter
  ] }

  let(:source_mendeley){ FactoryGirl.create(:source, :mendeley) }
  let(:source_pmc){ FactoryGirl.create(:source, :pmc) }
  let(:source_counter){ FactoryGirl.create(:source, :counter) }

  let!(:events){ [
    event_with_mendeley_work,
    event_with_with_pmc_work
  ] }

  let(:mendeley_work){ FactoryGirl.create(:work) }
  let(:pmc_work){ FactoryGirl.create(:work) }

  let(:event_with_mendeley_work){
    FactoryGirl.create(:event,
      work: mendeley_work,
      source: source_mendeley,
      total: 3
    )
  }

  let(:event_with_with_pmc_work){
    FactoryGirl.create(:event, :with_work_published_today,
      work: pmc_work,
      source: source_pmc,
      total: 1420
    )
  }

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

  describe "line items" do
    let(:line_items){ items = [] ; report.each_line_item{ |item| items << item } ; items }

    describe "when there are no events for works" do
      let!(:events){ [] }

      it "has no line items" do
        expect(line_items).to eq([])
      end
    end

    describe "when there are events for works" do
      it "yields each line item, one for each event" do
        items = []
        report.each_line_item{ |item| items << item }
        expect(items.length).to eq(events.length)
      end

      it "has an array of line items for every event" do
        expect(report.line_items.length).to eq(events.length)
      end

      describe "each line item" do
        let(:first_line_item){ line_items[0] }
        let(:second_line_item){ line_items[1] }

        it "has the pid" do
          expect(first_line_item.field("pid")).to eq(event_with_mendeley_work.work.pid)
          expect(second_line_item.field("pid")).to eq(event_with_with_pmc_work.work.pid)
        end

        it "has the publication_date" do
          expect(first_line_item.field("publication_date")).to eq(event_with_mendeley_work.work.published_on)
          expect(second_line_item.field("publication_date")).to eq(event_with_with_pmc_work.work.published_on)
        end

        it "has the title" do
          expect(first_line_item.field("title")).to eq(event_with_mendeley_work.work.title)
          expect(second_line_item.field("title")).to eq(event_with_with_pmc_work.work.title)
        end

        it "has the total count for each source for the work" do
          expect(first_line_item.field("mendeley")).to eq(event_with_mendeley_work.total)
          expect(second_line_item.field("pmc")).to eq(event_with_with_pmc_work.total)
        end

        it "defaults the count to 0 when there is no count for a source/work" do
          event_with_with_pmc_work.destroy
          expect(second_line_item.field("pmc")).to eq(0)
        end
      end

      context "and there are multiple events for one work across sources" do
        let!(:events){ [
          event_with_mendeley_work,
          event_for_same_work_but_for_pmc,
          event_for_same_work_but_for_counter
        ] }

        let!(:event_for_same_work_but_for_pmc){
          FactoryGirl.create(:event,
            work: event_with_mendeley_work.work,
            source: source_pmc,
            total: 14
          )
        }

        let!(:event_for_same_work_but_for_counter){
          FactoryGirl.create(:event,
            work: event_with_mendeley_work.work,
            source: source_counter,
            total: 13
          )
        }

        let(:line_items_for_work){
          line_items.select{ |i| i.field("pid") == event_with_mendeley_work.work.pid }
        }
        let!(:line_item){ line_items_for_work.first }

        it "groups the retrieval statuses for the work into a single line item" do
          expect(line_items_for_work.length).to eq(1)
        end

        it "includes the totals for each source as fields on the line item" do
          expect(line_item.field("mendeley")).to eq(event_with_mendeley_work.total)
          expect(line_item.field("pmc")).to      eq(event_for_same_work_but_for_pmc.total)
          expect(line_item.field("counter")).to  eq(event_for_same_work_but_for_counter.total)
        end
      end
    end

    describe "when there are events for works for sources other sources" do
      let!(:events){ [
        event_for_another_source
      ] }

      let(:event_for_another_source){
        FactoryGirl.create(:event, :with_work_published_today,
          source: FactoryGirl.create(:source),
          total: 44
        )
      }

      it "includes them in the report" do
        line_item = report.line_items.detect{ |item| item.field("pid") == event_for_another_source.work.pid }
        expect(line_item).to_not be(nil)
      end
    end
  end

  describe "#to_csv" do
    let(:expected_csv){ <<-CSV.gsub(/^\s+/, '')
      pid,publication_date,title,mendeley,pmc,counter
      #{mendeley_work.pid},#{mendeley_work.published_on.to_date},#{mendeley_work.title},3,0,0
      #{pmc_work.pid},#{pmc_work.published_on.to_date},#{pmc_work.title},0,1420,0
      CSV
    }

    it "returns the report formatted in CSV" do
      expect(CSV.parse(report.to_csv)).to eq(CSV.parse(expected_csv))
    end
  end

end
