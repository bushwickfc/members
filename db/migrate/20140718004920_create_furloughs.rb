class CreateFurloughs < ActiveRecord::Migration
  def up
    create_table :furloughs do |t|
      t.belongs_to :member, index: true, null: false
      t.belongs_to :creator, index: true, null: false
      t.string :type, null: false
      t.date :start, null: false
      t.date :finish, null: false

      t.timestamps
    end
    add_index :furloughs, [:start, :finish]
    execute %Q{ ALTER TABLE furloughs ADD FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE RESTRICT ON UPDATE CASCADE }
    execute %Q{ ALTER TABLE furloughs ADD FOREIGN KEY (creator_id) REFERENCES members (id) ON DELETE RESTRICT ON UPDATE CASCADE }
  end

  def down
    drop_table :furloughs
  end
end
