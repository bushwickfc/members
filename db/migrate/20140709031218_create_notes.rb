class CreateNotes < ActiveRecord::Migration
  def up
    create_table :notes do |t|
      t.belongs_to :creator, index: true, null: false
      t.integer :commentable_id
      t.string :commentable_type
      t.text :note, null: false

      t.timestamps
    end
    add_index :notes, [:commentable_id, :commentable_type]
    execute %Q{ ALTER TABLE notes ADD FOREIGN KEY (creator_id) REFERENCES members (id) ON DELETE RESTRICT ON UPDATE CASCADE }
  end

  def down
    drop_table :notes
  end
end
