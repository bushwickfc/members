require 'test_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

describe EmailSuspendedMembers do

  it "queues the job" do
    EmailSuspendedMembers.perform_async()
    assert_equal EmailSuspendedMembers.jobs.size, 1
  end 
  it "runs the job" do
    m = Member.first
    worker = EmailSuspendedMembers.new
    worker.perform()
    assert_equal Date.current, m.last_suspended_email
  end
  
end

