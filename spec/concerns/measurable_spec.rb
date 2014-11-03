require 'rails_helper'

describe Source do

  describe "get_event_metrics" do
    describe "citations" do
      let(:citations) { 12 }
      let(:total) { citations }
      let(:output) do
        { :pdf => nil,
          :html => nil,
          :shares => nil,
          :groups => nil,
          :comments => nil,
          :likes => nil,
          :citations => citations,
          :total => total }
      end

      it 'should return citations' do
        result = subject.get_event_metrics(citations: citations)
        expect(result).to eq(output)
      end

      it 'should handle strings' do
        result = subject.get_event_metrics(citations: "#{citations}")
        expect(result).to eq(output)
      end

      it 'should report a separate total value' do
        result = subject.get_event_metrics(citations: citations, total: 14)
        expect(result[:citations]).to eq(citations)
        expect(result[:total]).to eq(14)
      end
    end
  end
end
