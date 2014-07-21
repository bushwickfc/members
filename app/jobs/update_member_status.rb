class UpdateMemberStatus
  include Sidekiq::Worker
  sidekiq_options queue: :members, retry: true, backtrace: true, failures: true 

  def perform(member_id = nil)
    if member_id.nil?
      Member.where.not(status: ["suspended", "canceled"]).select(:id) do |member|
        UpdateMemberStatus.perform_async(member.id)
      end
    else
      member = Member.find(member_id)
      member.can_shop?
      member.update_status(member.membership_status.status)
    end

  end

end
