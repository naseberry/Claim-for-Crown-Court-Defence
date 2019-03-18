module Fee
  class BasicFeeValidator < Fee::BaseFeeValidator
    include Concerns::CaseNumbersValidator

    def self.fields
      %i[
        quantity
        rate
        date
        case_numbers
        discontinuance_ppe_served
      ] + super
    end

    private

    def validate_discontinuance_ppe_served
      return if claim_is_discontinuance?
      add_error(:discontinuance_ppe_served, 'invalid') if discontinuance_claim_has_ppe?
    end

    private

    def claim_is_discontinuance?
      @record.claim.case_type.fee_type_code.eql?('GRDIS')
    end

    def discontinuance_claim_has_ppe?
      @record.discontinuance_ppe_served
    end
  end
end
