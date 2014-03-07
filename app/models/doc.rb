class Doc

  attr_reader :title, :content

  def self.all
    Dir.entries(Rails.root.join("docs"))
  end

  def self.find(param)
    name = all.detect { |doc| doc == "#{param}.md" } || raise(ActiveRecord::RecordNotFound)
    self.new(name)
  end

  def initialize(name)
    file = IO.read(Rails.root.join("docs/#{name}"))

    if (md = file.match(/^(?<metadata>---\s*\n.*?\n?)^(---\s*$\n?)/m))
      content = md.post_match
      metadata = YAML.load(md[:metadata])
    end

    @content = content || "No content"
    @title = metadata["title"] || "No title"
  end
end