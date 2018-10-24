module API
  module Entities
    module CCR
      class AdvocateClaim < BaseEntity
        expose :uuid
        expose :supplier_number
        expose :case_number
        expose  :first_day_of_trial,
                :trial_fixed_notice_at,
                :trial_fixed_at,
                :trial_cracked_at,
                :retrial_started_at,
                :last_submitted_at,
                format_with: :utc
        expose :trial_cracked_at_third

        expose :adapted_advocate_category, as: :advocate_category
        expose :case_type, using: API::Entities::CCR::CaseType
        expose :court, using: API::Entities::CCR::Court
        expose :offence, using: API::Entities::CCR::Offence
        expose :defendants_with_main_first, using: API::Entities::CCR::Defendant, as: :defendants

        expose :retrial_reduction

        with_options(format_with: :string) do
          expose :actual_trial_length_or_one, as: :actual_trial_Length
          expose :estimated_trial_length_or_one, as: :estimated_trial_length
          expose :retrial_actual_length_or_one, as: :retrial_actual_length
          expose :retrial_estimated_length_or_one, as: :retrial_estimated_length
        end

        expose :additional_information

        expose :bills

        private

        def defendants_with_main_first
          object.defendants.order(created_at: :asc)
        end

        def estimated_trial_length_or_one
          object.estimated_trial_length.or_one
        end

        def actual_trial_length_or_one
          object.actual_trial_length.or_one
        end

        def retrial_actual_length_or_one
          object.retrial_actual_length.or_one
        end

        def retrial_estimated_length_or_one
          object.retrial_estimated_length.or_one
        end

        def bills
          data = []
          data.push AdaptedBasicFee.represent(basic_fees)
          data.push AdaptedFixedFee.represent(fixed_fees)
          data.push AdaptedMiscFee.represent(miscellaneous_fees)
          data.push grouped_expenses
          data.flatten.as_json
        end

        def adapted_advocate_category
          ::CCR::AdvocateCategoryAdapter.code_for(object.advocate_category) if object.advocate_category.present?
        end

        def adapted_basic_fee
          @adapted_basic_fee ||= ::CCR::Fee::BasicFeeAdapter.new(object)
        end

        def basic_fees
          adapted_basic_fee.claimed? ? [adapted_basic_fee] : []
        end

        def adapted_fixed_fee
          @adapted_fixed_fee ||= ::CCR::Fee::FixedFeeAdapter.new.call(object)
        end

        def fixed_fees
          adapted_fixed_fee.claimed? ? [adapted_fixed_fee] : []
        end

        def misc_fee_adapter
          ::CCR::Fee::MiscFeeAdapter.new
        end

        # CCR miscellaneous fees cover CCCD basic, fixed and miscellaneous fees
        #
        def miscellaneous_fees
          object.fees.each_with_object([]) do |fee, memo|
            misc_fee_adapter.call(fee).tap do |f|
              memo << f if f.claimed?
            end
          end
        end

        def grouped_expenses
          result = []
          grouped_expenses = object.expenses.group(:expense_type_id).group(:mileage_rate_id).count
          grouped_expenses.each do |key_array, v|
            expense_type_id = key_array[0]
            mileage_rate = key_array[1]
            these_expenses = object.expenses.where(expense_type_id: expense_type_id)
            if v > 10
              # TODO: magic stuff to total group
              temp_array = AdaptedExpense.represent(these_expenses)
              puts "I want to inject a single AdaptedExpense with a combined total quantity of #{temp_array.count} and a rate of #{temp_array.map(&:rate).inject(0, &:+)}"
              injection_attempt = [
                {
                  bill_type: temp_array.first.bill_type,
                  bill_subtype: temp_array.first.bill_subtype,
                  date_incurred: temp_array.first.date_incurred,
                  description: "#{temp_array.first.description} - #{temp_array.count} dates between #{temp_array.first.date_incurred} and #{temp_array.last.date_incurred}",
                  quantity: '1',
                  rate: sprintf('%.2f', temp_array.map(&:rate).inject(0, &:+))
                }]
              result.push injection_attempt
            else
              result.push AdaptedExpense.represent(these_expenses)
            end
          end
          # result.push AdaptedExpense.represent(object.expenses)
          result
        end
      end
    end
  end
end
