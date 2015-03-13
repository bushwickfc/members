class EmailSuspendedMembers
	include Sidekiq::Worker
	 sidekiq_options queue: :members, retry: true, backtrace: true, failures: true 

	 def perform
	 	suspended_members = Member.find_by_status("suspended")
	 	suspended_members.each do |m|
	 		if m.last_emailed and Date.current.month - m.last_emailed.month >= 1
	 			AdminMailer.suspended_email(m).deliver_now
		    	rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
		    		next
				end
				m.last_emailed = Date.current
	 		end
	 	end
	 end
	 
end