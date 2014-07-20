json.array!(@furloughs) do |furlough|
  json.extract! furlough, :id, :member_id, :receiver_id, :type, :start, :finish
  json.url furlough_show(@member, furlough, format: :json)
end
