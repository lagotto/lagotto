class RenameCountColumns < ActiveRecord::Migration
  def change
    rename_column :days, :total_count, :total
    rename_column :days, :html_count, :html
    rename_column :days, :pdf_count, :pdf
    rename_column :days, :comments_count, :comments
    rename_column :days, :likes_count, :likes
    add_column :days, :readers, :integer

    rename_column :months, :total_count, :total
    rename_column :months, :html_count, :html
    rename_column :months, :pdf_count, :pdf
    rename_column :months, :comments_count, :comments
    rename_column :months, :likes_count, :likes
    add_column :months, :readers, :integer

    rename_column :retrieval_statuses, :event_count, :total
    add_column :retrieval_statuses, :pdf, :integer
    add_column :retrieval_statuses, :html, :integer
    add_column :retrieval_statuses, :readers, :integer
    add_column :retrieval_statuses, :comments, :integer
    add_column :retrieval_statuses, :likes, :integer

    rename_column :api_responses, :event_count, :total
    rename_column :api_responses, :previous_count, :previous_total
    add_column :api_responses, :html, :integer
    add_column :api_responses, :pdf, :integer
  end
end
