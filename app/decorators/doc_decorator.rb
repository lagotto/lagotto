class DocDecorator < Draper::Decorator
  delegate_all

  def content
    if ["card_list", "home"].include?(layout)
      content_list.map do |item|
        { subtitle:   item[:subtitle].sub(/\((.*)\)/, '<small class="pull-right">\1</small>'),
          subcontent: h.markdown(item[:subcontent]) }
      end
    else
      h.markdown object.content
    end
  end

  # split content into array by H2 header
  def content_list
    object.content.split("\n## ").reduce([]) do |sum, s|
      if s.blank?
        sum
      else
        item = s.split("\n", 2)
        sum << { subtitle: item[0], subcontent: item[1].to_s.strip }
      end
    end
  end
end
