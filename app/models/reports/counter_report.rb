class CounterReport < SourceReport
  def self.xml_value_for_result(result)
    result.total - (result.pdf + result.html)
  end

  def headers
    super + ["xml"]
  end

  protected

  def build_line_item_for_result(result)
    super.tap do |line_item|
      line_item[:xml] = self.class.xml_value_for_result(result)
    end
  end
end
