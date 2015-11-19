require "test_helper"

describe TimeBank do
  it "must be valid" do
    @john_cashier_approved.must_be :valid?
  end

  describe "invalidates attribute" do
    subject { TimeBank.new }

    it "member_id" do
      subject.member_id = nil
      subject.wont_be :valid?
      subject.errors[:member_id].must_equal ["can't be blank"]
    end

    it "admin_id" do
      subject.admin_id = nil
      subject.wont_be :valid?
      subject.errors[:admin_id].must_equal ["can't be blank"]
    end

    it "start" do
      subject.start = "invalid"
      subject.wont_be :valid?
      subject.errors[:start].must_equal ["can't be blank"]
    end

    it "start too high" do
      subject.start = DateTime.tomorrow
      subject.finish = DateTime.yesterday
      subject.time_type = "greeter"
      subject.wont_be :valid?
      subject.errors[:start].must_equal ["must come before finish"]
    end

    it "finish" do
      subject.finish = "invalid"
      subject.wont_be :valid?
      subject.errors[:finish].must_equal ["can't be blank"]
    end

    it "date_worked not blank" do
      subject.date_worked = ""
      subject.wont_be :valid?
      subject.errors[:date_worked].must_equal ["can't be blank"]
    end

    it "hours_worked not blank" do
      subject.hours_worked = ""
      subject.wont_be :valid?
      subject.errors[:hours_worked].must_include "can't be blank"
    end

    it "hours_worked must be numeric" do
      subject.hours_worked = "the thirty-sixth chamber"
      subject.wont_be :valid?
      subject.errors[:hours_worked].must_include "is not a number"
    end

    it "hours_worked nonzero" do
      subject.hours_worked = 0
      subject.wont_be :valid?
      subject.errors[:hours_worked].must_include "must not be zero"
    end

    it "time_type" do
      subject.time_type = "invalid"
      subject.wont_be :valid?
      subject.errors[:time_type].must_equal ["is not included in the list"]
    end

  end

  describe "virtual attributes getters defaults" do
    subject { TimeBank.new }

    it "returns 'today's date' as default value for date_worked" do
      subject.date_worked.must_equal Date.current
    end

    it "returns '0.0' as default value for hours_worked" do
      subject.hours_worked.must_equal 0.0
    end
  end

  describe "virtual attributes setters" do
    yesterday    = Date.yesterday
    two_days_ago = 2.days.ago
    subject { TimeBank.new({member: @gus, admin_id: @addy.id, date_worked: Date.yesterday, hours_worked: 2.5,
      time_type: "store_shift", approved: true
    }) }

    it "sets date_worked via instantiation" do
      subject.date_worked.must_equal Date.yesterday
    end

    it "sets date_worked via property manipulation" do
      subject.date_worked = two_days_ago
      subject.date_worked.must_equal two_days_ago
    end

    it "sets hours_worked via instantiation" do
      subject.hours_worked.must_equal 2.5
    end

    it "sets hours_worked via property manipulation" do
      subject.hours_worked = 4.25
      subject.hours_worked.must_equal 4.25
    end
  end

  describe "time_type" do
    describe "penalty" do
      subject { TimeBank.new(member: @gus, admin_id: @addy.id, approved: true) }

      it "swaps positive differences in setter" do
        subject.start = DateTime.yesterday
        subject.finish = DateTime.yesterday+4.hours
        subject.time_type = "penalty"
        hours = ((subject.finish - subject.start) /60/60).to_i
        hours.must_equal -4
      end

      it "swaps positive differences in callback" do
        subject.time_type = "penalty"
        subject.start = DateTime.yesterday
        subject.finish = DateTime.yesterday+4.hours
        subject.valid?
        hours = ((subject.finish - subject.start) /60/60).to_i
        hours.must_equal -4
      end

      it "does not swap negative differences" do
        hours = @gus_penalty_negative.hours
        hours.must_equal -4
      end
    end

  end

  it "finds unapproved records" do
    count = TimeBank.where(member: @john).unapproved_only.count
    count.must_equal 1
  end

  it "finds approved records" do
    count = TimeBank.where(member: @john).approved_only.count
    count.must_equal 2
  end

  it "subtracts begin from finish" do
    hours = TimeBank.where(member: @john).hours.collect{|t| t.hours}
    hours.must_equal [4,4,4]
  end

  it "sums difference between finish and begin" do
    hours = TimeBank.where(member: @john).hours_summed.first.hours
    hours.must_equal 12
  end

  it "calculates virtual attribute hours" do
    @john_cashier_approved.send(:read_attribute, :hours).must_be :nil?
    @john_cashier_approved.hours.must_equal 4
  end

  describe "Member::Proxy" do
    it "sums a member's approved hours worked" do
      @john.time_banks.hours_worked.must_equal 8
    end

    describe "#balance" do
      it "calculates the difference between worked and owed" do
        @john.work_date = DateTime.current - 3.months
        @john.time_banks.balance.must_equal -4
      end
      it "calculates the difference between worked and owed" do
        @john.work_date = DateTime.current - 2.months
        @john.time_banks.balance.must_equal 0
      end
      it "calculates the difference between worked and owed" do
        @john.work_date = DateTime.current - 1.months
        @john.time_banks.balance.must_equal 4
      end
    end

    describe "#current?" do
      it "is true if hours owed is 0" do
        @suzy.time_banks.stub(:balance, 0) do
          @suzy.time_banks.current?.must_equal true
        end
      end

      it "is true if hours owed is greater than 0" do
        @suzy.time_banks.stub(:balance, 1) do
          @suzy.time_banks.current?.must_equal true
        end
      end

      it "is false if hours worked is less than hours owed" do
        @suzy.time_banks.stub(:balance, -1) do
          @suzy.time_banks.current?.must_equal false
        end
      end
    end

    describe "#suspended?" do
      it "is false if hours owed is 0" do
        @suzy.time_banks.stub(:balance, 0) do
          @suzy.time_banks.suspended?.must_equal false
        end
      end

      it "is false if hours worked is -4" do
        @suzy.time_banks.stub(:balance, -4) do
          @suzy.time_banks.suspended?.must_equal false
        end
      end

      it "is true if hours owed is lesser than -4" do
        @suzy.time_banks.stub(:balance, -5) do
          @suzy.time_banks.suspended?.must_equal true
        end
      end
    end

    describe "#can_shop?" do
      it "is true if current?" do
        @john.time_banks.stub(:current?, true) do
          @john.time_banks.can_shop?.must_equal true
        end
      end

      it "is true if !current? and !suspended?" do
        @john.time_banks.stub(:suspended?, false, :current?, false) do
          @john.time_banks.can_shop?.must_equal true
        end
      end

      it "is false if !current? and suspended?" do
        @john.time_banks.stub(:current?, false, :suspended?, true) do
          @john.time_banks.can_shop?.must_equal false
        end
      end

    end
  end

  describe "#hours_between" do
    it "returns hours for a range" do
      start = DateTime.current.beginning_of_month
      finish = start.end_of_month
      hours = @john.time_banks.hours_between(start, finish).hours_worked
      hours.must_equal 4.0
    end
  end

  describe "#last_shift" do
    it "finds the last shift worked" do
      @john.time_banks.last_shift.must_equal @john_cashier_approved
    end

    it "performs strftime on the last_shift.start " do
      fmt = "%b %d, %Y"
      expected = DateTime.current.strftime fmt
      @john.time_banks.last_shift(fmt).must_equal expected
    end
  end

end
