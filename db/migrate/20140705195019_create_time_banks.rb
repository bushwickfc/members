class CreateTimeBanks < ActiveRecord::Migration
  def change
    create_table :time_banks do |t|
      t.belongs_to :member, index: true
      t.belongs_to :admin, index: true
      t.belongs_to :committee, index: true
      t.datetime :start, null: false
      t.datetime :finish, null: false
      t.string :time_type, null: false
      t.boolean :approved, default: false, index: true

      t.timestamps
    end

    add_index :time_banks, [:start, :finish]
    execute %Q{ ALTER TABLE time_banks ADD FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE RESTRICT ON UPDATE CASCADE }
    execute %Q{ ALTER TABLE time_banks ADD FOREIGN KEY (admin_id) REFERENCES members (id) ON DELETE RESTRICT ON UPDATE CASCADE }
    execute %Q{ ALTER TABLE time_banks ADD FOREIGN KEY (committee_id) REFERENCES committees (id) ON DELETE RESTRICT ON UPDATE CASCADE }
  end

  def down
    drop_table :time_banks
  end
end
