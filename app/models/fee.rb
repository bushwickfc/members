class Fee < ActiveRecord::Base
  WEEKS_TO_PAY_MEMBERSHIP = 5
  cattr_reader :payment_types
  cattr_reader :payment_methods
  @@payment_types   = %w[membership investment].freeze
  @@payment_methods = %w[cash check money_order debit].freeze

  belongs_to :member
  belongs_to :receiver

  validates :member_id, presence: true
  validates :receiver_id, presence: true

  validates :amount, numericality: { greater_than: 0.0 }
  validates :payment_date, presence: true
  validates :payment_method, inclusion: { in: payment_methods }
  validates :payment_type, inclusion: { in: payment_types }

  scope :membership_payment, -> { where(payment_type: "membership") }
  scope :investment_payment, -> { where(payment_type: "investment") }

  def as_csv
    attributes
  end

  module MemberProxy
    def membership_payment_total
      where(payment_type: "membership").
        where(member_id: proxy_association.owner.id).
        sum(:amount)
    end

    def membership_paid_incrementally?
      weeks = proxy_association.owner.membership_in(:weeks)
      rate = proxy_association.owner.membership_rate / WEEKS_TO_PAY_MEMBERSHIP
      membership_payment_total >= weeks * rate
    end

    def membership_paid_full?
      membership_payment_total >= proxy_association.owner.membership_rate
    end

    def membership_payment_overdue?
      weeks = proxy_association.owner.membership_in(:weeks)
      !membership_paid_full? && weeks >= WEEKS_TO_PAY_MEMBERSHIP
    end

    def membership_paid?
      membership_paid_full? || membership_paid_incrementally?
    end
  end

end
