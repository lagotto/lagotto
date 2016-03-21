class ArticleCoverage < Agent
  # include common methods for Article Coverage
  include Coverable

  def parse_data(result, options = {})
    return [result] if result[:error]
    work = Work.where(id: options[:work_id]).first
    return [{ error: "Resource not found.", status: 404 }] unless work.present?

    if !result.is_a?(Hash)
      # make sure we have a hash
      result = { 'data' => result }
      result.extend Hashie::Extensions::DeepFetch
    elsif result[:status] == 404
      # properly handle not found errors
      result = { 'data' => [] }
      result.extend Hashie::Extensions::DeepFetch
    elsif result[:error]
      # return early if an error occured that is not a not_found error
      return [result]
    end

    total = Array(result['referrals']).length

    relations = []
    if total > 0
      relations << { prefix: "10.1371",
                     relation: { "subj_id" => "https://www.plos.org",
                                 "obj_id" => work.pid,
                                 "relation_type_id" => "discusses",
                                 "total" => total,
                                 "source_id" => source_id },
                     subj: { "pid" => "https://www.plos.org",
                             "URL" => "https://www.plos.org",
                             "title" => "PLOS",
                             "type" => "webpage",
                             "issued" => "2012-05-15T16:40:23Z" }}
    end

    relations
  end
end
