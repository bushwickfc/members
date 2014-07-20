class UpdateHoldsAndLeaves
  include Sidekiq::Worker
  sidekiq_options queue: :furloughs, retry: true, backtrace: true, failures: true 

  def perform(member_id=nil, start=nil, finish=nil, type=nil)
    if member_id.nil?
      last_month = Date.current-1.month
      start_lmonth = last_month.beginning_of_month
      finish_lmonth = last_month.end_of_month

      holds = Hold.active_between(start_lmonth, finish_lmonth)
      holds.each do |hold|
        UpdateHoldsAndLeaves.perform_async(hold.member_id, start_lmonth.to_s, finish_lmonth.to_s, "hold")
      end

      parentals = Parental.active_between(start_lmonth, finish_lmonth)
      parentals.each do |parental|
        UpdateHoldsAndLeaves.perform_async(parental.member_id, start_lmonth.to_s, finish_lmonth.to_s, "parental")
      end

    else
      member = Member.find(member_id)
      hours = member.time_banks.hours_summed.hours_between(start, finish).hours_worked
      hours = member.monthly_hours - hours
      if hours > 0
        member.time_banks.create!(
          admin: Admin.first,
          approved: false,
          start: start.to_time,
          finish: start.to_time + hours.hours,
          time_type: type.downcase
        )
      end
    end

  end

end
