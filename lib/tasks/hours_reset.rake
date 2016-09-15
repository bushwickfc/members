namespace :hours do
  task :reset => :environment do
    Member.all.each do |member|
      diff = member.time_bank.hours_difference
      date = Time.now
      format = "%F"
      while diff < 0
        change = 0
        if diff < -23
          change = 23
          diff = diff + change
        else
          change = -diff
          diff = 0
        end
        tb = { "date_worked"=> date.strftime(format),
               "hours_worked"=> change }
        member.time_banks.new(tb)
        date = date - 86400
      end
    end
  end
end
