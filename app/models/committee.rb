class Committee < ActiveRecord::Base
  belongs_to :member
  has_many   :time_banks

  validates :member_id, presence: true
  validates :name, presence: true

  scope     :form_select,     -> { select :name, :id }
  scope     :include_parents, -> { includes :member }
end
