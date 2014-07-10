class CreateFees < ActiveRecord::Migration
  def up
    create_table :fees do |t|
      t.belongs_to :member, index: true
      t.belongs_to :receiver, index: true
      t.float :amount, null: false
      t.date :payment_date, null: false
      t.string :payment_type, null: false
      t.string :payment_method, null: false

      t.timestamps
    end

    add_index :fees, :payment_date
    execute %Q{ ALTER TABLE fees ADD FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE RESTRICT ON UPDATE CASCADE }
    execute %Q{ ALTER TABLE fees ADD FOREIGN KEY (receiver_id) REFERENCES members (id) ON DELETE RESTRICT ON UPDATE CASCADE }
  end

  def down
    drop_table :fees
  end
end
