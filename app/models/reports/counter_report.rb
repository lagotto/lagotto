class CounterReport < SourceReport

  def headers
    super + ["xml"]
  end

  protected

  def build_line_item_for_result(result)
    super.tap do |line_item|
      line_item[:xml] = line_item[:total] - (line_item[:pdf] + line_item[:html])
    end
  end

end
