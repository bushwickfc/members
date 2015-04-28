class EmailSuspendedMembers
  include Sidekiq::Worker
  sidekiq_options queue: :members, retry: true, backtrace: true, failures: true 

  def perform
    suspended_members = Member.where(:status => "suspended")
    suspended_members.each do |m|
      if m.last_suspended_email.nil? || Date.current.month - m.last_suspended_email.month >= 1
        begin
          AdminMailer.suspended_email(m).deliver
        rescue
          next
        end
        m.last_suspended_email = Date.current
        m.save
      end
    end
  end
end