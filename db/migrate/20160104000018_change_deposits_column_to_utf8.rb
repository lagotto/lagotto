class ChangeDepositsColumnToUtf8 < ActiveRecord::Migration
  UTF8_LONGTEXT_PAIRS = [
    'deposits' , 'message',
    'works', 'csl'
  ]

  UTF8_INDEX_PAIRS = [
    'publishers', 'title',
    'contributors', 'family_name',
    'contributors', 'given_names',
  ]

  def self.up
    execute "ALTER DATABASE `#{ActiveRecord::Base.connection.current_database}` CHARACTER SET utf8mb4;"

    ActiveRecord::Base.connection.tables.each do |table|
      execute "ALTER TABLE `#{table}` CHARACTER SET = utf8mb4;"
    end

    UTF8_LONGTEXT_PAIRS.each_slice(2) do |table, col|
      execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    end

    UTF8_INDEX_PAIRS.each_slice(2) do |table, col|
      execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    end

    remove_index :works, name: 'index_works_on_pid'
    add_index "works", ["pid"], name: "index_works_on_pid", unique: true, length: {"pid"=>191}, using: :btree
  end

  def self.down
    execute "ALTER DATABASE `#{ActiveRecord::Base.connection.current_database}` CHARACTER SET utf8;"

    ActiveRecord::Base.connection.tables.each do |table|
      execute "ALTER TABLE `#{table}` CHARACTER SET = utf8;"
    end

    UTF8_LONGTEXT_PAIRS.each_slice(2) do |table, col|
      execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` LONGTEXT CHARACTER SET utf8 COLLATE utf8_unicode_ci;;"
    end

    UTF8_INDEX_PAIRS.each_slice(2) do |table, col|
      execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    end

    remove_index :works, name: 'index_works_on_pid'
    add_index "works", ["pid"], name: "index_works_on_pid", unique: true, length: {"pid"=>200}, using: :btree
  end
end
