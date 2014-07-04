require "test_helper"

describe Member do
  let(:member) { Member.new }

  it "must be valid" do
    member.must_be :valid?
  end
end
