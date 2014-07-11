class Note < ActiveRecord::Base
  belongs_to :member
  belongs_to :receiver

  def as_csv
    attributes
  end
end
