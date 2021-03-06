module API
  module Entities
    module CCLF
      class AdaptedHardshipFee < AdaptedBaseBill
        expose :quantity, format_with: :integer_string
        expose :amount, format_with: :string

        private

        delegate :bill_type, :bill_subtype, to: :adapter

        def adapter
          @adapter ||= ::CCLF::Fee::HardshipFeeAdapter.new(object)
        end
      end
    end
  end
end
