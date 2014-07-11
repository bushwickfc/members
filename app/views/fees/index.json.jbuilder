json.array!(@fees) do |fee|
  json.extract! fee, :id, :member_id, :receiver_id, :amount, :payment_date, :payment_type, :payment_method
  json.url fee_url(fee, format: :json)
end
