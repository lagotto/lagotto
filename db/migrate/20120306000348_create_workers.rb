class CreateWorkers < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.integer :identifier, :null => false  # identifier given to the worker when it was started
      t.string  :queue, :null => false       # name of the queue the worker is associated with.

      t.timestamps
    end
  end
end
