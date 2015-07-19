class AddKeys < ActiveRecord::Migration
  def change
    # remove orphaned rows before adding foreign keys
    execute "delete from retrieval_statuses where work_id not in (select id from works);"

    execute "delete from months where work_id not in (select id from works);"
    execute "delete from months where retrieval_status_id not in (select id from retrieval_statuses);"

    execute "delete from days where work_id not in (select id from works);"
    execute "delete from days where retrieval_status_id not in (select id from retrieval_statuses);"

    execute "delete from relations where work_id not in (select id from works);"
    execute "delete from relations where related_work_id not in (select id from works);"
    execute "delete from relations where relation_type_id not in (select id from relation_types);"

    execute "delete from works where work_tpye_id not in (select id from work_types);"

    add_foreign_key "days", "retrieval_statuses", name: "days_retrieval_status_id_fk", on_delete: :cascade
    add_foreign_key "days", "sources", name: "days_source_id_fk", on_delete: :cascade
    add_foreign_key "days", "works", name: "days_work_id_fk", on_delete: :cascade
    add_foreign_key "months", "retrieval_statuses", name: "months_retrieval_status_id_fk", on_delete: :cascade
    add_foreign_key "months", "sources", name: "months_source_id_fk", on_delete: :cascade
    add_foreign_key "months", "works", name: "months_work_id_fk", on_delete: :cascade
    add_foreign_key "publisher_options", "publishers", primary_key: "member_id", name: "publisher_options_publisher_id_fk", on_delete: :cascade
    add_foreign_key "publisher_options", "sources", name: "publisher_options_source_id_fk", on_delete: :cascade
    add_foreign_key "relations", "works", column: "related_work_id", name: "relations_related_work_id_fk", on_delete: :cascade
    add_foreign_key "relations", "relation_types", name: "relations_relation_type_id_fk", on_delete: :cascade
    add_foreign_key "relations", "sources", name: "relations_source_id_fk", on_delete: :cascade
    add_foreign_key "relations", "works", name: "relations_work_id_fk", on_delete: :cascade
    add_foreign_key "reports_users", "reports", name: "reports_users_report_id_fk", on_delete: :cascade
    add_foreign_key "reports_users", "users", name: "reports_users_user_id_fk", on_delete: :cascade
    add_foreign_key "retrieval_statuses", "sources", name: "retrieval_statuses_source_id_fk", on_delete: :cascade
    add_foreign_key "retrieval_statuses", "works", name: "retrieval_statuses_work_id_fk", on_delete: :cascade
    add_foreign_key "sources", "groups", name: "sources_group_id_fk", on_delete: :cascade
    add_foreign_key "works", "work_types", name: "works_work_type_id_fk", on_delete: :cascade
  end
end
