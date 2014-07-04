json.array!(@members) do |member|
  json.extract! member, :id, :first_name, :middle_name, :last_name, :email, :phone, :phone2, :fax, :address, :address2, :city, :state, :country, :zip, :sex, :status, :join_date, :admin, :membership_agreement, :monthly_hours, :fee_discount, :investment_discount
  json.url member_url(member, format: :json)
end
