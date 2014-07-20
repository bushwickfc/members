require "test_helper"

describe Furlough do
  it "must be valid" do
    @john_one_month_hold.must_be :valid?
  end

  describe "invalidates attribute" do
    subject { Furlough.new }

    it "start" do
      subject.start = "invalid"
      subject.wont_be :valid?
      subject.errors[:start].must_equal ["can't be blank"]
    end

    it "finish" do
      subject.start = "finish"
      subject.wont_be :valid?
      subject.errors[:finish].must_equal ["can't be blank"]
    end

    it "type" do
      subject.type = nil
      subject.wont_be :valid?
      subject.errors[:type].must_equal ["can't be blank"]
    end

    it "member_id" do
      subject.member_id = nil
      subject.wont_be :valid?
      subject.errors[:member_id].must_equal ["can't be blank"]
    end

    it "receiver_id" do
      subject.receiver_id = nil
      subject.wont_be :valid?
      subject.errors[:receiver_id].must_equal ["can't be blank"]
    end

  end

  it "rejects overlapping furloughs" do
    @john.furloughs.active.count.must_equal 1
    furlough = @john.furloughs.new(type: "Hold", start: Date.current-1.month, finish: Date.current)
    furlough.wont_be :valid?
    furlough.errors[:start].must_equal ["active during this period"]
  end

  describe "#active_between" do
    it "finds active Holds" do
      start = Date.current.beginning_of_month
      finish = Date.current.end_of_month
      Furlough.hold.active_between(start, finish).count.must_equal 1
    end

    it "finds active Holds in ranges" do
      start = (Date.current-3.months).beginning_of_month
      finish = start.end_of_month
      Furlough.hold.active_between(start, finish).count.must_equal 1
    end

    it "finds active Parentals" do
      start = Date.current.beginning_of_month
      finish = Date.current.end_of_month
      Furlough.parental.active_between(start, finish).count.must_equal 0
    end

  end

  it "finds Holds" do
    Furlough.hold.count.must_equal 2
  end

  it "finds Parentals" do
    Furlough.parental.count.must_equal 1
  end

end
