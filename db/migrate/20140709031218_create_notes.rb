class CreateNotes < ActiveRecord::Migration
  def up
    create_table :notes do |t|
      t.belongs_to :member, index: true, null: false
      t.belongs_to :creator, index: true, null: false
      t.string :type, null: false
      t.text :note, null: false

      t.timestamps
    end
    add_index :notes, [:type]
    execute %Q{ ALTER TABLE fees ADD FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE RESTRICT ON UPDATE CASCADE }
    execute %Q{ ALTER TABLE fees ADD FOREIGN KEY (creator_id) REFERENCES members (id) ON DELETE RESTRICT ON UPDATE CASCADE }
  end

  def down
    drop_table :notes
  end
end
