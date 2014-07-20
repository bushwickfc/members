class CreateFurloughs < ActiveRecord::Migration
  def up
    create_table :furloughs do |t|
      t.belongs_to :member, index: true
      t.belongs_to :receiver, index: true
      t.string :type, null: false
      t.date :start, null: false
      t.date :finish, null: false

      t.timestamps
    end
    add_index :furloughs, [:start, :finish]
    execute %Q{ ALTER TABLE furloughs ADD FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE RESTRICT ON UPDATE CASCADE }
    execute %Q{ ALTER TABLE furloughs ADD FOREIGN KEY (receiver_id) REFERENCES members (id) ON DELETE RESTRICT ON UPDATE CASCADE }
  end

  def down
    drop_table :furloughs
  end
end
