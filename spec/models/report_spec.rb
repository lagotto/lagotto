require 'spec_helper'

describe Report do
  subject { Report }

  context "available reports" do

    before(:each) do
      FactoryGirl.create(:error_report_with_admin_user)
    end

    it "admin users should see one report" do
      response = subject.available("admin")
      response.length.should == 1
    end

    it "regular users should not see any report" do
      response = subject.available("user")
      response.length.should == 0
    end
  end

  context "generate csv" do
    let!(:article) { FactoryGirl.create(:article_with_events) }

    it "should format the ALM data as csv" do
      response = CSV.parse(subject.to_csv)
      #response.length.should == 2
      response.first.should eq(["doi", "publication_date", "title", "citeulike"])
      response.last.should eq([article.doi, article.published_on.iso8601, article.title, "50"])
    end
  end

  context "write csv to file" do

    before(:each) do
      FileUtils.rm_rf("#{Rails.root}/data/report_#{Date.today.iso8601}")
    end

    let!(:article) { FactoryGirl.create(:article_with_events, doi: "10.1371/journal.pcbi.1000204") }
    let(:csv) { subject.to_csv }
    let(:filename) { "alm_stats.csv" }
    let(:mendeley) { FactoryGirl.create(:mendeley) }

    it "should write report file" do
      filepath = "#{Rails.root}/data/report_#{Date.today.iso8601}/#{filename}"
      response = subject.write(filename, csv)
      response.should eq (filepath)
    end

    describe "merge and compress csv file" do

      before(:each) do
        subject.write(filename, csv)
      end

      it "should read stats" do
        stat = { name: "alm_stats" }
        response = subject.read_stats(stat).to_s
        response.should eq(csv)
      end

      it "should merge stats" do
        url = "#{CONFIG[:couchdb_url]}_design/reports/_view/mendeley"
        stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'mendeley_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
        filename = "mendeley_stats.csv"
        filepath = "#{Rails.root}/data/report_#{Date.today.iso8601}/#{filename}"
        csv = mendeley.to_csv
        subject.write(filename, csv)

        response = CSV.parse(subject.merge_stats)
        #response.length.should == 2
        response.first.should eq(["doi", "publication_date", "title", "citeulike", "mendeley_readers", "mendeley_groups", "mendeley"])
        response.last.should eq([article.doi, article.published_on.iso8601, article.title, "50", "1663", "0", "1663"])
        File.delete filepath
      end

      it "should merge stats from single report" do
        response = subject.merge_stats.to_s
        response.should eq(csv)
      end

      it "should zip report file" do
        csv = subject.merge_stats
        filename = "alm_report.csv"
        zip_filepath = "#{Rails.root}/public/files/alm_report.zip"
        alm_report = subject.write(filename, csv)

        response = subject.zip_file
        response.should eq(zip_filepath)
        File.exist?(zip_filepath).should be_true
        File.delete zip_filepath
      end

      it "should zip report folder" do
        zip_filepath = "#{Rails.root}/data/report_#{Date.today.iso8601}.zip"
        response = subject.zip_folder
        response.should eq(zip_filepath)
        File.exist?(zip_filepath).should be_true
        File.delete zip_filepath
      end
    end
  end

  context "error report" do
    let(:report) { FactoryGirl.create(:error_report_with_admin_user) }

    it "send email" do
      report.send_error_report
      mail = ActionMailer::Base.deliveries.last
      mail.to.should == [report.users.map(&:email).join(",")]
      mail.subject.should == "[ALM] Error Report"
    end

    it "generates a multipart message (plain text and html)" do
      report.send_error_report
      mail = ActionMailer::Base.deliveries.last
      mail.body.parts.length.should == 2
      mail.body.parts.collect(&:content_type).should == ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
    end

    it "generates proper links to the admin dashboard" do
      report.send_error_report
      mail = ActionMailer::Base.deliveries.last
      body_html = mail.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source
      body_html.should include("<a href=\"http://#{CONFIG[:hostname]}/admin/alerts\">Go to admin dashboard</a>")
    end
  end

  context "stale source report" do
    let(:source) { FactoryGirl.create(:citeulike) }
    let(:source_ids) { [source.id] }
    let(:report) { FactoryGirl.create(:stale_source_report_with_admin_user) }

    it "send email" do
      report.send_stale_source_report(source_ids)
      mail = ActionMailer::Base.deliveries.last
      mail.to.should == [report.users.map(&:email).join(",")]
      mail.subject.should == "[ALM] Stale Source Report"
    end

    it "generates a multipart message (plain text and html)" do
      report.send_stale_source_report(source_ids)
      mail = ActionMailer::Base.deliveries.last
      mail.body.parts.length.should == 2
      mail.body.parts.collect(&:content_type).should == ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
    end

    it "generates proper links to the admin dashboard" do
      report.send_stale_source_report(source_ids)
      mail = ActionMailer::Base.deliveries.last
      body_html = mail.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source
      body_html.should include("<a href=\"http://#{CONFIG[:hostname]}/admin/alerts?class=SourceNotUpdatedError\">Go to admin dashboard</a>")
    end
  end
end
