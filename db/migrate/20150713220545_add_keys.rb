class AddKeys < ActiveRecord::Migration
  def change
    # remove orphaned rows before adding foreign keys
    execute "delete from events where work_id not in (select id from works);"

    execute "delete from months where work_id not in (select id from works);"
    execute "delete from months where event_id not in (select id from events);"

    execute "delete from days where work_id not in (select id from works);"
    execute "delete from days where event_id not in (select id from events);"

    execute "delete from relations where work_id not in (select id from works);"
    execute "delete from relations where related_work_id not in (select id from works);"
    execute "delete from relations where relation_type_id not in (select id from relation_types);"

    execute "delete from works where work_type_id not in (select id from work_types);"

    execute "delete from reports_users where user_id not in (select id from users);"
    execute "delete from reports_users where report_id not in (select id from reports);"

    add_foreign_key "days", "events", name: "days_event_id_fk", on_delete: :cascade
    add_foreign_key "days", "sources", name: "days_source_id_fk", on_delete: :cascade
    add_foreign_key "days", "works", name: "days_work_id_fk", on_delete: :cascade
    add_foreign_key "months", "events", name: "months_event_id_fk", on_delete: :cascade
    add_foreign_key "months", "sources", name: "months_source_id_fk", on_delete: :cascade
    add_foreign_key "months", "works", name: "months_work_id_fk", on_delete: :cascade
    add_foreign_key "publisher_options", "publishers", primary_key: "member_id", name: "publisher_options_publisher_id_fk", on_delete: :cascade
    add_foreign_key "publisher_options", "agents", name: "publisher_options_agent_id_fk", on_delete: :cascade
    add_foreign_key "relations", "works", column: "related_work_id", name: "relations_related_work_id_fk", on_delete: :cascade
    add_foreign_key "relations", "relation_types", name: "relations_relation_type_id_fk", on_delete: :cascade
    add_foreign_key "relations", "sources", name: "relations_source_id_fk", on_delete: :cascade
    add_foreign_key "relations", "works", name: "relations_work_id_fk", on_delete: :cascade
    add_foreign_key "reports_users", "reports", name: "reports_users_report_id_fk", on_delete: :cascade
    add_foreign_key "reports_users", "users", name: "reports_users_user_id_fk", on_delete: :cascade
    add_foreign_key "events", "sources", name: "events_source_id_fk", on_delete: :cascade
    add_foreign_key "events", "works", name: "events_work_id_fk", on_delete: :cascade
    add_foreign_key "sources", "groups", name: "sources_group_id_fk", on_delete: :cascade
    add_foreign_key "works", "work_types", name: "works_work_type_id_fk", on_delete: :cascade
  end
end
