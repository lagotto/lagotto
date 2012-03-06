class CreateWorkers < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.integer :identifier, :null => false
      t.string  :queue, :null => false

      t.timestamps
    end
  end
end
