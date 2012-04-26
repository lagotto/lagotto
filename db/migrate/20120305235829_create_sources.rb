class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string   :type,           :null => false                    # for single table inheritance
      t.string   :name,           :null => false                    # name of the source (used as a key)
      t.string   :display_name,   :null => false                    # display name of the source
      t.boolean  :active,         :default => false                 # determine if the source is active or not
      t.datetime :disable_until                                     # the source will be disabled until this date time
      t.integer  :disable_delay,  :default => 10, :null => false    # how long a source should be disabled, in seconds
      t.integer  :timeout,        :default => 30, :null => false    # timeout value for http call out to the source
      t.integer  :workers,        :null => false                    # number of workers for the source queue
      t.text     :config                                            # source specific configurations
      t.integer  :group_id                                          # group id (from groups table)

      t.timestamps
    end

    add_index :sources, :type, :unique => true
    add_index :sources, :name, :unique => true
  end
end
