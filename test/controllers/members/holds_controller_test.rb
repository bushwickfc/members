require "test_helper"

describe Members::HoldsController do

  let(:hold) { furloughs :john_one_month_hold }

  it "creates hold" do
    assert_difference('hold.member.holds.count') do
      start = Date.current + 2.month
      finish = start + 1.month
      post :create, member_id: hold.member, hold: { 
        member_id: hold.member_id, 
        creator_id: hold.creator_id, 
        type: hold.type, 
        start: start, 
        finish: finish
      }
    end

    assert_redirected_to member_hold_path(assigns(:member), assigns(:hold))
  end

  it "shows hold" do
    get :show, id: hold, member_id: hold.member
    assert_response :success
    assert_not_nil assigns(:member)
  end

  it "gets edit" do
    get :edit, id: hold, member_id: hold.member
    assert_not_nil assigns(:member)
  end

  it "updates hold" do
    start = Date.current - 2.months
    put :update, member_id: hold.member, id: hold, hold: { 
      member_id: hold.member_id, 
      creator_id: hold.creator_id, 
      type: hold.type, 
      start: start, 
      finish: hold.finish
    }
    assert_redirected_to member_hold_path(assigns(:member), assigns(:hold))
  end

end
