require 'rails_helper'

describe Counter do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

  describe "date_range" do
    it 'should return this month and this year without options' do
      result = subject.date_range
      expect(result).to eq([{ month: 9, year: 2013 }])
    end

    it 'should return the last three months with options month and year' do
      result = subject.date_range(month: 7, year: 2013)
      expect(result).to eq([{ month: 7, year: 2013 }, { month: 8, year: 2013 }, { month: 9, year: 2013 }])
    end

    it 'should return the last three months with options month and year as string' do
      result = subject.date_range(month: "7", year: "2013")
      expect(result).to eq([{ month: 7, year: 2013 }, { month: 8, year: 2013 }, { month: 9, year: 2013 }])
    end

    it 'should return this month and year on invalid month and year' do
      result = subject.date_range(month: "July", year: 2013)
      expect(result).to eq([{ month: 9, year: 2013 }])
    end
  end

  describe "get_year_month" do
    it 'should return the year and month' do
      result = subject.get_year_month(Time.zone.now.utc.iso8601)
      expect(result).to eq([2013, 9])
    end
  end

end

# the concern behaves differently for Pmc, returning dates until the last and not the current month
describe Pmc do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

  describe "date_range" do
    it 'should return last month and this year' do
      result = subject.date_range
      expect(result).to eq([{ month: 8, year: 2013 }])
    end

    it 'should return the last three months until last month with options month and year' do
      result = subject.date_range(month: 7, year: 2013)
      expect(result).to eq([{ month: 7, year: 2013 }, { month: 8, year: 2013 }])
    end

    it 'should return the last three months until last month with options month and year as string' do
      result = subject.date_range(month: "7", year: "2013")
      expect(result).to eq([{ month: 7, year: 2013 }, { month: 8, year: 2013 }])
    end

    it 'should return last month and this year on invalid month and year' do
      result = subject.date_range(month: "July", year: 2013)
      expect(result).to eq([{ month: 8, year: 2013 }])
    end
  end
end
