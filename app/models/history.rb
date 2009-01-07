class History < ActiveRecord::Base
  belongs_to :retrieval

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.tag!("history", :year => year, :month => month, :count => citations_count)
  end

  def to_included_json
    {
      :year => year, 
      :month => month, 
      :count => citations_count,
    }
  end
end
