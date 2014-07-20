require "test_helper"

describe Members::FurloughsController do

  it "gets index" do
    get :index, member_id: @john_one_month_hold.member
    assert_response :success
    assert_not_nil assigns(:furloughs)
    assert_not_nil assigns(:member)
    assigns(:furloughs).count.must_equal 2
  end

end
