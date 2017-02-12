class String
  def my_titleize
    self.gsub(/(\b|_)(.)/) { "#{$1}#{$2.upcase}" }
  end
end
