class Fee::FixedFeeTypePresenter < BasePresenter
  presents :fee_type

  def data_attributes
    {
      case_numbers: case_numbers_field?
    }
  end

  private

  def case_numbers_field?
    case_uplift?
  end
end
