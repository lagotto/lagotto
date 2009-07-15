class Citation < ActiveRecord::Base
  belongs_to :retrieval, :counter_cache => true
  serialize :details

  validates_presence_of :uri

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    
    xml.tag!("citation", :uri => uri) { 
      details.keys.each { | key | 
        detail = details[key];

        if(detail.is_a?(Array))
            xml.tag!("details") {
              detail.each { | value |
                  xml.tag!(key, value)
              }
            }
        else
          xml.tag!(key, detail)
        end
      }
    }
  end

  def to_included_json
    { :citation => details }
  end
end





