require "test_helper"

describe Parental do
  it "must be valid" do
    @john_one_year_parental.must_be :valid?
  end

  describe "invalidates attribute" do
    subject { Parental.new }

    it "start" do
      subject.finish = subject.start = Date.current
      subject.wont_be :valid?
      subject.errors[:start].must_equal ["Hold must be at least 1 year"]
    end
  end
end
