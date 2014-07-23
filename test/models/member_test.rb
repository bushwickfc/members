require "test_helper"

describe Member do
  it "must be valid" do
    @john.must_be :valid?
  end

  describe "invalidates attribute" do
    subject { @john }

    it "first_name" do
      subject.first_name = nil
      subject.wont_be :valid?
      subject.errors[:first_name].must_equal ["can't be blank"]
    end

    it "last_name" do
      subject.last_name = nil
      subject.wont_be :valid?
      subject.errors[:last_name].must_equal ["can't be blank"]
    end

    it "email require valid email with mx record" do
      subject.email = "a@example.com"
      subject.wont_be :valid?
      subject.errors[:email].must_equal ["is invalid"]
    end

    it "gender" do
      subject.gender = "invalid"
      subject.wont_be :valid?
      subject.errors[:gender].must_equal ["is not included in the list"]
    end

    it "status" do
      subject.status = "invalid"
      subject.wont_be :valid?
      subject.errors[:status].must_equal ["is not included in the list"]
    end

    it "monthly_hours" do
      subject.monthly_hours = 0.0
      subject.wont_be :valid?
      subject.errors[:monthly_hours].must_equal ["must be greater than 0.0"]
    end

    it "membership_discount" do
      subject.membership_discount = -1
      subject.wont_be :valid?
      subject.errors[:membership_discount].must_equal ["must be greater than or equal to 0.0"]
    end

    it "investment_discount" do
      subject.investment_discount = -1
      subject.wont_be :valid?
      subject.errors[:investment_discount].must_equal ["must be greater than or equal to 0.0"]
    end

  end

  [:days, :weeks, :months, :years].each do |gauge|
    # testing short time
    it "determines membership length in #{gauge}, for suzy" do
      result = @suzy.membership_in(gauge)
      case gauge
      when :days    then result.must_equal 35
      when :weeks   then result.must_equal 5
      when :months  then result.must_equal 1
      when :years   then result.must_equal 0
      end
    end

    # testing leap year
    it "determines membership length in #{gauge}, for member2" do
      result = @member2.membership_in(gauge)
      case gauge
      when :days    then result.must_equal 1826
      when :weeks   then result.must_equal 260
      when :months  then result.must_equal 60
      when :years   then result.must_equal 5
      end
    end
  end

  it "computes 0% discount membership rate" do
    @john.membership_rate.must_equal 50.0
  end

  it "computes 50% discount membership rate" do
    @gus.membership_rate.must_equal 25.0
  end

  it "computes 0% discount investment rate" do
    @john.investment_rate.must_equal 25.0
  end

  it "computes 50% discount investment rate" do
    @gus.investment_rate.must_equal 12.5
  end

  it "concatenates the name fields" do
    @john.full_name.must_equal "John J Jingleheimer"
  end

  it "calculates hours owed" do
    @john.hours_owed.must_equal 48
  end

  it 'generates a hashed email' do
    hash = Digest::SHA1.hexdigest @john.email
    @john.optout_hash.must_equal hash
  end

  it 'finds hashed emails' do
    member = Member.by_email_hash(@john.optout_hash)
    member.id.must_equal @john.id
  end

  it 'finds current users who can\'t shop' do
    Member.cached_cant_shop.count.must_equal 2
  end

  it 'finds current users who can shop' do
    Member.cached_can_shop.count.must_equal 7
  end

  it 'finds all notes' do
    @john.all_notes.count.must_equal 5
  end

end
