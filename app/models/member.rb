require 'digest/sha1'

class Member < ActiveRecord::Base
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         authentication_keys: [:login], password_length: 3..128

  MEMBERSHIP_FEE = 50
  ANNUAL_FEE     = 25
  FULL_NAME      = 'LTRIM(CONCAT_WS(" ", first_name, last_name)) AS full_name'
  cattr_reader :statuses, :contact_preferences
  @@statuses = %w[active work_alert inactive suspended hold parental canceled interested volunteer]
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

  has_many :notes, as: :commentable
  has_many :events, as: :trackable

  accepts_nested_attributes_for :notes, reject_if: proc {|a| a['note'].blank?}

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, email: { mx: true, message: "Host does not receive email" }, if: lambda {|m| m.contact_preference == "email" }
  validates :status, inclusion: { in: @@statuses }, allow_nil: true, allow_blank: true
  validates :contact_preference, inclusion: { in: @@contact_preferences }, allow_nil: true, allow_blank: true
  validates :monthly_hours, numericality: { greater_than: 0.0 }
  validates :membership_discount, numericality: { greater_than_or_equal_to: 0.0 }
  validates :annual_discount, numericality: { greater_than_or_equal_to: 0.0 }
  validates_confirmation_of :password

  scope     :status_totals, -> { select("count(*) as total, status").group(:status).order(:status) }
  scope     :form_select, -> { full_name.select(:id) }
  scope     :full_name,   -> { select(FULL_NAME) }
  scope     :cached_cant_shop, -> { where(status: %w[inactive canceled volunteer interested hold]) }
  scope     :cached_can_shop, -> { where(status: [nil, "work_alert", "suspended", "active", "parental"]) }

  def self.by_email_hash(hash)
    find_by!("SHA1(email) = ?", hash)
  end

  def self.permitted_params
    [
      :first_name,
      :last_name, 
      :opt_out, 
      :email, 
      :hash,
      :phone, 
      :phone2, 
      :fax, 
      :address, 
      :address2, 
      :city, 
      :state, 
      :country, 
      :zip, 
      :status, 
      :join_date, 
      :work_date,
      :date_of_birth, 
      :admin, 
      :membership_agreement, 
      :monthly_hours, 
      :membership_discount, 
      :annual_discount,
      :password,
      :password_confirmation,
      :remember_me,
      :current_password,
      notes_attributes: [:commentable_id, :commentable_type, :creator_id, :note],
    ]
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).
        find_by("concat_ws(' ', first_name, last_name) = ? OR email = ?", 
                login, login)
    else
      where(conditions).first
    end
  end

  def self.name_like(params = {})
    fname = params[:first_name]
    lname = params[:last_name]
    rel = default_scoped
    rel = rel.where("first_name LIKE '%#{fname}%'") if fname
    rel = rel.where("last_name LIKE '%#{lname}%'") if lname
    rel
  end

  def all_notes
    Note.union_scope(
      Note.commentable(fee_ids, "Fee"),
      Note.commentable(hold_ids, "Hold"),
      Note.commentable(id, "Member"),
      Note.commentable(parental_ids, "Parental"),
      Note.commentable(time_bank_ids, "TimeBank"),
    ).order(updated_at: :desc)
  end

  def optout_hash
    Digest::SHA1.hexdigest email
  end

  def membership_rate
    MEMBERSHIP_FEE - (MEMBERSHIP_FEE * membership_discount / 100.0)
  end

  def annual_rate
    ANNUAL_FEE - (ANNUAL_FEE * membership_discount / 100.0)
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
    read_attribute(:full_name) || [first_name, last_name].join(' ').strip.gsub(/\s+/, ' ')
  end

  def membership_status(force = false)
    return @membership_status if @membership_status && !force

    @membership_status = Struct::MembershipStatus.new(
      status,                                     # status
      join_date,                                  # join_date
      false,                                      # can_shop
      (holds.active.first.finish rescue nil),     # hold
      fees.membership_paid?,                      # membership_fees
      fees.membership_balance,                    # membership_fees_balance
      fees.membership_payment_overdue?,           # membership_fees_overdue
      (parentals.active.first.finish rescue nil), # parental
      time_banks.balance,                         # time_bank_balance
    )
  end

  # JSON work around
  def can_shop
    can_shop?
  end

  def can_shop?
    membership_status(true).can_shop?
  end

  def can_shop_messages
    membership_status.messages
  end

  def update_status(new_status)
    update_columns(status: new_status) if status != new_status
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def login=(login)
    @login = login
  end

  def login
    @login || self.full_name || self.email
  end

  def password_required?
    false
  end

end
