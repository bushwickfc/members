require "test_helper"

describe Fee do

  let(:admin) { members :addy }
  let(:fee) { Fee.new(
      member_id: admin.id, 
      creator_id: admin.id, 
      amount: 10.0,
      payment_date: '2014-07-04',
      payment_method: 'cash',
      payment_type: 'membership'
    )
  }

  it "must be valid" do
    fee.must_be :valid?
  end

  describe "validates attribute" do

    %w[cash check money_order debit].each do |value|
      it "payment_method #{value}" do
        fee.payment_method = value
        fee.must_be :valid?
      end
    end

    %w[membership annual].each do |value|
      it "payment_type #{value}" do
        fee.payment_type = value
        fee.must_be :valid?
      end
    end

  end

  describe "invalidates attribute" do
    subject { Fee.new }

    it "payment_type" do
      subject.payment_type = "invalid"
      subject.wont_be :valid?
      subject.errors[:payment_type].must_equal ["is not included in the list"]
    end

    it "payment_method" do
      subject.payment_method = "invalid"
      subject.wont_be :valid?
      subject.errors[:payment_method].must_equal ["is not included in the list"]
    end

    it "payment_date" do
      subject.payment_date = "invalid"
      subject.wont_be :valid?
      subject.errors[:payment_date].must_equal ["can't be blank"]
    end

    it "amount" do
      subject.amount = -1
      subject.wont_be :valid?
      subject.errors[:amount].must_equal ["must be greater than 0.0"]
    end

    it "member_id" do
      subject.member_id = nil
      subject.wont_be :valid?
      subject.errors[:member_id].must_equal ["can't be blank"]
    end

    it "creator_id" do
      subject.creator_id = nil
      subject.wont_be :valid?
      subject.errors[:creator_id].must_equal ["can't be blank"]
    end

  end

  it "computes total membership fees" do
    @suzy.fees.membership_payment_total.must_equal 50.0
  end

  describe "paid in full" do
    it "calculates lump sum payments" do
      @john.fees.where(payment_type: "membership").count.must_equal 1
      @john.fees.membership_paid_full?.must_equal true
    end

    it "calculates incremental payments" do
      @suzy.fees.where(payment_type: "membership").count.must_equal 5
      @suzy.fees.membership_paid_full?.must_equal true
    end
  end

  describe "incremental payments, on time" do
    it "calculates incremental payments" do
      @morton.fees.where(payment_type: "membership").count.must_equal 3
      @morton.fees.membership_paid_incrementally?.must_equal true
    end
  end

  describe "incremental payments, tardy" do
    it "calculates incremental payments" do
      @gus.membership_discount.must_equal 50.0
      @gus.fees.where(payment_type: "membership").count.must_equal 2
      @gus.fees.membership_paid_incrementally?.must_equal false
    end
  end

  describe "incremental payments, suspend" do
    it "is true for delinquent users" do
      @gus.join_date = Date.current - 10.weeks
      @gus.fees.membership_payment_overdue?.must_equal true
    end

    it "is false for paid users" do
      @john.fees.membership_payment_overdue?.must_equal false
    end
  end

  describe "membership paid" do
    it "is true for john" do
      @john.fees.membership_paid?.must_equal true
    end
    it "is true for suzy" do
      @suzy.fees.membership_paid?.must_equal true
    end
    it "is false for gus" do
      @gus.fees.membership_paid?.must_equal false
    end
  end

  describe "#membership_balance" do
    it "is 0 for john" do
      @john.fees.membership_balance.must_equal 0
    end

    it "is 0 for suzy" do
      @suzy.fees.membership_balance.must_equal 0
    end

    it "is 15 for gus" do
      @gus.fees.membership_balance.must_equal 15
    end

  end

end
