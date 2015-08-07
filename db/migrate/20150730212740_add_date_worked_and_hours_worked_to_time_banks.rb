class AddDateWorkedAndHoursWorkedToTimeBanks < ActiveRecord::Migration
  def change
    add_column :time_banks, :date_worked, :datetime, :null => false, :after => :finish
    add_column :time_banks, :hours_worked, :decimal, :precision => 4, :scale => 2, :null => false, :default => 0, :after => :date_worked

    add_index :time_banks, :date_worked
  end
end
