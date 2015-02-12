Struct.new("MembershipStatus", 
            :status,
            :join_date,
            :can_shop,
            :hold,
            :membership_fees,
            :membership_fees_balance,
            :membership_fees_overdue,
            :parental,
            :time_bank_balance,
            :last_shift
) do

  VOLUNTEER=1
  INTERESTED=2
  ACTIVE=4
  PARENTAL=8
  WORK_ALERT=16
  HOLD=32
  SUSPENDED=64
  CANCELED=128
  INACTIVE=256

  def initialize(*a)
    super
    @calculated_status = 0
  end

  def messages(force = false)
    return @messages if @messages && !force
    @messages = Array.new
  end

  def can_shop?(force = false)
    return @can_shop_bool if @can_shop_bool && !force
    messages(true)
    s_ok = check_status
    m_ok = check_membership_fees
    h_ok = check_hours
    self.can_shop = @can_shop_bool = s_ok && m_ok && h_ok
    if @can_shop_bool
      messages << "Member in good standing"
      set_calculated_status(ACTIVE)
    end
    self.status = convert_calculated_status
    @can_shop_bool
  end

  def set_calculated_status(i)
    puts "setting #{i}"
    @calculated_status |= i
  end

  def convert_calculated_status
    return self.status if @calculated_status == 0

    if @calculated_status & INACTIVE == INACTIVE
      "inactive"
    elsif @calculated_status & CANCELED == CANCELED
      "canceled"
    elsif @calculated_status & SUSPENDED == SUSPENDED
      "suspended"
    elsif @calculated_status & HOLD == HOLD
      "hold"
    elsif @calculated_status & WORK_ALERT == WORK_ALERT
      "work_alert"
    elsif @calculated_status & PARENTAL == PARENTAL
      "parental"
    elsif @calculated_status & ACTIVE == ACTIVE
      "suspended"
    elsif @calculated_status & INTERESTED == INTERESTED
      "interested"
    elsif @calculated_status & VOLUNTEER == VOLUNTEER
      "volunteer"
    end
  end

  def a_member?
    !(status == "volunteer" || status == "interested" || join_date.blank?)
  end

  def check_status
    return @status_ok unless @status_ok.nil?

    if !a_member?
      set_calculated_status(status.upcase.constantize) if join_date
      @status_ok = false
      messages << "Not a member"

    elsif status == "canceled" || status == "suspended" || status == "inactive"
      set_calculated_status(status.upcase.constantize)
      @status_ok = false
      messages << "#{status.capitalize} membership"

    elsif status == "hold" || !hold.blank?
      #if hold.blank?
        ## TODO needed?
        #self.status = nil
        #@status_ok = check_status
      #else
        @status_ok = false
        messages << "On hold until #{hold}"
        set_calculated_status(HOLD)
      #end

    elsif status == "parental" || !parental.blank?
      #if parental.blank?
        ## TODO needed?
        #self.status = nil
        #@status_ok = check_status
      #else
        @status_ok = true
        messages << "On parental leave until #{parental}"
        set_calculated_status(PARENTAL)
      #end

    elsif status == "work_alert"
      @status_ok = true
      set_calculated_status(WORK_ALERT)

    elsif status == "active" || status.blank?
      @status_ok = true
      set_calculated_status(ACTIVE)

    else
      messages << "Unknown status '#{status}'"
      @status_ok = true
    end

    @status_ok
  end

  def check_membership_fees
    return @fees_ok unless @fees_ok.nil?
    return false unless a_member?

    if membership_fees_overdue
      set_calculated_status(INACTIVE)
      @fees_ok = false
      messages << "Membership fees not paid in 2 months, balance $%0.2f" % membership_fees_balance
    elsif membership_fees_balance > 0
      @fees_ok = true
      messages << "Still owes fees ($%0.2f)" % membership_fees_balance
    else
      @fees_ok = true
    end

    @fees_ok
  end

  def check_hours
    return @hours_ok unless @hours_ok.nil?
    return false unless a_member?

    if time_bank_balance <= -16
      @hours_ok = false
      set_calculated_status(INACTIVE)
      messages << "Inactive, owes 16+ hours"
    elsif time_bank_balance > -16 && time_bank_balance <= -8.25
      @hours_ok = false
      set_calculated_status(SUSPENDED)
      messages << "Suspended, owes #{time_bank_balance.abs} hours"
    elsif time_bank_balance < -4
      @hours_ok = true
      set_calculated_status(WORK_ALERT)
      messages << "Work alert, owes #{time_bank_balance.abs} hours"
    elsif time_bank_balance < 0
      @hours_ok = true
      set_calculated_status(ACTIVE)
      messages << "Owes #{time_bank_balance.abs} hours"
    else
      @hours_ok = true
      set_calculated_status(ACTIVE)
      messages << "Banked #{time_bank_balance} hours"
    end

    messages << "Last shift #{last_shift}"

    @hours_ok
  end

end

