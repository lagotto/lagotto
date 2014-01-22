class AddApiResponsesIndexes < ActiveRecord::Migration
  def change
    add_index :retrieval_statuses, [:source_id, :event_count, :retrieved_at], :order=>{:source_id=>:asc, :event_count=>:desc, :retrieved_at=>:desc}, :name => 'index_retrieval_statuses_source_id_event_count_retrieved_at_desc'

    add_index :api_responses, [:unresolved, :id], :name => 'index_api_responses_unresolved_id'
    add_index :api_responses, [:created_at], :name => 'index_api_responses_created_at'

    add_index :api_requests, [:api_key, :created_at], :order=>{:api_key=>:asc, :created_at=>:desc}, :name => 'index_api_requests_api_key_created_at'
  end
end
