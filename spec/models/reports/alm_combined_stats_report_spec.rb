require "rails_helper"

describe AlmCombinedStatsReport do
  subject(:report){ described_class.new(
    alm_report: alm_report,
    pmc_report: pmc_report,
    counter_report: counter_report,
    mendeley_report: mendeley_report
  ) }

  let(:alm_report){ stubbed_alm_report }
  let(:pmc_report){ stubbed_pmc_report }
  let(:counter_report){ stubbed_counter_report }
  let(:mendeley_report){ stubbed_mendeley_report }

  let(:stubbed_alm_report){ double("AlmStatsReport", headers: ["pid", "publication_date"]) }
  let(:stubbed_pmc_report){ double("PmcStatsReport") }
  let(:stubbed_counter_report){ double("CounterStatsReport") }
  let(:stubbed_mendeley_report){ double("MendeleyStatsReport") }

  let(:alm_line_items){ [alm_line_item_1, alm_line_item_2] }
  let(:pmc_line_items){ [pmc_line_item_1, pmc_line_item_2] }
  let(:counter_line_items){ [counter_line_item_1, counter_line_item_2] }
  let(:mendeley_line_items){ [mendeley_line_item_1, mendeley_line_item_2] }

  let(:alm_line_item_1){ Reportable::LineItem.new(pid: 1, publication_date: "2015-02-04") }
  let(:pmc_line_item_1){ Reportable::LineItem.new(pid: 1, total: 21) }
  let(:counter_line_item_1){ Reportable::LineItem.new(pid: 1, total: 25) }
  let(:mendeley_line_item_1){ Reportable::LineItem.new(pid: 1, total: 29) }

  let(:alm_line_item_2){ Reportable::LineItem.new(pid: 2, publication_date: "2015-03-05") }
  let(:pmc_line_item_2){ Reportable::LineItem.new(pid: 2, total: 41) }
  let(:counter_line_item_2){ Reportable::LineItem.new(pid: 2, total: 45) }
  let(:mendeley_line_item_2){ Reportable::LineItem.new(pid: 2, total: 49) }

  before do
    allow(stubbed_alm_report).to receive(:each_line_item)
      .and_yield(alm_line_items[0])
      .and_yield(alm_line_items[1])

    allow(stubbed_pmc_report).to receive(:each_line_item)
      .and_yield(pmc_line_items[0])
      .and_yield(pmc_line_items[1])

    allow(stubbed_counter_report).to receive(:each_line_item)
      .and_yield(counter_line_items[0])
      .and_yield(counter_line_items[1])

    allow(stubbed_mendeley_report).to receive(:each_line_item)
      .and_yield(mendeley_line_items[0])
      .and_yield(mendeley_line_items[1])
  end

  describe "#headers" do
    subject(:headers){ report.headers }

    it "includes all of the AlmStatsReport headers" do
      alm_report.headers.each do |alm_header|
        expect(headers).to include(alm_header)
      end
    end

    it { should include("mendeley_readers") }
    it { should include("mendeley_groups") }
    it { should include("pmc_html") }
    it { should include("pmc_pdf") }
    it { should include("counter_html") }
    it { should include("counter_pdf") }
  end

  describe "#each_line_item" do
    it "enumerates over the line items, one for each unique work pid" do
      line_items = []
      report.each_line_item { |item| line_items << item }
      expect(line_items.length).to eq(2)
    end

    describe "each individual line item" do
      let(:line_items){ Array.new.tap{ |items| report.each_line_item { |item| items << item } } }
      let(:line_item_1){ line_items.detect{ |i| i.field("pid") == alm_line_item_1.field("pid") } }
      let(:line_item_2){ line_items.detect{ |i| i.field("pid") == alm_line_item_2.field("pid") } }

      it "has a value for every AlmStatsRepot header" do
        alm_report.headers.each do |header|
          expect(line_item_1.field(header)).to eq(alm_line_item_1.field(header))
          expect(line_item_2.field(header)).to eq(alm_line_item_2.field(header))
        end
      end

      it "has pmc_html" do
        expect(line_item_1.field("pmc_html")).to eq(pmc_line_item_1.field("total"))
      end

      it "has pmc_pdf" do
        expect(line_item_1.field("pmc_pdf")).to eq(pmc_line_item_1.field("total"))
      end

      it "has counter_html" do
        expect(line_item_1.field("counter_html")).to eq(counter_line_item_1.field("total"))
      end

      it "has counter_pdf" do
        expect(line_item_1.field("counter_pdf")).to eq(counter_line_item_1.field("total"))
      end

      it "has mendeley_readers" do
        expect(line_item_1.field("mendeley_readers")).to eq(mendeley_line_item_1.field("total"))
      end

      it "has mendeley_groups" do
        expect(line_item_1.field("mendeley_groups")).to eq(mendeley_line_item_1.field("total"))
      end
    end
  end

  describe "#to_csv" do
    let(:expected_csv){ <<-CSV.gsub(/^\s+/, '')
      pid,publication_date,mendeley_readers,mendeley_groups,pmc_html,pmc_pdf,counter_html,counter_pdf
      1,2015-02-04,14,15,10,11,12,13
      2,2015-03-05,24,25,20,21,22,23
      CSV
    }

    it "returns the report formatted in CSV" do
      expect(CSV.parse(report.to_csv)).to eq(CSV.parse(expected_csv))
    end
  end

  describe "integration example, sanity check" do
    let(:alm_report){ AlmStatsReport.new([source_pmc, source_counter, source_mendeley]) }
    let(:pmc_report){ PmcReport.new(source_pmc) }
    let(:counter_report){ CounterReport.new(source_counter) }
    let(:mendeley_report){ MendeleyReport.new(source_mendeley) }

    let(:source_mendeley){ FactoryGirl.create(:source, :mendeley) }
    let(:source_pmc){ FactoryGirl.create(:source, :pmc) }
    let(:source_counter){ FactoryGirl.create(:source, :counter) }

    let(:work){ FactoryGirl.create(:work) }

    let(:work_relation_mendeley){
      FactoryGirl.create(:relation,
        work: work,
        source: source_mendeley,
        total: 50
      )
    }

    let!(:work_relation_pmc){
      FactoryGirl.create(:relation,
        work: work,
        source: source_pmc,
        total: 14
      )
    }

    let!(:work_relation_counter){
      FactoryGirl.create(:relation,
        work: work,
        source: source_counter,
        total: 23
      )
    }

    it "constructs the right line item" do
      expected_line_item = Reportable::LineItem.new(
        pid:              work.pid,
        publication_date: work.published_on,
        title:            work.title,
        pmc:              work_relation_pmc.total,
        counter:          work_relation_counter.total,
        mendeley:         work_relation_mendeley.total,
        # mendeley_readers: work_relation_mendeley.readers,
        # mendeley_groups:  work_event_mendeley.total - work_event_mendeley.readers,
        # pmc_pdf:          work_event_pmc.pdf,
        # pmc_html:         work_event_pmc.html,
        # counter_pdf:      work_event_counter.pdf,
        # counter_html:     work_event_counter.html
      )

      expect(report.line_items.first).to eq(expected_line_item)
    end
  end
end
