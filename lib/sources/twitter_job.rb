require 'source_job'
require 'cgi'

class TwitterJob < SourceJob
  #SOURCE_URL = "http://sfdev03.plos.org:5984/plos-tweetstream/_design/tweets/_view/by_doi?key="
  SOURCE_URL = "http://tws-mia.plos.org:5984/plos-tweetstream/_design/tweets/_view/by_doi?key="

  def perform

    puts "#{source.name} #{doi} perform"
    Rails.logger.debug "#{source.name} #{doi} perform"

    # check to see if source is active and not disabled
    # if disabled, exit
    unless source.active && (source.disable_until.nil? || source.disable_until < DateTime.now.utc)
      puts "#{source.name} #{doi} not active or disabled"
      Rails.logger.debug "#{source.name} #{doi} not active or disabled"

      retrieval_history.status = RetrievalHistory::SKIPPED_MSG

      msg = []
      unless source.active
        msg << RetrievalHistory::SOURCE_NOT_ACTIVE
      end

      unless (source.disable_until.nil? || source.disable_until < DateTime.now.utc)
        msg << RetrievalHistory::SOURCE_DISABLED
      end

      retrieval_history.msg = msg.join(",")

      retrieval_history.save
      return
    end

    puts "#{source.name} #{doi} good"
    Rails.logger.debug "#{source.name} #{doi} good"

    # get the data
    query_url = "#{SOURCE_URL}#{CGI.escape("\"#{doi}\"")}"

    puts "#{query_url}"

    options = {}
    events = []

    json_data = get_json(query_url, options)

    if json_data.length > 0
      results = json_data["rows"]

      results.each do | result |
        tweet = result["value"]

        username = tweet["from_user"]

        if username.nil?
          username = tweet["user"]["screen_name"]
        end

        tweet[:url] = "http://twitter.com/#!/#{username}/status/#{tweet["id_str"]}"
        tweet.delete("_id")
        tweet.delete("_rev")

        events << tweet
      end
    end

    retrieved_at = DateTime.now.utc
    if events.length > 0
      data = {}
      data[:doi] = doi
      data[:updated_at] = retrieved_at
      data[:source] = source.name
      data[:events] = events;

      # save the data to couchdb
      data_rev = save_data(retrieval_status.data_rev, data.clone, "#{source.name}:#{CGI.escape(doi)}")
      retrieval_status.data_rev = data_rev

      # save the data to couchdb as retrieval history data
      save_data(nil, data, retrieval_history.id)

      # set retrieval history status to success
      retrieval_history.status = RetrievalHistory::SUCCESS_MSG
      # save the event count in mysql
      retrieval_history.event_count = events.length

    else
      # if we don't get any data, set retrieval history status to success with no data
      retrieval_history.status = RetrievalHistory::SUCCESS_NODATA_MSG
    end

    retrieval_status.retrieved_at = retrieved_at
    retrieval_history.retrieved_at = retrieved_at

    retrieval_status.save
    retrieval_history.save

    puts "twitter #{doi} done"
    Rails.logger.debug "twitter #{doi} done"

  end

end
