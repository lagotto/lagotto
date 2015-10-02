require 'rails_helper'

describe Source do

  describe "get_metrics" do
    describe "citations" do
      let(:citations) { 12 }
      let(:total) { citations }
      let(:output) do
        { :pdf => nil,
          :html => nil,
          :readers => nil,
          :comments => nil,
          :likes => nil,
          :total => total }
      end

      it 'should return citations' do
        result = subject.get_metrics(total: citations)
        expect(result).to eq(output)
      end

      it 'should handle strings' do
        result = subject.get_metrics(total: "#{citations}")
        expect(result).to eq(output)
      end
    end

    describe "readers" do
      let(:readers) { 12 }
      let(:total) { readers }
      let(:output) do
        { :pdf => nil,
          :html => nil,
          :readers => 12,
          :comments => nil,
          :likes => nil,
          :total => total }
      end

      it 'should return readers' do
        result = subject.get_metrics(readers: readers)
        expect(result).to eq(output)
      end

      it 'should handle strings' do
        result = subject.get_metrics(readers: "#{readers}")
        expect(result).to eq(output)
      end

      it 'should report a separate total value' do
        result = subject.get_metrics(readers: readers, total: 14)
        expect(result[:readers]).to eq(readers)
        expect(result[:total]).to eq(14)
      end
    end
  end

  describe 'get_iso8601_from_epoch' do
    it 'should handle seconds' do
      result = subject.get_iso8601_from_epoch(1350426975)
      expect(result).to eq("2012-10-16T22:36:15Z")
    end

    it 'should handle milliseconds' do
      result = subject.get_iso8601_from_epoch(1350426975660)
      expect(result).to eq("2012-10-16T22:36:15Z")
    end

    it 'should handle strings' do
      result = subject.get_iso8601_from_epoch("1350426975")
      expect(result).to eq("2012-10-16T22:36:15Z")
    end

    it 'should handle nil' do
      result = subject.get_iso8601_from_epoch(nil)
      expect(result).to be_nil
    end
  end
end
