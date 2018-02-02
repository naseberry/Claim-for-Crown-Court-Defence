module API
  module Entities
    module CCLF
      class AdaptedMiscFee < AdaptedBaseFee
        expose :bill_scenario
        expose :amount, format_with: :string

        private

        delegate :bill_type, :bill_subtype, :bill_scenario, to: :adapter

        def adapter
          @adapter ||= ::CCLF::Fee::MiscFeeAdapter.new(object)
        end
      end
    end
  end
end