class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :first_name, null: false
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
      t.float :annual_discount, default: 0.0

      ## Database authenticatable
      #t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      t.timestamps
    end

    %w[email work_date join_date admin status opt_out].each do |col|
      add_index :members, col
    end
    add_index :members, :reset_password_token, unique: true

    add_index :members, [:first_name, :last_name], unique: true

  end
end
