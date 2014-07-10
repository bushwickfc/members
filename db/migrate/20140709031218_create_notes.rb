class CreateNotes < ActiveRecord::Migration
  def up
    create_table :notes do |t|
      t.belongs_to :member, index: true
      t.belongs_to :receiver, index: true
      t.text :note

      t.timestamps
    end
    execute %Q{ ALTER TABLE fees ADD FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE RESTRICT ON UPDATE CASCADE }
    execute %Q{ ALTER TABLE fees ADD FOREIGN KEY (receiver_id) REFERENCES members (id) ON DELETE RESTRICT ON UPDATE CASCADE }
  end

  def down
    drop_table :notes
  end
end
