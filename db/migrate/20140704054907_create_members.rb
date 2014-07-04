class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :phone2
      t.string :fax
      t.string :address
      t.string :address2
      t.string :city
      t.string :state
      t.string :country
      t.string :zip
      t.string :sex
      t.string :status
      t.date :join_date
      t.boolean :admin
      t.boolean :membership_agreement
      t.float :monthly_hours
      t.float :fee_discount
      t.float :investment_discount

      t.timestamps
    end
  end
end
