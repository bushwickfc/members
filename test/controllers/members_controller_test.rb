require "test_helper"

describe MembersController do

  it "gets active index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:members)
    assert_equal 5, assigns(:members).to_a.count
  end

  it "gets new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:member)
    assert_not_nil assigns(:statuses)
    assert_not_nil assigns(:contact_preferences)
  end

  it "creates member" do
    assert_difference('Member.count') do
      post :create, member: { 
        address2: @john.address2,
        address: @john.address,
        admin: @john.admin,
        city: @john.city,
        password: "abc",
        password_confirmation: "abc",
        contact_preference: @john.contact_preference,
        country: @john.country,
        date_of_birth: @john.date_of_birth,
        email: @john.email,
        fax: @john.fax,
        membership_discount: @john.membership_discount,
        first_name: @john.first_name+"1",
        annual_discount: @john.annual_discount,
        join_date: @john.join_date,
        work_date: @john.work_date,
        last_name: @john.last_name,
        membership_agreement: @john.membership_agreement,
        monthly_hours: @john.monthly_hours,
        phone2: @john.phone2,
        phone: @john.phone,
        state: @john.state,
        status: @john.status,
        zip: @john.zip 
      }
    end

    assert_redirected_to member_path(assigns(:member))
  end

  it "shows member" do
    get :show, id: @john
    assert_response :success
    assert_not_nil assigns(:member)
    assert_not_nil assigns(:messages)
    assert_not_nil assigns(:notes)
  end

  it "gets edit" do
    get :edit, id: @john
    assert_response :success
    assert_not_nil assigns(:member)
    assert_not_nil assigns(:statuses)
    assert_not_nil assigns(:contact_preferences)
  end

  it "updates member" do
    put :update, id: @john, member: { 
      address2: @john.address2,
      address: @john.address,
      admin: @john.admin,
      city: @john.city,
      contact_preference: @john.contact_preference,
      country: @john.country,
      date_of_birth: @john.date_of_birth,
      email: @john.email,
      fax: @john.fax,
      membership_discount: @john.membership_discount,
      first_name: @john.first_name,
      annual_discount: @john.annual_discount,
      join_date: @john.join_date,
      work_date: @john.work_date,
      last_name: @john.last_name,
      membership_agreement: @john.membership_agreement,
      monthly_hours: @john.monthly_hours,
      phone2: @john.phone2,
      phone: @john.phone,
      state: @john.state,
      status: @john.status,
      zip: @john.zip 
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
    skip "works in browser, not in test env"
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
