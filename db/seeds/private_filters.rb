# encoding: UTF-8
# Load private filters
html_ratio_too_high_error= HtmlRatioTooHighError.find_or_create_by_name(
  :name => "HtmlRatioTooHighError",
  :display_name => "HTML ratio too high error",
  :description => "Raises an error if HTML/PDF ratio is higher than 50.")