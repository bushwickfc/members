class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :trackable_id
      t.string :trackable_type
      t.string :data, limit: 2048

      t.timestamps
    end
    add_index :events, [:trackable_id, :trackable_type]
  end
end
