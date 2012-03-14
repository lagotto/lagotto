class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string   :type
      t.string   :name,           :null => false                    # name of the source
      t.string   :display_name,   :null => false                    # display name of the source
      t.boolean  :active,         :default => false                 # determine if the source is active or not
      t.datetime :disable_until                                     #
      t.integer  :disable_delay,  :default => 10, :null => false    # how long a source should be disabled, in seconds
      t.integer  :timeout,        :default => 30, :null => false    # timeout value for http call to the source
      t.integer  :workers,        :null => false                    # number of workers for the source queue

      t.timestamps
    end

    add_index :sources, :type, :unique => true
    add_index :sources, :name, :unique => true
  end
end
