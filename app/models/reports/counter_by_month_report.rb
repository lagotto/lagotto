class CounterByMonthReport < SourceByMonthReport

  register_value_provider_for_format :xml do |result|
    result.total - (result.pdf + result.html)
  end

end
