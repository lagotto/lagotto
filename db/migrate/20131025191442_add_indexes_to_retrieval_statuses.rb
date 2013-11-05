class AddIndexesToRetrievalStatuses < ActiveRecord::Migration
  def change

    #Warning, on a table with 77m records, this will takes at least 20 minutes to add!
    #CREATE INDEX index_retrieval_statuses_source_id_event_count_desc ON `retrieval_statuses` (`source_id` ASC, event_count DESC);
    add_index :retrieval_statuses, [:source_id, :event_count], :order=>{:source_id=>:asc, :event_count=>:desc}, :name => 'index_retrieval_statuses_source_id_event_count_desc'


    #Warning, on a table with 77m records, this will takes at least 20 minutes to add!
    #CREATE INDEX index_retrieval_statuses_source_id_article_id_event_count_desc ON `retrieval_statuses` (`source_id` ASC, article_id ASC, event_count DESC);
    add_index :retrieval_statuses, [:source_id, :article_id, :event_count], :order=>{:source_id=>:asc, :article_id=>:asc, :event_count=>:desc}, :name => 'index_retrieval_statuses_source_id_article_id_event_count_desc'

  end
end
