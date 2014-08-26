module MonthRangeHelper
  class MonthRange
    include Enumerable
    def initialize(first_date, last_date)
      @first = Date.civil(first_date.year, first_date.month, 1)
      @last = Date.civil(last_date.year, last_date.month, 1)
      @offset = (@first > @last) ? -1 : 1
    end

    def each
      d = @first
      loop do
        yield d
        d >>= @offset
        break if (d <=> @last) == @offset
      end
    end
  end

  def month_range(start_date, end_date)
    MonthRange.new(start_date, end_date)
  end
end
