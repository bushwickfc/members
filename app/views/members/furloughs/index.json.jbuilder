json.array!(@furloughs) do |furlough|
  json.extract! furlough, :id, :member_id, :creator_id, :type, :start, :finish
  json.url furlough_show(@member, furlough, format: :json)
end
