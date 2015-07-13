shared_examples_for "SourceReport examples" do |options|
  raise ArgumentError("Missing :source_factory") unless options[:source_factory]
  raise ArgumentError("Missing :report_class") unless options[:report_class]

  subject(:report){ options[:report_class].new(source) }
  let(:source){ FactoryGirl.create options[:source_factory] }

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
      html: 1,
      pdf: 2,
      total: 3
    )
  }

  let(:retrieval_status_with_many_readers){
    FactoryGirl.create(:retrieval_status,
      work: work_2,
      source: source,
      html: 1319,
      pdf: 100,
      total: 1420
    )
  }

  let(:line_items){ items = [] ; report.each_line_item{ |item| items << item } ; items }

  describe "#headers" do
    subject(:headers){ report.headers }
    it { should include("pid")}
    it { should include("html")}
    it { should include("pdf")}
    it { should include("total")}
  end

  describe "line items" do
    describe "when there are no retrieval_statuses" do
      let!(:retrieval_statuses){ [] }

      it "has no line items" do
        expect(line_items).to eq([])
      end
    end

    describe "when the source doesn't exist" do
      subject(:report){ options[:report_class].new(nil) }
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

    describe "when there are retrieval_statuses for works for sources other sources" do
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

      it "does not include line item stats for other sources" do
        line_item = line_items.detect{ |item| item.field("pid") == retrieval_status_for_another_source.work.pid }
        expect(line_item).to be(nil)
      end
    end
  end

  describe "#to_csv" do
    it "returns the report formatted in CSV" do
      expected_csv = []
      expected_csv << report.headers.join(",")
      report.line_items.map do |item|
        expected_csv << report.headers.map{ |h| item[h] }.join(',')
      end
      expect(CSV.parse(report.to_csv)).to eq(CSV.parse(expected_csv.join("\n")))
    end
  end

end
