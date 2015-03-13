class AdminMailer < ActionMailer::Base
  default from: "bfc@bushwickfoodcoop.com"

  def suspended_email(member)
  	@member = member
  	@date = Date.current
  	email_and_name = %("#{@member.first_name}" <#{@member.email}>)
  	mail(to: email_and_name, subject: 'BFC Membership Alert: You are currently suspended')
  end
end
