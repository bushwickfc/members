class TimeBank < ActiveRecord::Base
  # format string used to insert SUM or nothing
  HOURS_SELECT = "IFNULL(CAST(%s(UNIX_TIMESTAMP(finish)-UNIX_TIMESTAMP(start))/60/60 AS SIGNED), 0) AS hours"
  HOURS_SUSPENDED = -4
  cattr_reader :time_types
  @@time_types = %w[
    cashier
    close
    committee
    facilities
    gift_given
    gift_received
    greeter
    hold
    maternity
    meeting
    open
    orientation
    other
    penalty
    receiving
  ]

  belongs_to :member
  belongs_to :admin
  belongs_to :committee

  before_validation :penalty_swap

  validates :member_id, presence: true
  validates :admin_id,  presence: true
  validates :start,     presence: true
  validates :finish,    presence: true
  validates :time_type, inclusion: { in: @@time_types }
  validates :approved,  presence: true

  validate  :validate_positive_times, :validate_negative_times

  scope :unapproved_only, -> { where(approved: false) }
  scope :approved_only,   -> { where(approved: true) }
  scope :hours,           -> { select(HOURS_SELECT % nil) }
  scope :hours_summed,    -> { select(HOURS_SELECT % "SUM") }

  attr_accessor :hours

  def hours
    read_attribute(:hours) || ((finish - start)/60/60).to_i rescue 0
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

  def as_csv
    attributes
  end

  module TimeBank::MemberProxy

    def hours_worked
      approved_only.hours_summed.first.hours
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

  end
end
