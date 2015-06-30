require "rails_helper"

describe AlmCombinedStatsReport do
  subject(:report){ described_class.new(
    alm_report: alm_report,
    pmc_report: pmc_report,
    counter_report: counter_report,
    mendeley_report: mendeley_report
  ) }

  let(:alm_report){ double("AlmStatsReport", headers: ["pid", "publication_date"], line_items: alm_line_items) }
  let(:pmc_report){ double("PmcStatsReport", line_items: pmc_line_items) }
  let(:counter_report){ double("CounterStatsReport", line_items: counter_line_items) }
  let(:mendeley_report){ double("MendeleyStatsReport", line_items: mendeley_line_items) }

  let(:alm_line_items){ [alm_line_item_1, alm_line_item_2] }
  let(:pmc_line_items){ [pmc_line_item_1, pmc_line_item_2] }
  let(:counter_line_items){ [counter_line_item_1, counter_line_item_2] }
  let(:mendeley_line_items){ [mendeley_line_item_1, mendeley_line_item_2] }

  let(:alm_line_item_1){ Reportable::LineItem.new(pid: 1, publication_date: "2015-02-04") }
  let(:pmc_line_item_1){ Reportable::LineItem.new(pid: 1, html: 10, pdf: 11) }
  let(:counter_line_item_1){ Reportable::LineItem.new(pid: 1, html: 12, pdf: 13) }
  let(:mendeley_line_item_1){ Reportable::LineItem.new(pid: 1, readers: 14, groups: 15) }

  let(:alm_line_item_2){ Reportable::LineItem.new(pid: 2, publication_date: "2015-03-05") }
  let(:pmc_line_item_2){ Reportable::LineItem.new(pid: 2, html: 20, pdf: 21) }
  let(:counter_line_item_2){ Reportable::LineItem.new(pid: 2, html: 22, pdf: 23) }
  let(:mendeley_line_item_2){ Reportable::LineItem.new(pid: 2, readers: 24, groups: 25) }

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

  describe "#line_items" do
    subject(:line_items){ report.line_items }

    context "and there are no line items found on any of the reports" do
      let(:alm_line_items){ [] }
      let(:pmc_line_items){ [] }
      let(:counter_line_items){ [] }
      let(:mendeley_line_items){ [] }

      it "returns an empty array" do
        expect(line_items).to eq []
      end
    end

    context "and there are line items found" do

      it "returns an array of line items, one for each unique work pid" do
        expect(line_items.length).to eq(2)
      end

      describe "each line item" do
        let(:line_item_1){ line_items.detect{ |i| i.field("pid") == alm_line_item_1.field("pid") } }
        let(:line_item_2){ line_items.detect{ |i| i.field("pid") == alm_line_item_2.field("pid") } }

        it "has a value for every AlmStatsRepot header" do
          alm_report.headers.each do |header|
            expect(line_item_1.field(header)).to eq(alm_line_item_1.field(header))
            expect(line_item_2.field(header)).to eq(alm_line_item_2.field(header))
          end
        end

        it "has pmc_html" do
          expect(line_item_1.field("pmc_html")).to eq(pmc_line_item_1.field("html"))
        end

        it "has pmc_pdf" do
          expect(line_item_1.field("pmc_pdf")).to eq(pmc_line_item_1.field("pdf"))
        end

        it "has counter_html" do
          expect(line_item_1.field("counter_html")).to eq(counter_line_item_1.field("html"))
        end

        it "has counter_pdf" do
          expect(line_item_1.field("counter_pdf")).to eq(counter_line_item_1.field("pdf"))
        end

        it "has mendeley_readers" do
          expect(line_item_1.field("mendeley_readers")).to eq(mendeley_line_item_1.field("readers"))
        end

        it "has mendeley_groups" do
          expect(line_item_1.field("mendeley_groups")).to eq(mendeley_line_item_1.field("groups"))
        end
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

    it "returns a the report formatted in CSV" do
      expect(CSV.parse(report.to_csv)).to eq(CSV.parse(expected_csv))
    end
  end

  describe "integration example, sanity check" do
    subject(:report){ described_class.new(
      alm_report: alm_report,
      pmc_report: pmc_report,
      counter_report: counter_report,
      mendeley_report: mendeley_report
    ) }

    let(:alm_report){ AlmStatsReport.new([source_pmc, source_counter, source_mendeley]) }
    let(:pmc_report){ PmcReport.new(source_pmc) }
    let(:counter_report){ CounterReport.new(source_counter) }
    let(:mendeley_report){ MendeleyReport.new(source_mendeley) }

    let(:source_mendeley){ FactoryGirl.create :mendeley }
    let(:source_pmc){ FactoryGirl.create :pmc }
    let(:source_counter){ FactoryGirl.create :counter }

    let(:work){ FactoryGirl.create(:work) }

    let(:work_retrieval_status_mendeley){
      FactoryGirl.create(:retrieval_status,
        work: work,
        source: source_mendeley,
        readers: 1,
        total: 50
      )
    }

    let!(:work_retrieval_status_pmc){
      FactoryGirl.create(:retrieval_status,
        work: work,
        source: source_pmc,
        pdf: 3,
        html: 4,
        total: 14
      )
    }

    let!(:work_retrieval_status_counter){
      FactoryGirl.create(:retrieval_status,
        work: work,
        source: source_counter,
        pdf: 5,
        html: 6,
        total: 23
      )
    }

    it "constructs the right line item" do
      expected_line_item = Reportable::LineItem.new(
        pid:              work.pid,
        publication_date: work.published_on,
        title:            work.title,
        pmc:              work_retrieval_status_pmc.total,
        counter:          work_retrieval_status_counter.total,
        mendeley:         work_retrieval_status_mendeley.total,
        mendeley_readers: work_retrieval_status_mendeley.readers,
        mendeley_groups:  work_retrieval_status_mendeley.total - work_retrieval_status_mendeley.readers,
        pmc_pdf:          work_retrieval_status_pmc.pdf,
        pmc_html:         work_retrieval_status_pmc.html,
        counter_pdf:      work_retrieval_status_counter.pdf,
        counter_html:     work_retrieval_status_counter.html
      )
      expect(report.line_items.first).to eq(expected_line_item)
    end
  end
end
