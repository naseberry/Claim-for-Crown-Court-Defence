# == Schema Information
#
# Table name: offences
#
#  id               :integer          not null, primary key
#  description      :string
#  offence_class_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

require 'rails_helper'

RSpec.describe OffencesController, type: :controller do
  let!(:scheme_9_offences) {
    [
      create(:offence, :with_fee_scheme, description: 'Offence 1'),
      create(:offence, :with_fee_scheme, description: 'Offence 3'),
      create(:offence, :with_fee_scheme, description: 'Offence 2')
    ]
  }
  let!(:scheme_10_offences) {
    [
      create(:offence, :with_fee_scheme_ten, description: 'Offence 10-1'),
      create(:offence, :with_fee_scheme_ten, description: 'Offence 10-3'),
      create(:offence, :with_fee_scheme_ten, description: 'Offence 10-2')
    ]
  }

  describe 'GET index' do
    it 'should return all offences if no description present' do
      xhr :get, :index
      expect(assigns(:offences).size).to eq 3
      expect(assigns(:offences).map(&:description)).to eq( ['Offence 1', 'Offence 2', 'Offence 3' ])
    end

    it 'should just get the matching offence' do
      xhr :get, :index, {description: 'Offence 3'}
      expect(assigns(:offences).map(&:description)).to eq( [ 'Offence 3'] )
    end

    context 'when fee reform filter is provided' do
      let(:params) { { fee_scheme: 'fee_reform' } }

      it 'returns offences only for fee scheme 10' do
        xhr :get, :index, params
        expect(assigns(:offences).size).to eq 3
        expect(assigns(:offences).map(&:description)).to match_array( ['Offence 10-1', 'Offence 10-3', 'Offence 10-2' ])
      end

      it 'calls the fee reform search offences service with the provided filters' do
        expected_args = { fee_scheme: 'fee_reform', controller: 'offences', action: 'index' }
        expect(FeeReform::SearchOffences).to receive(:call).with(expected_args).and_call_original
        xhr :get, :index, params
      end
    end
  end
end
