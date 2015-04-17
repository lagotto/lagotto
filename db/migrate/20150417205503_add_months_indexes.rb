class AddMonthsIndexes < ActiveRecord::Migration
  def up
    add_index "months", ["source_id", "year", "month"], name: "index_months_on_source_id_and_year_and_month"
    add_index "months", ["retrieval_status_id", "year", "month"], name: "index_months_on_retrieval_status_id_and_year_and_month"
    add_index "days", ["retrieval_status_id", "year", "month", "day"], name: "index_days_on_retrieval_status_id_and_year_and_month_and_day"
    add_index "relationships", ["work_id", "related_work_id"], name: "index_relationships_on_work_id_related_work_id"
  end

  def down
    remove_index "months", name: "index_months_on_source_id_and_year_and_month"
    remove_index "months", name: "index_months_on_retrieval_status_id_and_year_and_month"
    remove_index "days", name: "index_days_on_retrieval_status_id_and_year_and_month_and_day"
    remove_index "relationships", name: "index_relationships_on_work_id_related_work_id"
  end
end
