require "test_helper"

describe TimeBanksController do

  describe "index" do
    it "gets 4 month index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:time_banks)
      assert_equal assigns(:time_banks).to_a.count, 14
    end

    it "gets all index" do
      get :index, all: 1
      assert_response :success
      assert_not_nil assigns(:time_banks)
      assert_equal TimeBank.count, assigns(:time_banks).to_a.count
    end

    it "gets unapproved index" do
      get :index, search: {approved: 0}
      assert_response :success
      assert_not_nil assigns(:time_banks)
      assert_equal assigns(:time_banks).to_a.count, 2
    end
  end

  it "gets new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:admins)
    assert_not_nil assigns(:committees)
    assert_not_nil assigns(:members)
    assert_not_nil assigns(:time_bank)
    assert_not_nil assigns(:time_types)
  end

  it "creates time_bank" do
    assert_difference('TimeBank.count') do
      post :create, time_bank: {
        member_id: @john, admin_id: @addy, date_worked: "2015-9-10", hours_worked: 1, approved: true,
        time_type: "store_shift"
      }
    end

    assert_redirected_to time_bank_path(assigns(:time_bank))
  end

  it "shows time_bank" do
    get :show, id: @john_cashier_approved
    assert_response :success
    assert_not_nil assigns(:time_bank)
  end

  it "gets edit" do
    get :edit, id: @john_cashier_approved
    assert_response :success
    assert_not_nil assigns(:admins)
    assert_not_nil assigns(:committees)
    assert_not_nil assigns(:members)
    assert_not_nil assigns(:time_bank)
    assert_not_nil assigns(:time_types)
  end

  it "updates time_bank" do
    put :update, id: @john_cashier_approved, time_bank: {
      member_id: @john, admin_id: @addy, date_worked: "2015-9-10", hours_worked: 4, approved: true,
      time_type: "store_shift"
    }
    assert_redirected_to time_bank_path(assigns(:time_bank))
  end

  it "destroys time_bank" do
    assert_difference('TimeBank.count', -1) do
      delete :destroy, id: @john_cashier_approved
    end

    assert_redirected_to time_banks_path
  end

end
