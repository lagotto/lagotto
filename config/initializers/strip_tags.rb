
class String
  def strip_tags
    gsub(/<\/?[^>]*>/, "")
  end
end
