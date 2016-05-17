require 'test_helper'

describe Struct::MembershipStatus do
  let(:member_hash) { {
    status: "",
    join_date: Date.parse("2011-08-22"),
    can_shop: false,
    hold: nil,
    membership_fees: true,
    membership_fees_balance: 0.0,
    membership_fees_overdue: false,
    parental: nil,
    time_bank_balance: 1461.25,
    last_shift: "Feb 02, 2015"
  }}

  describe "#messages" do
    it "is an empty array" do
      status = Struct::MembershipStatus.new
      status.messages.must_equal []
    end
  end

  describe "#a_member?" do
    it "is false if join_date is nil" do
      attrs = member_hash.values
      attrs[1] = nil
      status = Struct::MembershipStatus.new(*attrs)
      status.wont_be :a_member?
    end

    it "is false if join_date is empty" do
      attrs = member_hash.values
      attrs[1] = ""
      status = Struct::MembershipStatus.new(*attrs)
      status.wont_be :a_member?
    end

    it "is true otherwise" do
      status = Struct::MembershipStatus.new(*member_hash.values)
      status.must_be :a_member?
    end

  end

  describe "#check_status" do
    it "is false for non-members" do
      status = Struct::MembershipStatus.new(*member_hash.values)
      status.stub(:a_member?, false) do
        status.check_status.must_equal false
      end
    end

    %w[suspended].each do |s|
      it "is false for '#{s}'" do
        attrs = member_hash.values
        attrs[0] = s
        attrs[8] = -16
        status = Struct::MembershipStatus.new(*attrs)
        status.check_status.must_equal false
        status.messages.must_equal ["#{s.capitalize} membership"]
        status.status.must_equal s
      end
    end

    it "is true for unknown statuses" do
      attrs = member_hash.values
      attrs[0] = "invalid"
      status = Struct::MembershipStatus.new(*attrs)
      status.check_status.must_equal true
      status.messages.must_equal ["Unknown status 'invalid'"]
      status.status.must_equal "invalid"
    end

    it "is true for hold without date" do
      attrs = member_hash.values
      attrs[0] = "hold"
      attrs[3] = nil
      status = Struct::MembershipStatus.new(*attrs)
      status.check_status.must_equal true
      status.messages.must_equal []
      status.status.must_equal "active"
    end

    it "is false for hold with date" do
      attrs = member_hash.values
      attrs[0] = "hold"
      attrs[3] = Date.current
      status = Struct::MembershipStatus.new(*attrs)
      status.check_status.must_equal false
      status.messages.must_equal ["On hold until #{Date.current}"]
      status.status.must_equal "hold"
    end

    it "is false for hold date" do
      attrs = member_hash.values
      attrs[0] = nil
      attrs[3] = Date.current
      status = Struct::MembershipStatus.new(*attrs)
      status.check_status.must_equal false
      status.messages.must_equal ["On hold until #{Date.current}"]
      status.status.must_equal "hold"
    end

    it "is true for parental without date" do
      attrs = member_hash.values
      attrs[0] = "parental"
      attrs[7] = nil
      status = Struct::MembershipStatus.new(*attrs)
      status.check_status.must_equal true
      status.messages.must_equal []
      status.status.must_equal "active"
    end

    it "is true for parental with date" do
      attrs = member_hash.values
      attrs[0] = "parental"
      attrs[7] = Date.current
      status = Struct::MembershipStatus.new(*attrs)
      status.check_status.must_equal true
      status.messages.must_equal ["On parental leave until #{Date.current}"]
      status.status.must_equal "parental"
    end

    it "is true for parental date" do
      attrs = member_hash.values
      attrs[0] = nil
      attrs[7] = Date.current
      status = Struct::MembershipStatus.new(*attrs)
      status.check_status.must_equal true
      status.messages.must_equal ["On parental leave until #{Date.current}"]
      status.status.must_equal "parental"
    end

    ["active", "", nil].each do |s|
      it "is true for '#{s}'" do
        attrs = member_hash.values
        attrs[0] = s
        status = Struct::MembershipStatus.new(*attrs)
        status.check_status.must_equal true
        status.messages.must_equal []
        status.status.must_equal "active"
      end
    end

  end

  describe "#check_membership_fees" do
    it "is false for non-members" do
      status = Struct::MembershipStatus.new(*member_hash.values)
      status.stub(:a_member?, false) do
        status.check_membership_fees.must_equal false
      end
    end

    it "is false if membership_fees_overdue" do
      attrs = member_hash.values
      attrs[5] = 1.0
      attrs[6] = true
      status = Struct::MembershipStatus.new(*attrs)
      status.check_membership_fees.must_equal false
      status.messages.must_equal ["Membership fees not paid in 2 months, balance $1.00"]
      status.status.must_equal "suspended"
    end

    it "is true if membership_fees_balance" do
      attrs = member_hash.values
      attrs[5] = 1.0
      status = Struct::MembershipStatus.new(*attrs)
      status.check_membership_fees.must_equal true
      status.messages.must_equal ["Still owes fees ($1.00)"]
      status.status.must_equal ""
    end

    it "is true otherwise" do
      status = Struct::MembershipStatus.new(*member_hash.values)
      status.check_membership_fees.must_equal true
      status.messages.must_equal []
      status.status.must_equal ""
    end

  end

  describe "#check_hours" do
    it "is false for non-members" do
      status = Struct::MembershipStatus.new(*member_hash.values)
      status.stub(:a_member?, false) do
        status.check_hours.must_equal false
      end
    end

    it "is true for balances <= -8.25" do
      attrs = member_hash.values
      attrs[8] = -8.25
      status = Struct::MembershipStatus.new(*attrs)
      status.check_hours.must_equal false
      status.messages.must_equal ["Suspended, owes 8.25 hours", "Last shift Feb 02, 2015"]
      status.status.must_equal "suspended"
    end

    it "is true for balances < 0" do
      attrs = member_hash.values
      attrs[8] = -7
      status = Struct::MembershipStatus.new(*attrs)
      status.check_hours.must_equal true
      status.messages.must_equal ["Work alert, owes 7 hours", "Last shift Feb 02, 2015"]
      status.status.must_equal "work_alert"
    end

    it "is true for balances > 0" do
      attrs = member_hash.values
      attrs[8] = 7
      status = Struct::MembershipStatus.new(*attrs)
      status.check_hours.must_equal true
      status.messages.must_equal ["Banked 7 hours", "Last shift Feb 02, 2015"]
      status.status.must_equal ""
    end

  end

  describe "#can_shop?" do
    it "is true, if everything is true" do
      status = Struct::MembershipStatus.new(*member_hash.values)
      status.stub :check_status, true do
        status.stub :check_membership_fees, true do
          status.stub :check_hours, true do
            status.must_be :can_shop?
            status.status.must_equal "active"
            status.messages.must_equal ["Member in good standing"]
          end
        end
      end
    end

    it "is false, if check_status is false" do
      status = Struct::MembershipStatus.new(*member_hash.values)
      status.stub :check_status, false do
        status.stub :check_membership_fees, true do
          status.stub :check_hours, true do
            status.wont_be :can_shop?
            status.status.must_equal ""
            status.messages.must_equal []
          end
        end
      end
    end

    it "is false, if check_membership_fees is false" do
      status = Struct::MembershipStatus.new(*member_hash.values)
      status.stub :check_status, true do
        status.stub :check_membership_fees, false do
          status.stub :check_hours, true do
            status.wont_be :can_shop?
            status.status.must_equal ""
            status.messages.must_equal []
          end
        end
      end
    end

    it "is false, if check_hours is false" do
      status = Struct::MembershipStatus.new(*member_hash.values)
      status.stub :check_status, true do
        status.stub :check_membership_fees, true do
          status.stub :check_hours, false do
            status.wont_be :can_shop?
            status.status.must_equal ""
            status.messages.must_equal []
          end
        end
      end
    end

    it "is true, if member is in work_alert" do
      attrs = member_hash.values
      attrs[8] = -6
      status = Struct::MembershipStatus.new(*attrs)
      status.must_be :can_shop?
      status.status.must_equal "work_alert"
      status.messages.must_equal ["Work alert, owes 6 hours", "Last shift Feb 02, 2015", "Member in good standing"]
    end

  end
end
