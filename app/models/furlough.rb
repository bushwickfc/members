class Furlough < ActiveRecord::Base
  belongs_to :member
  belongs_to :creator, class_name: "Member"
  has_many :notes, as: :commentable

  accepts_nested_attributes_for :notes, reject_if: proc {|a| a['note'].blank?}

  validates :member_id, presence: true
  validates :creator_id, presence: true
  validates :start, presence: true
  validates :finish, presence: true
  validates :type, presence: true
  validate  :no_member_furloughs_active, :start_finish_valid
  before_validation :membership_active, unless: :persisted?
  after_save :back_fill_time_banks

  scope :active,          -> { where("NOW() BETWEEN start AND finish") }
  scope :hold,            -> { where(type: :Hold) }
  scope :parental,        -> { where(type: :Parental) }
  scope :include_parents, -> { includes(:member, :creator) }

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

  def membership_active
    if member && !member.membership_status.can_shop?
      errors.add(:member_id, "must be able to shop")
    end
  end

  def back_fill_time_banks
    eom = Date.current.end_of_month
    return true if start > eom
    i=0
    loop do
      s = (Date.current - i.months).beginning_of_month
      f = s.end_of_month
      break if s < start.beginning_of_month
      UpdateHoldsAndLeaves.perform_async(member.id, s.to_s, f.to_s, 'hold', creator.id)
      i+=1
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
