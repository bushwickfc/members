# TODO: Add job which puts time into time_banks for maternity and hold members
class Member < ActiveRecord::Base
  MEMBERSHIP_FEE = 50
  INVESTMENT_FEE = 25
  FULL_NAME      = 'LTRIM(CONCAT_WS(" ", first_name, middle_name, last_name)) AS full_name'
  cattr_reader :genders, :statuses, :contact_preferences
  @@genders  = %w[Male Female]
  @@statuses = %w[active inactive suspended hold parental canceled interested volunteer]
  @@contact_preferences = %w[email phone]

  has_many :committees,   dependent: :restrict_with_exception
  has_many :fees,         dependent: :restrict_with_exception do
    include Fee::MemberProxy
  end
  has_many :furloughs,    dependent: :restrict_with_exception
  has_many :holds,        dependent: :restrict_with_exception
  has_many :parentals,    dependent: :restrict_with_exception
  has_many :time_banks,   dependent: :restrict_with_exception do
    include TimeBank::MemberProxy
  end

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, email: { mx: true, message: "Host does not receive email" }, if: lambda {|m| m.contact_preference == "email" }
  validates :gender, inclusion: { in: @@genders }, allow_nil: true, allow_blank: true
  validates :status, inclusion: { in: @@statuses }, allow_nil: true, allow_blank: true
  validates :contact_preference, inclusion: { in: @@contact_preferences }, allow_nil: true, allow_blank: true
  validates :monthly_hours, numericality: { greater_than: 0.0 }
  validates :membership_discount, numericality: { greater_than_or_equal_to: 0.0 }
  validates :investment_discount, numericality: { greater_than_or_equal_to: 0.0 }

  scope     :form_select, -> { full_name.select(:id) }
  scope     :full_name,   -> { select(FULL_NAME) }

  def membership_rate
    MEMBERSHIP_FEE - (MEMBERSHIP_FEE * membership_discount / 100.0)
  end

  def investment_rate
    INVESTMENT_FEE - (INVESTMENT_FEE * membership_discount / 100.0)
  end

  def membership_in(type = :weeks)
    return 0.0 unless join_date?

    since = (Date.current - join_date).to_f
    case type
    when :days    then since
    when :weeks   then since / 7.0
    when :months  then since / 30.0
    when :years   then since / 365.0
    end.floor
  end

  def work_in(type = :weeks)
    return 0.0 unless work_date?

    since = (Date.current - work_date).to_f
    case type
    when :days    then since
    when :weeks   then since / 7.0
    when :months  then since / 30.0
    when :years   then since / 365.0
    end.floor
  end

  def hours_owed
    work_in(:months) * monthly_hours
  end

  def full_name
    read_attribute(:full_name) || [first_name, middle_name, last_name].join(' ')
  end

end
