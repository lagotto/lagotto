require 'rails_helper'

describe Counter do

  before(:each) do
    Date.stub(:today).and_return(Date.new(2013, 9, 5))
  end

  describe "date_range" do
    it 'should return this month and this year without options' do
      result = subject.date_range
      result.should eq([{ month: 9, year: 2013 }])
    end

    it 'should return the last three months with options month and year' do
      result = subject.date_range(month: 7, year: 2013)
      result.should eq([{ month: 7, year: 2013 }, { month: 8, year: 2013 }, { month: 9, year: 2013 }])
    end

    it 'should return the last three months with options month and year as string' do
      result = subject.date_range(month: "7", year: "2013")
      result.should eq([{ month: 7, year: 2013 }, { month: 8, year: 2013 }, { month: 9, year: 2013 }])
    end

    it 'should return this month and year on invalid month and year' do
      result = subject.date_range(month: "July", year: 2013)
      result.should eq([{ month: 9, year: 2013 }])
    end
  end

end

# the concern behaves differently for Pmc, returning dates until the last and not the current month
describe Pmc do

  before(:each) do
    Date.stub(:today).and_return(Date.new(2013, 9, 5))
  end

  describe "date_range" do
    it 'should return last month and this year' do
      result = subject.date_range
      result.should eq([{ month: 8, year: 2013 }])
    end

    it 'should return the last three months until last month with options month and year' do
      result = subject.date_range(month: 7, year: 2013)
      result.should eq([{ month: 7, year: 2013 }, { month: 8, year: 2013 }])
    end

    it 'should return the last three months until last month with options month and year as string' do
      result = subject.date_range(month: "7", year: "2013")
      result.should eq([{ month: 7, year: 2013 }, { month: 8, year: 2013 }])
    end

    it 'should return last month and this year on invalid month and year' do
      result = subject.date_range(month: "July", year: 2013)
      result.should eq([{ month: 8, year: 2013 }])
    end
  end
end
