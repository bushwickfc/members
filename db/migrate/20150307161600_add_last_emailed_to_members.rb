class AddLastEmailedToMembers < ActiveRecord::Migration
  def change
  	add_column :members, :last_suspended_email, :date, :default => nil
  end
end
