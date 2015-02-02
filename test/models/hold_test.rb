require "test_helper"

describe Hold do
  describe "invalidates attribute" do
    subject { Hold.new(member: Member.find_by(admin: true)) }

    %w[inactive canceled suspended].each do |status|
      it "member for status #{status}" do
        subject.member.update_column(:status, status)
        subject.wont_be :valid?
        subject.errors[:member_id].must_equal ["must be able to shop"]
      end
    end

    it "start" do
      subject.finish = subject.start = Date.current
      subject.wont_be :valid?
      subject.errors[:start].must_equal  ["Hold must be at least 1 month"]
    end

    it "member" do
      subject.member.update_column(:work_date, Date.current - 1.year)
      subject.wont_be :valid?
      subject.errors[:member_id].must_equal ["must be able to shop"]
    end
  end
end
