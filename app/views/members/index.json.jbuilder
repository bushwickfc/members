json.array!(@members) do |member|
  json.extract! member,
    :id,
    :first_name,
    :last_name,
    :opt_out,
    :email,
    :phone,
    :phone2,
    :fax,
    :address,
    :address2,
    :city,
    :state,
    :country,
    :zip,
    :contact_preference,
    :status,
    :join_date,
    :work_date,
    :date_of_birth,
    :admin,
    :membership_agreement,
    :monthly_hours,
    :membership_discount,
    :annual_discount,
    :hours,
    :hours_owed,
    :hours_difference,
  json.url member_url(member, format: :json)
end
