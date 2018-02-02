module API
  module Entities
    module CCLF
      class FinalClaim < BaseClaim
        # TODO: WIP - all bills must be addeded
        def bills
          data = []
          data.push AdaptedFixedFee.represent(object.fixed_fee)
          data.push AdaptedGraduatedFee.represent(object.graduated_fee)
          data.push AdaptedMiscFee.represent(object.misc_fees)
          # data.push API::Entities::CCLF::AdaptedDisbursments.represent(object.disbursements)
          # data.push API::Entities::CCLF::AdaptedExpense.represent(object.expenses)
          data.push AdaptedWarrantFee.represent(object.warrant_fee)
          data.as_json.flat_select { |bill| bill[:bill_type].present? }
        end
      end
    end
  end
end