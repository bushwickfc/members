class Note < ActiveRecord::Base
  belongs_to :member
  belongs_to :receiver
end
