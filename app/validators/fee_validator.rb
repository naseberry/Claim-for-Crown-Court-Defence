class FeeValidator < BaseClaimValidator

  def self.fields
    [
      :fee_type,
      :quantity,
      :rate
    ]
  end

  def self.mandatory_fields
    [:claim]
  end

  private

  def validate_claim
    validate_presence(:claim, 'blank')
  end

  def validate_fee_type
    validate_presence(:fee_type, 'blank')
  end

  def validate_quantity
    @actual_trial_length = @record.try(:claim).try(:actual_trial_length) || 0

    case @record.fee_type.try(:code)
      when 'BAF'
        validate_baf_quantity
      when 'DAF'
        validate_daily_attendance_3_40_quantity
      when 'DAH'
        validate_daily_attendance_41_50_quantity
      when 'DAJ'
        validate_daily_attendance_51_plus_quantity
      when 'PCM'
        validate_pcm_quantity
    end

    validate_any_quantity

  end

  def validate_baf_quantity
    validate_numericality(:quantity, 0, 1, 'baf_qty_numericality')
  end

  # cannot claim this fee if trial lasted less than 3 days
  # can only claim a maximum of 38 (or trial length after first 2 days deducted)
  def validate_daily_attendance_3_40_quantity
    return if @record.quantity == 0
    add_error(:quantity, 'daf_qty_mismatch') if @actual_trial_length < 3 || @record.quantity > [38, @actual_trial_length - 2].min
  end

  # cannot claim this fee if trial lasted less than 41 days
  # can only claim a maximum of 10 (or trial length after first 40 days deducted)
  def validate_daily_attendance_41_50_quantity
    return if @record.quantity == 0
    add_error(:quantity, 'dah_qty_mismatch') if @actual_trial_length < 41 || @record.quantity > [10, @actual_trial_length - 40].min
  end

  # cannot claim this fee if trial lasted less than 51 days
  # can only claim a maximum of trial length after first 50 days deducted
  def validate_daily_attendance_51_plus_quantity
    return if @record.quantity == 0
    add_error(:quantity, 'daj_qty_mismatch') if @actual_trial_length < 51 || @record.quantity > @actual_trial_length - 50
  end

  def validate_pcm_quantity
    if @record.claim.case_type.try(:allow_pcmh_fee_type?)
      add_error(:quantity, 'pcm_numericality') if @record.quantity > 3
    else
      add_error(:quantity, 'pcm_not_applicable') unless (@record.quantity == 0 || @record.quantity.blank?)
    end
  end

  def validate_any_quantity
    add_error(:quantity, 'invalid') if @record.quantity < 0 || @record.quantity > 99999
  end

  def validate_rate
    # TODO: this return should be removed once those claims (on gamma/beta-testing) created prior to rate being reintroduced
    #       have been deleted/archived.
    return if @record.is_before_rate_reintroduced?

    fee_code = @record.fee_type.try(:code)
    case fee_code
      when "BAF", "DAF", "DAH", "DAJ", "SAF", "PCM", "CAV", "NDR", "NOC", "NPW", "PPE"
        validate_basic_fee_rate(fee_code)
      else
        validate_any_quantity_rate_combination
    end
  end

  # if one has a value and the other doesn't then we add error to the one that does NOT have a value
  def validate_any_quantity_rate_combination
    if @record.quantity > 0 && @record.rate <= 0
      add_error(:rate, 'invalid')
    elsif @record.quantity <= 0 && @record.rate > 0
      add_error(:quantity, 'invalid')
    end
  end

  # if one has a value and the other doesn't then we add error to the one that does NOT have a value
  # NOTE: we have specific error messages for basic fees
  def validate_basic_fee_rate(case_type)
    if @record.quantity > 0 && @record.rate <=0
      add_error(:rate, "#{case_type.downcase}_invalid")
    elsif @record.quantity <= 0 && @record.rate > 0
      add_error(:quantity, "#{case_type.downcase}_invalid")
    end
  end

end

