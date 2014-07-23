require "test_helper"

describe Members::ParentalsController do

  let(:parental) { furloughs :john_one_year_parental }

  it "creates parental" do
    assert_difference('parental.member.parentals.count') do
      start = Date.current + 2.month
      finish = start + 1.year
      r = post :create, member_id: parental.member, parental: { 
        member_id: parental.member_id, 
        creator_id: parental.creator_id, 
        type: parental.type, 
        start: start, 
        finish: finish
      }
      #puts r.body
    end

    assert_redirected_to member_parental_path(assigns(:member), assigns(:parental))
  end

  it "shows parental" do
    get :show, id: parental, member_id: parental.member
    assert_response :success
    assert_not_nil assigns(:member)
  end

  it "gets edit" do
    get :edit, id: parental, member_id: parental.member
    assert_not_nil assigns(:member)
    assert_not_nil assigns(:creators)
  end

  it "updates parental" do
    start = Date.current - 2.months
    finish = start + 1.year
    r = put :update, member_id: parental.member, id: parental, parental: { 
      member_id: parental.member_id, 
      creator_id: parental.creator_id, 
      type: parental.type, 
      start: start, 
      finish: finish
    }
    assert_redirected_to member_parental_path(assigns(:member), assigns(:parental))
    #puts r.body
  end

end
