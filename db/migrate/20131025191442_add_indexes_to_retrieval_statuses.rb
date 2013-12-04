class AddIndexesToRetrievalStatuses < ActiveRecord::Migration
  def change

    add_index :retrieval_statuses, [:source_id, :event_count], :order=>{:source_id=>:asc, :event_count=>:desc}, :name => 'index_retrieval_statuses_source_id_event_count_desc'

    add_index :retrieval_statuses, [:source_id, :article_id, :event_count], :order=>{:source_id=>:asc, :article_id=>:asc, :event_count=>:desc}, :name => 'index_retrieval_statuses_source_id_article_id_event_count_desc'

  end
end
