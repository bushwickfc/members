class UpdateMemberStatus
  include Sidekiq::Worker
  sidekiq_options queue: :members, retry: true, backtrace: true, failures: true 

  def perform(member_id = nil)
    if member_id.nil?
      Member.select(:id).each do |member|
        UpdateMemberStatus.perform_async(member.id)
      end
    else
      member = Member.includes(:holds, :parentals, :fees, :time_banks).find(member_id)
      member.can_shop?
      member.update_status(member.membership_status.status) if member.membership_status.a_member?
    end

  end

end
