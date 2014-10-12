class Event < ActiveRecord::Base
  belongs_to :trackable, polymorphic: true
  serialize :data, JSON
  scope :status_change, -> { where('data LIKE \'%"status"%\'') }
  
  def self.created_after(date = Date.current.beginning_of_month)
    where("created_at >= ?", date.to_date)
  end
end
