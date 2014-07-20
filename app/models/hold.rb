class Hold < Furlough
  MINIMUM_HOLD = 30

  validate :hold_length_valid

  def hold_length_valid
    if finish - start < MINIMUM_HOLD
      errors.add(:start, "Hold must be at least 1 month")
      false
    end
  end

end
