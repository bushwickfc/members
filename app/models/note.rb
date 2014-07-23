class Note < ActiveRecord::Base
  belongs_to :member
  belongs_to :creator, class_name: "Member"
end
