require "test_helper"

describe MembersController do

  let(:member) { members :member1 }

  it "gets index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:members)
  end

  it "gets new" do
    get :new
    assert_response :success
  end

  it "creates member" do
    @member = member
    assert_difference('Member.count') do
      post :create, member: { address2: @member.address2, address: @member.address, admin: @member.admin, city: @member.city, country: @member.country, email: @member.email, fax: @member.fax, fee_discount: @member.fee_discount, first_name: @member.first_name+"1", investment_discount: @member.investment_discount, join_date: @member.join_date, last_name: @member.last_name, membership_agreement: @member.membership_agreement, middle_name: @member.middle_name, monthly_hours: @member.monthly_hours, phone2: @member.phone2, phone: @member.phone, sex: @member.sex, state: @member.state, status: @member.status, zip: @member.zip }
    end

    assert_redirected_to member_path(assigns(:member))
  end

  it "shows member" do
    get :show, id: member
    assert_response :success
  end

  it "gets edit" do
    get :edit, id: member
    assert_response :success
  end

  it "updates member" do
    @member = member
    put :update, id: member, member: { address2: @member.address2, address: @member.address, admin: @member.admin, city: @member.city, country: @member.country, email: @member.email, fax: @member.fax, fee_discount: @member.fee_discount, first_name: @member.first_name, investment_discount: @member.investment_discount, join_date: @member.join_date, last_name: @member.last_name, membership_agreement: @member.membership_agreement, middle_name: @member.middle_name, monthly_hours: @member.monthly_hours, phone2: @member.phone2, phone: @member.phone, sex: @member.sex, state: @member.state, status: @member.status, zip: @member.zip }
    assert_redirected_to member_path(assigns(:member))
  end

  it "destroys member" do
    assert_difference('Member.count', -1) do
      delete :destroy, id: member
    end

    assert_redirected_to members_path
  end

end
