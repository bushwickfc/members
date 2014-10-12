require "test_helper"

describe Event do
  it "must be valid" do
    @john_status_active.must_be :valid?
  end

  describe "#status_change" do
    it "only returns status changes" do
      Event.status_change.count.must_equal 2
    end
  end

  describe "#created_after" do
    it "only finds recently created events" do
      Event.created_after(Date.current.beginning_of_month).count.must_equal 1
    end
  end
end
