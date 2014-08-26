# encoding: UTF-8

class Doc
  attr_reader :title, :content, :updated_at, :update_date, :cache_key

  def self.all
    Dir.entries(Rails.root.join("docs"))
  end

  def self.find(param)
    name = all.find { |doc| doc.downcase == "#{param.downcase}.md" }
    if name.present?
      new(name)
    else
      OpenStruct.new(title: "No title", content: "")
    end
  end

  def initialize(name)
    file = IO.read(Rails.root.join("docs/#{name}"))

    if (md = file.match(/^(?<metadata>---\s*\n.*?\n?)^(---\s*$\n?)/m))
      content = md.post_match
      metadata = YAML.load(md[:metadata])
      title = metadata["title"]
    end

    @content = content || ""
    @title = title || "No title"
    @updated_at =  File.mtime(Rails.root.join("docs/#{name}"))
  end

  def update_date
    updated_at.utc.iso8601
  end

  def cache_key
    ActiveSupport::Cache.expand_cache_key [title, update_date]
  end
end
