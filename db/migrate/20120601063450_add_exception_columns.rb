class AddExceptionColumns < ActiveRecord::Migration
  def up
    add_column :retrieval_histories, :request, :text
    add_column :retrieval_histories, :response, :text
    add_column :retrieval_histories, :backtrace, :text
  end

  def down
    remove_column :retrieval_histories, :request
    remove_column :retrieval_histories, :reponse
    remove_column :retrieval_histories, :backtrace
  end
end
