class Furlough < ActiveRecord::Base
  belongs_to :member
  belongs_to :receiver

  validates :member_id, presence: true
  validates :receiver_id, presence: true
  validates :start, presence: true
  validates :finish, presence: true
  validates :type, presence: true
  validate  :no_member_furloughs_active, :start_finish_valid

  scope :active,          -> { where("NOW() BETWEEN start AND finish") }
  scope :hold,            -> { where(type: :Hold) }
  scope :parental,        -> { where(type: :Parental) }
  scope :include_parents, -> { includes(:member, :receiver) }

  # @params range [Array|Range|Scalar] an array or range or two date strings
  def self.active_between(*range)
    if range[0].kind_of?(String)
      start = range[0].to_date
      finish = range[1].to_date
      range = start..finish
    end
    where("? BETWEEN start AND finish OR ? BETWEEN start AND finish",
          range.first, range.last)
  end

  def start_finish_valid
    return unless start? && finish?
    if finish < start
      errors.add(:start, "must come before finish")
      false
    end
  end

  def no_member_furloughs_active
    furloughs = Furlough.where(member_id: member_id).
      active_between(start, finish)
    furloughs = furloughs.where.not(id: id) if id?
    if furloughs.any?
      errors.add(:start, "active during this period")
      false
    end
  end

end