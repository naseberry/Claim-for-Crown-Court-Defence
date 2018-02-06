module API
  module Entities
    module CCLF
      class AdaptedExpense < AdaptedBaseBill
        expose :amount, format_with: :string
        expose :vat_amount, format_with: :string

        private

        delegate :bill_type, :bill_subtype, to: :adapter

        def adapter
          @adapter ||= ::CCLF::ExpenseAdapter.new(object)
        end
      end
    end
  end
end
