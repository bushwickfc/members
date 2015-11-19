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
      self.status = "active" if status.blank?
    end
    @can_shop_bool
  end

  def a_member?
    !(status == "volunteer" || status == "interested" || join_date.blank?)
  end

  def check_status
    return @status_ok unless @status_ok.nil?

    if !a_member?
      @status_ok = false
      messages << "Not a member"

    # enforce suspended status, if their hours warrant it, or reprocess them
    elsif (status == "suspended" && (time_bank_balance <= -8.25 || membership_fees_overdue)) || 
           status == "canceled" || status == "inactive"
      @status_ok = false
      messages << "#{status.capitalize} membership"

    elsif status == "hold" || !hold.blank?
      if hold.blank?
        self.status = nil
        @status_ok = check_status
      else
        @status_ok = false
        messages << "On hold until #{hold}"
        self.status = "hold"
      end

    elsif status == "parental" || !parental.blank?
      if parental.blank?
        self.status = nil
        @status_ok = check_status
      else
        @status_ok = true
        messages << "On parental leave until #{parental}"
        self.status = "parental"
      end

    elsif status == "work_alert"
      @status_ok = true
      self.status = "work_alert"

    elsif (status == "suspended" && time_bank_balance > -8.25 && !membership_fees_overdue) ||
           status == "active" || status.blank?
      @status_ok = true
      self.status = "active"

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
      self.status = "inactive"
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
      self.status = "inactive"
      messages << "Inactive, owes 16+ hours"
    elsif time_bank_balance > -16 && time_bank_balance <= -8.25
      @hours_ok = false
      self.status = "suspended"
      messages << "Suspended, owes #{time_bank_balance.abs} hours"
    elsif time_bank_balance < -4
      @hours_ok = true
      self.status = "work_alert"
      messages << "Work alert, owes #{time_bank_balance.abs} hours"
    elsif time_bank_balance < 0
      @hours_ok = true
      messages << "Owes #{time_bank_balance.abs} hours"
    else
      @hours_ok = true
      messages << "Banked #{time_bank_balance} hours"
    end

    messages << "Last shift #{last_shift}" if last_shift

    @hours_ok
  end

end

