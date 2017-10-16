require 'rails_helper'
require 'spec_helper'

describe API::Entities::CCR::AdaptedAdvocateFee do
  subject(:response) { JSON.parse(described_class.represent(adapted_advocate_fee).to_json).deep_symbolize_keys }

  let(:claim) { create(:authorised_claim) }
  let(:case_type) { instance_double('case_type', fee_type_code: 'GRTRL')}
  let(:adapted_advocate_fee) { ::CCR::Fee::AdvocateFeeAdapter.new.call(claim) }

  before do
    allow(claim).to receive(:case_type).and_return case_type
  end

  it 'has expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'AGFS_FEE',
      bill_subtype: 'AGFS_FEE',
      quantity: '1.0',
      rate: '0.0',
      amount: '0.0',
      ppe: '0',
      number_of_witnesses: '0',
      number_of_cases: '1',
      daily_attendances: '0',
      case_numbers: nil
    )
  end
end