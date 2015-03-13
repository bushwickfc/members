require "test_helper"

describe AdminMailer do
  subject { create :member }
  
  it "sends a correct suspended email" do
  	email = AdminMailer.suspended_email(subject)
  	email_and_name = %("#{subject.first_name}" <#{subject.email}>)
  	assert_equal email_and_name, email.to
  	assert_equal 'BFC Membership Alert: You are currently suspended', subject.subject
  end
end
