class ChangeUtf8Encoding < ActiveRecord::Migration
  UTF8_PAIRS = {
    'works'  => 'title',
    'alerts' => 'message',
    'alerts' => 'trace',
    'alerts' => 'details'
  }

  def self.up
    # execute "ALTER DATABASE `#{ActiveRecord::Base.connection.current_database}` CHARACTER SET utf8mb4;"

    # ActiveRecord::Base.connection.tables.each do |table|
    #   execute "ALTER TABLE `#{table}` CHARACTER SET = utf8mb4;"
    # end

    UTF8_PAIRS.each do |table, col|
      execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` TEXT  CHARACTER SET utf8mb4  NULL;"
    end

  end

  def self.down
    # execute "ALTER DATABASE `#{ActiveRecord::Base.connection.current_database}` CHARACTER SET utf8;"

    # ActiveRecord::Base.connection.tables.each do |table|
    #   execute "ALTER TABLE `#{table}` CHARACTER SET = utf8;"
    # end

    UTF8_PAIRS.each do |table, col|
      execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` TEXT  CHARACTER SET utf8  NULL;"
    end
  end
end
