require "test_helper"

describe Members::FeesController do

  let(:fee) { fees :fee1 }

  it "gets index" do
    get :index, member_id: fee.member
    assert_response :success
    assert_not_nil assigns(:fees)
    assert_not_nil assigns(:member)
  end

  it "gets new" do
    get :new, member_id: fee.member
    assert_response :success
    assert_not_nil assigns(:member)
    assert_not_nil assigns(:payment_methods)
    assert_not_nil assigns(:payment_types)
    assert_not_nil assigns(:receivers)
  end

  it "creates fee" do
    @fee = fee
    assert_difference('fee.member.fees.count') do
      post :create, member_id: @fee.member, fee: { receiver_id: @fee.receiver_id, amount: @fee.amount, member_id: @fee.member_id, payment_date: @fee.payment_date, payment_method: @fee.payment_method, payment_type: @fee.payment_type }
    end

    assert_redirected_to member_fee_path(assigns(:member), assigns(:fee))
  end

  it "shows fee" do
    get :show, id: fee, member_id: fee.member
    assert_response :success
    assert_not_nil assigns(:member)
  end

  it "gets edit" do
    get :edit, id: fee, member_id: fee.member
    assert_not_nil assigns(:member)
    assert_not_nil assigns(:payment_methods)
    assert_not_nil assigns(:payment_types)
    assert_not_nil assigns(:receivers)
  end

  it "updates fee" do
    @fee = fee
    put :update, member_id: @fee.member, id: fee, fee: { receiver_id: @fee.receiver_id, amount: @fee.amount, member_id: @fee.member_id, payment_date: @fee.payment_date, payment_method: @fee.payment_method, payment_type: @fee.payment_type }
    assert_redirected_to member_fee_path(assigns(:member), assigns(:fee))
  end

  it "destroys fee" do
    member = fee.member
    assert_difference('Fee.count', -1) do
      delete :destroy, id: fee, member_id: fee.member
    end

    assert_redirected_to member_fees_path(member)
  end

end
