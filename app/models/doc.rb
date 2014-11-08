# encoding: UTF-8

class Doc
  attr_reader :title, :layout, :content, :content_list, :updated_at, :update_date, :cache_key

  def self.all
    Dir.entries(Rails.root.join("docs"))
  end

  def self.find(param)
    name = all.find { |doc| doc.downcase == "#{param.downcase}.md" }
    if name.present?
      new(name)
    else
      OpenStruct.new(title: nil, layout: nil, content: nil)
    end
  end

  def initialize(name)
    file = IO.read(Rails.root.join("docs/#{name}"))

    if (md = file.match(/^(?<metadata>---\s*\n.*?\n?)^(---\s*$)/m))
      content = md.post_match
      metadata = YAML.load(md[:metadata])
      title = metadata["title"]
      layout = metadata["layout"]
    end

    @content = content || ""
    @title = title || "No title"
    @layout = layout || "page"
    @updated_at =  File.mtime(Rails.root.join("docs/#{name}"))
  end

  # split content into array by H2 header
  def content_list
    content.split("\n## ").reduce([]) do |sum, s|
      if s.blank?
        sum
      else
        item = s.split("\n", 2)
        subtitle = item[0].sub(/\((.*)\)/, '<small class="pull-right">\1</small>')
        sum << { subtitle: subtitle, content: item[1].to_s.strip }
      end
    end
  end

  def update_date
    updated_at.utc.iso8601
  end

  def cache_key
    ActiveSupport::Cache.expand_cache_key [title, update_date]
  end
end
