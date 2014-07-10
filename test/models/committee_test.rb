require "test_helper"

describe Committee do
  let(:committee) { Committee.new(member: @john, name: "test") }

  it "must be valid" do
    committee.must_be :valid?
  end

  describe "invalidates attribute" do
    subject { Committee.new }

    it "name" do
      Committee.where(name: "membership").count.must_equal 1
      subject.member = @john
      subject.name = "membership"
      assert_raise(ActiveRecord::RecordNotUnique) do
        subject.save
      end
    end

  end
end
