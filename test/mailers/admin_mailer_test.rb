require "test_helper"

describe AdminMailer do
  
  it "sends a correct suspended email" do
  	email = AdminMailer.suspended_email(@john)
  	assert_equal @john.email, email.to[0]
  	assert_equal 'BFC Membership Alert: You are currently suspended', email.subject
  end


end
