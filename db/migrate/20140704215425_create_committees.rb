class CreateCommittees < ActiveRecord::Migration
  def up
    create_table :committees do |t|
      t.belongs_to :member, null: false, index: true
      t.string :name, null: false

      t.timestamps
    end
    add_index :committees, :name, unique: true
    execute %Q{ ALTER TABLE committees ADD FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE RESTRICT ON UPDATE CASCADE }
  end

  def down
    drop_table :committees
  end
end
