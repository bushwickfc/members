json.array!(@time_banks) do |time_bank|
  json.extract! time_bank, :id, :member_id, :admin_id, :committee_id, :date_worked, :hours_worked, :hours, :time_type, :approved
  json.url time_bank_url(time_bank, format: :json)
end
