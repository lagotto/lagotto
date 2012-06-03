class RetrievalHistory < ActiveRecord::Base
  belongs_to :retrieval_status

  SUCCESS_MSG = "SUCCESS"
  SUCCESS_NODATA_MSG = "SUCCESS WITH NO DATA"
  ERROR_MSG = "ERROR"
  ERROR_TIMEOUT_MSG = "ERROR WITH TIMEOUT"
  ERROR_RESPONSE_MSG = "ERROR IN RESPONSE"
  SKIPPED_MSG = "SKIPPED"
  SOURCE_DISABLED = "Source disabled"
  SOURCE_NOT_ACTIVE = "Source not active"

  def as_json
    {
        :updated_at => (retrieved_at.nil? ? nil: retrieved_at.to_time),
        :count => event_count
    }
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.tag!("history", :updated_at => (retrieved_at.nil? ? nil: retrieved_at.to_time), :count => event_count)
  end

end
