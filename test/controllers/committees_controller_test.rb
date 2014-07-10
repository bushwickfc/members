require "test_helper"

describe CommitteesController do

  let(:committee) { committees :membership }

  it "gets index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:committees)
    assert_nil assigns(:member)
  end

  it "gets index for member" do
    get :index, member_id: @john
    assert_response :success
    assert_not_nil assigns(:committees)
    assert_not_nil assigns(:member)
  end

  it "gets new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:committee)
    assert_not_nil assigns(:members)
  end

  it "creates committee" do
    assert_difference('Committee.count') do
      post :create, committee: { member_id: @john, name: "test" }
    end

    assert_redirected_to committee_path(assigns(:committee))
  end

  it "shows committee" do
    get :show, id: committee
    assert_response :success
    assert_not_nil assigns(:committee)
  end

  it "gets edit" do
    get :edit, id: committee
    assert_response :success
    assert_not_nil assigns(:committee)
    assert_not_nil assigns(:members)
  end

  it "updates committee" do
    put :update, id: committee, committee: { member_id: @membership.member_id, name: @membership.name }
    assert_redirected_to committee_path(assigns(:committee))
  end

  it "destroys committee" do
    assert_difference('Committee.count', -1) do
      delete :destroy, id: committee
    end

    assert_redirected_to committees_path
  end

end
