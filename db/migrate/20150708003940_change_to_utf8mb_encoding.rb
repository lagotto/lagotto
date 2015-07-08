class ChangeToUtf8mbEncoding < ActiveRecord::Migration
  UTF8_TEXT_PAIRS = [
    'works' , 'title',
    'alerts', 'trace'
  ]

  UTF8_MEDIUMTEXT_PAIRS = [
    'alerts', 'message',
    'alerts', 'details',
    'retrieval_statuses', 'extra'
  ]

  UTF8_INDEX_PAIRS = [
    'alerts', 'class_name',
    'api_requests', 'api_key',
    'data_migrations', 'version',
    'reviews', 'name',
    'sources', 'type',
    'sources', 'name',
    'users', 'email',
    'users', 'reset_password_token',
    'users', 'authentication_token',
    'works', 'doi',
    'works', 'pmid',
    'works', 'pmcid',
    'works', 'wos',
    'works', 'scp',
    'works', 'ark',
    'works', 'arxiv'
  ]

  def self.up
    # execute "ALTER DATABASE `#{ActiveRecord::Base.connection.current_database}` CHARACTER SET utf8mb4;"

    # ActiveRecord::Base.connection.tables.each do |table|
    #   execute "ALTER TABLE `#{table}` CHARACTER SET = utf8mb4;"
    # end

    UTF8_TEXT_PAIRS.each_slice(2) do |table, col|
      execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    end

    UTF8_MEDIUMTEXT_PAIRS.each_slice(2) do |table, col|
      execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` MEDIUMTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    end

    UTF8_INDEX_PAIRS.each_slice(2) do |table, col|
      execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    end

    remove_index :works, name: 'index_works_on_pid'
    add_index "works", ["pid"], name: "index_works_on_pid", unique: true, length: {"pid"=>191}, using: :btree
  end

  def self.down
    # execute "ALTER DATABASE `#{ActiveRecord::Base.connection.current_database}` CHARACTER SET utf8;"

    # ActiveRecord::Base.connection.tables.each do |table|
    #   execute "ALTER TABLE `#{table}` CHARACTER SET = utf8;"
    # end

    UTF8_TEXT_PAIRS.each_slice(2) do |table, col|
      execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` TEXT CHARACTER SET utf8 COLLATE utf8_unicode_ci;;"
    end

    UTF8_MEDIUMTEXT_PAIRS.each_slice(2) do |table, col|
      execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` MEDIUMTEXT CHARACTER SET utf8 COLLATE utf8_unicode_ci;;"
    end

    UTF8_INDEX_PAIRS.each_slice(2) do |table, col|
      execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    end

    remove_index :works, name: 'index_works_on_pid'
    add_index "works", ["pid"], name: "index_works_on_pid", unique: true, length: {"pid"=>200}, using: :btree
  end
end
