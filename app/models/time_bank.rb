class TimeBank < ActiveRecord::Base
  # format string used to insert SUM or nothing
  HOURS_SELECT = "IFNULL(CAST(%s(UNIX_TIMESTAMP(finish)-UNIX_TIMESTAMP(start))/60.0/60.0 AS DECIMAL(10,2)), 0.0) AS hours"
  HOURS_SUSPENDED = -4
  cattr_reader :time_types
  @@time_types = %w[
    store_shift
    committee
    facilities
    gift_given
    gift_received
    hold
    parental
    meeting
    orientation
    other
    penalty
  ].sort.freeze

  belongs_to :member
  belongs_to :admin
  belongs_to :committee
  has_many :notes, as: :commentable

  accepts_nested_attributes_for :notes, reject_if: proc {|a| a['note'].blank?}

  before_validation :penalty_swap

  validates :member_id,    presence: true
  validates :admin_id,     presence: true
  validates :date_worked,  presence: true
  validates :hours_worked, presence: true, numericality: true, exclusion: { in: [0], message: "must not be zero" }
  validates :start,        presence: true
  validates :finish,       presence: true
  validates :time_type,    inclusion: { in: @@time_types }

  validate  :validate_positive_times, :validate_negative_times

  scope :unapproved_only, -> { where(approved: false) }
  scope :approved_only,   -> { where(approved: true) }
  scope :hours,           -> { select(HOURS_SELECT % nil) }
  scope :hours_summed,    -> { select(HOURS_SELECT % "SUM") }
  scope :include_parents, -> { includes(:admin, :member, :committee) }
  scope :select_all,      -> { select("#{table_name}.*").hours }

  # Overriding initialize() due to manipulation of time data with values from
  #  virtual attributes 'date_worked' and 'hours_worked'.
  # @see TimeBank::date_hack()
  def initialize(attributes={})
    date_hack(attributes)
    super(attributes)
  end

  # Overriding update() due to manipulation of time data with values from
  #  virtual attributes 'date_worked' and 'hours_worked'.
  # @see TimeBank::date_hack()
  def update(attributes={})
    date_hack(attributes)
    super(attributes)
  end

  # Facilitates better UX for user input of a single date, and amount of hours
  #  worked on that date, while preserving the original functionality of the
  #  start time and finish time.
  # @see TimeBank::date_worked() and TimeBank::hours_worked()
  private def date_hack(attributes)
    if !attributes["date_worked"].nil? && !attributes["date_worked"].blank?
      attributes["start"]  = attributes["date_worked"].to_time
      attributes["finish"] = attributes["start"] + attributes["hours_worked"].to_f.hours

      attributes.delete("date_worked")
      attributes.delete("hours_worked")
    end
  end

  # @params range [Array|Range|Scalar] an array or range or two date strings
  def self.hours_between(*range)
    if range[0].kind_of?(String)
      start = range[0].to_datetime
      finish = range[1].to_datetime
      range = start..finish
    end
    where("start BETWEEN :start AND :finish OR finish BETWEEN :start AND :finish",
          start: range.first, finish: range.last)
  end

  # Virtual attribute to provide better UX for inputting a Member's work on a
  #  given day. Value is converted into TimeBank.start.
  # @see TimeBank::date_hack()
  def date_worked
    @date_worked ||= self.start.to_date
  rescue
    Date.current
  end

  def date_worked=(date_worked_val)
    self.attributes['date_worked'] = date_worked_val
  end

  # Virtual attribute to provide better UX for inputting amount of time a
  #  Member worked on a given day. Value is used to determine TimeBank.finish.
  # @see TimeBank::date_hack()
  def hours_worked
    @hours_worked ||= hours
  rescue NoMethodError
    nil
  end

  def hours_worked=(hours_worked_val)
    self.attributes['hours_worked'] = hours_worked_val
  end

  def hours
    if attributes["hours"]
      read_attribute(:hours).to_f 
    else
      ((finish - start)/1.hour).to_f
    end
  rescue NoMethodError
    0.0
  end

  # ensure that penalties create negative time for the member
  # While I would prefer to only use a callback or a setter, I don't feel
  # like relying soley on a setter works. If a user writes directly to the
  # database, or skips callbacks, this value will be incorrect...
  def time_type=(new_time_type)
    write_attribute(:time_type, new_time_type)
    swap_start_finish
  end

  # ensure that penalties create negative time for the member
  # While I would prefer to only use a callback or a setter, I don't feel
  # like the delay on callback gives immediate enough feedback, esp during testing and in
  # the console.
  def penalty_swap
    swap_start_finish do
      update_columns(start: start, finish: finish) if persisted?
    end
  end

  # only check for negative times when it's for penalty
  def validate_negative_times
    return true if (time_type != "penalty" && time_type != "gift_given") || start.nil? || finish.nil?
    if r = start <= finish
      errors.add(:start, "must come after finish, for penalties")
    end
    r
  end

  # only check for positive times when it's not for penalty
  def validate_positive_times
    return true if (time_type == "gift_given" || time_type == "penalty") || start.nil? || finish.nil?
    if r = start >= finish
      errors.add(:start, "must come before finish")
      errors.add(:hours_worked, "must be positive for this time type")
    end
    r
  end

  private def swap_start_finish(&block)
    return true if (time_type != "gift_given" && time_type != "penalty") || start.nil? || finish.nil?
    return true if (time_type == "gift_given" || time_type == "penalty") && start > finish
    #puts "SWAP #{start} #{finish} // #{self.inspect}"
    s = start
    write_attribute(:start, finish)
    write_attribute(:finish, s)
    block_given? ? yield : true
  end

  module TimeBank::MemberProxy

    def since_work_date
      where("start >= ?", proxy_association.owner.work_date)
    end

    def hours_worked
      since_work_date.approved_only.hours_summed.first.hours
    end

    def balance
      hours_worked - proxy_association.owner.hours_owed
    end

    def current?
      balance >= 0
    end

    def suspended?
      balance < HOURS_SUSPENDED
    end

    def can_shop?
      current? || !suspended?
    end

    def last_shift(fmt = nil)
      shift = proxy_association.owner.time_banks.order(start: :desc).limit(1).first
      fmt.nil? ? shift : shift.start.strftime(fmt)
    rescue NoMethodError => e
      nil
    end

  end
end
