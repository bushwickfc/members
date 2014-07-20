require "test_helper"

describe Hold do
  describe "invalidates attribute" do
    subject { Hold.new }

    it "start" do
      subject.finish = subject.start = Date.current
      subject.wont_be :valid?
      subject.errors[:start] = ["Hold must be at least 1 month"]
    end
  end
end
