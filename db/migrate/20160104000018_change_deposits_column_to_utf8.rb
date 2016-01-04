class ChangeDepositsColumnToUtf8 < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `deposits` CHANGE `message` `message` LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    execute "ALTER TABLE `works` CHANGE `csl` `csl` LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    execute "ALTER TABLE `publishers` CHANGE `title` `title` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  end

  def self.down
    execute "ALTER TABLE `deposits` CHANGE `message` `message` LONGTEXT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    execute "ALTER TABLE `works` CHANGE `csl` `csl` LONGTEXT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    execute "ALTER TABLE `publishers` CHANGE `title` `title` VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
  end
end
