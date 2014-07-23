require "test_helper"

describe FeesController do

  let(:fee) { fees :fee1 }

  it "gets index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fees)
  end

  it "gets new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:members)
    assert_not_nil assigns(:payment_methods)
    assert_not_nil assigns(:payment_types)
    assert_not_nil assigns(:creators)
  end

  it "creates fee" do
    @fee = fee
    assert_difference('Fee.count') do
      post :create, fee: { creator_id: @fee.creator_id, amount: @fee.amount, member_id: @fee.member_id, payment_date: @fee.payment_date, payment_method: @fee.payment_method, payment_type: @fee.payment_type }
    end

    assert_redirected_to fee_path(assigns(:fee))
  end

  it "shows fee" do
    get :show, id: fee
    assert_response :success
  end

  it "gets edit" do
    get :edit, id: fee
    assert_not_nil assigns(:members)
    assert_not_nil assigns(:payment_methods)
    assert_not_nil assigns(:payment_types)
    assert_not_nil assigns(:creators)
  end

  it "updates fee" do
    @fee = fee
    put :update, id: fee, fee: { creator_id: @fee.creator_id, amount: @fee.amount, member_id: @fee.member_id, payment_date: @fee.payment_date, payment_method: @fee.payment_method, payment_type: @fee.payment_type }
    assert_redirected_to fee_path(assigns(:fee))
  end

  it "destroys fee" do
    assert_difference('Fee.count', -1) do
      delete :destroy, id: fee, member_id: fee.member
    end

    assert_redirected_to fees_path
  end

end
