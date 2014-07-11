# TODO: Add job which puts time into time_banks for maternity and hold members
class Member < ActiveRecord::Base
  MEMBERSHIP_FEE = 50
  INVESTMENT_FEE = 25
  MINIMUM_HOLD   = 1.month
  FULL_NAME      = 'CONCAT_WS(" ", first_name, middle_name, last_name) AS full_name'
  cattr_reader :genders, :statuses, :contact_preferences
  @@genders  = %w[Male Female]
  @@statuses = %w[active inactive suspended hold maternity canceled interested volunteer]
  @@contact_preferences = %w[email phone]

  has_many :committees, dependent: :restrict_with_exception
  has_many :fees, dependent: :restrict_with_exception do
    include Fee::MemberProxy
  end
  has_many :time_banks, dependent: :restrict_with_exception do
    include TimeBank::MemberProxy
  end

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, email: { mx: true, message: "Host does not receive email" }, if: lambda {|m| m.contact_preference == "email" }
  validates :gender, inclusion: { in: @@genders }, allow_nil: true, allow_blank: true
  validates :status, inclusion: { in: @@statuses }, allow_nil: true, allow_blank: true
  validates :contact_preference, inclusion: { in: @@contact_preferences }, allow_nil: true, allow_blank: true
  validates :join_date, presence: true
  validates :date_of_birth, presence: true
  validates :monthly_hours, numericality: { greater_than: 0.0 }
  validates :membership_discount, numericality: { greater_than_or_equal_to: 0.0 }
  validates :investment_discount, numericality: { greater_than_or_equal_to: 0.0 }

  validate  :on_hold_until_valid

  scope     :form_select, -> { full_name.select(:id) }
  scope     :full_name,   -> { select(FULL_NAME) }

  # do not validate if +on_hold_until+ is nil
  def on_hold_until_valid
    min_hold = Date.current + MINIMUM_HOLD

    if !on_hold_until? || on_hold_until >= min_hold
      true
    else
      errors.add(:on_hold_until, "Hold is not long enough")
      false
    end
  end

  def membership_rate
    MEMBERSHIP_FEE - (MEMBERSHIP_FEE * membership_discount / 100.0)
  end

  def investment_rate
    INVESTMENT_FEE - (INVESTMENT_FEE * membership_discount / 100.0)
  end

  def membership_in(type = :weeks)
    since = (Date.current - join_date).to_i
    case type
    when :days    then since
    when :weeks   then since / 7
    when :months  then since / 30
    when :years   then since / 365
    end
  end

  def hours_owed
    membership_in(:months) * monthly_hours
  end

  def full_name
    read_attribute(:full_name) || [first_name, middle_name, last_name].join(' ')
  end

end
