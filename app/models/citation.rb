class Citation < ActiveRecord::Base
  belongs_to :retrieval, :counter_cache => true
  serialize :details

  validates_presence_of :uri

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    # For now, we don't expose details, because details.to_xml
    # seems problematic...
    xml.tag!("citation", :uri => uri)
  end

  def to_included_json
    {
      :uri => uri,
      :details => details,
    }
  end
end
