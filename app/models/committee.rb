class Committee < ActiveRecord::Base
  belongs_to :member

  validates :member_id, presence: true
  validates :name, presence: true

  scope     :form_select, -> { select :name, :id }

  def as_csv
    attributes
  end
end
