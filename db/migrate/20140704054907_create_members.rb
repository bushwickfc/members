class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :first_name, null: false
      t.string :middle_name
      t.string :last_name, null: false
      t.string :email
      t.string :phone
      t.string :phone2
      t.string :fax
      t.string :address
      t.string :address2
      t.string :city, default: "Brooklyn"
      t.string :state, default: "NY"
      t.string :country, default: "US"
      t.string :zip
      t.string :contact_preference, default: "email"
      t.string :gender
      t.string :status
      t.date :join_date
      t.date :work_date
      t.date :date_of_birth
      t.boolean :admin, default: false
      t.boolean :membership_agreement, default: false
      t.boolean :opt_out, default: false
      t.float :monthly_hours, default: 4.0
      t.float :membership_discount, default: 0.0
      t.float :investment_discount, default: 0.0

      t.timestamps
    end

    %w[email work_date join_date admin status opt_out].each do |col|
      add_index :members, col
    end

    add_index :members, [:first_name, :middle_name, :last_name], unique: true

  end
end
