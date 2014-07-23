require "test_helper"

describe MembersController do

  it "gets active index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:members)
    assert_equal assigns(:members).to_a.count, 7
  end

  it "gets interested index" do
    get :index, interested: 1
    assert_response :success
    assert_not_nil assigns(:members)
    assert_equal assigns(:members).to_a.count, 1
  end

  it "gets inactive index" do
    get :index, inactive: 1
    assert_response :success
    assert_not_nil assigns(:members)
    assert_equal assigns(:members).to_a.count, 1
  end

  it "gets new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:genders)
    assert_not_nil assigns(:member)
    assert_not_nil assigns(:statuses)
    assert_not_nil assigns(:contact_preferences)
  end

  it "creates member" do
    assert_difference('Member.count') do
      post :create, member: { 
        address2: @member1.address2,
        address: @member1.address,
        admin: @member1.admin,
        city: @member1.city,
        contact_preference: @member1.contact_preference,
        country: @member1.country,
        date_of_birth: @member1.date_of_birth,
        email: @member1.email,
        fax: @member1.fax,
        membership_discount: @member1.membership_discount,
        first_name: @member1.first_name+"1",
        investment_discount: @member1.investment_discount,
        join_date: @member1.join_date,
        work_date: @member1.work_date,
        last_name: @member1.last_name,
        membership_agreement: @member1.membership_agreement,
        middle_name: @member1.middle_name,
        monthly_hours: @member1.monthly_hours,
        phone2: @member1.phone2,
        phone: @member1.phone,
        gender: @member1.gender,
        state: @member1.state,
        status: @member1.status,
        zip: @member1.zip 
      }
    end

    assert_redirected_to member_path(assigns(:member))
  end

  it "shows member" do
    get :show, id: @member1
    assert_response :success
    assert_not_nil assigns(:member)
  end

  it "gets edit" do
    get :edit, id: @member1
    assert_response :success
    assert_not_nil assigns(:genders)
    assert_not_nil assigns(:member)
    assert_not_nil assigns(:statuses)
    assert_not_nil assigns(:contact_preferences)
  end

  it "updates member" do
    put :update, id: @member1, member: { 
      address2: @member1.address2,
      address: @member1.address,
      admin: @member1.admin,
      city: @member1.city,
      contact_preference: @member1.contact_preference,
      country: @member1.country,
      date_of_birth: @member1.date_of_birth,
      email: @member1.email,
      fax: @member1.fax,
      membership_discount: @member1.membership_discount,
      first_name: @member1.first_name,
      investment_discount: @member1.investment_discount,
      join_date: @member1.join_date,
      work_date: @member1.work_date,
      last_name: @member1.last_name,
      membership_agreement: @member1.membership_agreement,
      middle_name: @member1.middle_name,
      monthly_hours: @member1.monthly_hours,
      phone2: @member1.phone2,
      phone: @member1.phone,
      gender: @member1.gender,
      state: @member1.state,
      status: @member1.status,
      zip: @member1.zip 
    }
    assert_redirected_to member_path(assigns(:member))
  end

  it "destroys member" do
    assert_difference('Member.count', -1) do
      delete :destroy, id: @safe_delete
    end

    assert_redirected_to members_path
  end

  it "does not destroy member with fees" do
    assert_difference('Member.count', 0) do
      assert_raise(ActiveRecord::DeleteRestrictionError, 
                   "Cannot delete record because of dependent fees") do
        delete :destroy, id: @john
      end
    end

    assert_response :success
    assert_not_nil assigns(:member)
  end

end
