require 'rails_helper'
require File.dirname(__FILE__) + '/validation_helpers'

describe ClaimDateValidator do

  include ValidationHelpers

  let(:cracked_case_type)                 { FactoryGirl.build :case_type, :requires_cracked_dates, name: "Cracked trial"  }
  let(:cracked_before_retrial_case_type)  { FactoryGirl.build :case_type, :requires_cracked_dates, name: "Cracked before retrial" }
  let(:contempt_case_type)                { FactoryGirl.build :case_type, :requires_trial_dates,    name: 'Contempt'}
  let(:retrial_case_type)                 { FactoryGirl.build :case_type, :retrial}

  let(:claim)                             { FactoryGirl.create :claim }
  let(:cracked_trial_claim) do
    claim = FactoryGirl.create :claim, case_type: cracked_case_type
    nulify_fields_on_record(claim, :trial_fixed_notice_at, :trial_fixed_at, :trial_cracked_at)
  end

  let(:cracked_before_retrial_claim) do
    claim = FactoryGirl.create :claim, case_type: cracked_before_retrial_case_type
    nulify_fields_on_record(claim, :trial_fixed_notice_at, :trial_fixed_at, :trial_cracked_at)
  end

  before do
    claim.force_validation = true
    cracked_trial_claim.force_validation = true
    cracked_before_retrial_claim.force_validation = true
  end

  context 'trial_fixed_notice_at' do
    context 'cracked_trial_claim' do
      it { should_error_if_not_present(cracked_trial_claim, :trial_fixed_notice_at, 'blank_cracked_trial_date') }
      it { should_error_if_in_future(cracked_trial_claim, :trial_fixed_notice_at, 'check_cracked_trial_date') }
      it { should_error_if_too_far_in_the_past(cracked_trial_claim, :trial_fixed_notice_at, 'check_cracked_trial_date') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_trial_claim, :trial_fixed_notice_at, 'check_cracked_trial_date') }
    end

    it 'should error if not present for Cracked before retrial' do
      expect(cracked_before_retrial_claim.valid?).to be false
      expect(cracked_before_retrial_claim.errors[:trial_fixed_notice_at]).to eq( [ 'blank_cracked_before_retrial_date' ])
    end

    it 'should error if in the future' do
      cracked_trial_claim.trial_fixed_notice_at = 3.days.from_now.to_date
      expect(cracked_trial_claim.valid?).to be false
      expect(cracked_trial_claim.errors[:trial_fixed_notice_at]).to eq( [ 'check_cracked_trial_date' ])
    end

    context 'cracked_before_retrial claim' do
      it { should_error_if_not_present(cracked_before_retrial_claim, :trial_fixed_notice_at, 'blank_cracked_before_retrial_date') }
      it { should_error_if_in_future(cracked_before_retrial_claim, :trial_fixed_notice_at, 'check_cracked_before_retrial_date') }
      it { should_error_if_too_far_in_the_past(cracked_before_retrial_claim, :trial_fixed_notice_at, 'check_cracked_before_retrial_date') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_before_retrial_claim, :trial_fixed_notice_at, 'check_cracked_before_retrial_date') }
    end
  end

  context 'trial fixed at' do
    context 'cracked trial claim' do
      it { should_error_if_not_present(cracked_trial_claim, :trial_fixed_at, 'blank_cracked_trial_date') }
      it { should_error_if_too_far_in_the_past(cracked_trial_claim, :trial_fixed_at, 'check_cracked_trial_date') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_trial_claim, :trial_fixed_at, 'check_cracked_trial_date') }
      it { should_error_if_earlier_than_other_date(cracked_trial_claim, :trial_fixed_at, :trial_fixed_notice_at, 'check_cracked_trial_date') }
    end

    context 'cracked before retrial' do
      it { should_error_if_not_present(cracked_before_retrial_claim, :trial_fixed_at, 'blank_cracked_before_retrial_date') }
      it { should_error_if_too_far_in_the_past(cracked_before_retrial_claim, :trial_fixed_at, 'check_cracked_before_retrial_date') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_before_retrial_claim, :trial_fixed_at, 'check_cracked_before_retrial_date') }
      it { should_error_if_earlier_than_other_date(cracked_before_retrial_claim, :trial_fixed_at, :trial_fixed_notice_at, 'check_cracked_before_retrial_date') }
    end
  end

  context 'trial cracked at' do
    context 'cracked trial' do
      it { should_error_if_not_present(cracked_trial_claim, :trial_cracked_at, 'blank_cracked_trial_date') }
      it { should_error_if_in_future(cracked_trial_claim, :trial_cracked_at, 'check_cracked_trial_date') }
      it { should_error_if_too_far_in_the_past(cracked_trial_claim, :trial_cracked_at, 'check_cracked_trial_date') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_trial_claim, :trial_cracked_at, 'check_cracked_trial_date') }
      it { should_error_if_earlier_than_other_date(cracked_trial_claim, :trial_cracked_at, :trial_fixed_notice_at, 'check_cracked_trial_date') }
    end

    context 'cracked before retrial' do
      it { should_error_if_not_present(cracked_before_retrial_claim, :trial_cracked_at, 'blank_cracked_before_retrial_date') }
      it { should_error_if_in_future(cracked_before_retrial_claim, :trial_cracked_at, 'check_cracked_before_retrial_date') }
      it { should_error_if_too_far_in_the_past(cracked_before_retrial_claim, :trial_cracked_at, 'check_cracked_before_retrial_date') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_before_retrial_claim, :trial_cracked_at, 'check_cracked_before_retrial_date') }
      it { should_error_if_earlier_than_other_date(cracked_before_retrial_claim, :trial_cracked_at, :trial_fixed_notice_at, 'check_cracked_before_retrial_date') }
    end
  end

  context 'first day of trial' do
    let(:contempt_claim_with_nil_first_day) { nulify_fields_on_record(FactoryGirl.create(:claim, case_type: contempt_case_type), :first_day_of_trial) }
    before { contempt_claim_with_nil_first_day.force_validation = true }
    it { should_error_if_not_present(contempt_claim_with_nil_first_day, :first_day_of_trial, "blank")  }
    it { should_errror_if_later_than_other_date(contempt_claim_with_nil_first_day, :first_day_of_trial, :trial_concluded_at, "blank") }
    it { should_error_if_earlier_than_earliest_repo_date(contempt_claim_with_nil_first_day, :first_day_of_trial, 'blank') }
    it { should_error_if_too_far_in_the_past(contempt_claim_with_nil_first_day, :first_day_of_trial, 'blank') }
  end

  context 'trial_concluded_at' do
    let(:contempt_claim_with_nil_concluded_at) { nulify_fields_on_record(FactoryGirl.create(:claim, case_type: contempt_case_type), :trial_concluded_at) }
    before { contempt_claim_with_nil_concluded_at.force_validation = true }
    it { should_error_if_not_present(contempt_claim_with_nil_concluded_at, :trial_concluded_at, "blank") }
    it { should_error_if_earlier_than_other_date(contempt_claim_with_nil_concluded_at, :trial_concluded_at, :first_day_of_trial, "blank") }
    it { should_error_if_earlier_than_earliest_repo_date(contempt_claim_with_nil_concluded_at, :trial_concluded_at, 'blank') }
    it { should_error_if_too_far_in_the_past(contempt_claim_with_nil_concluded_at, :trial_concluded_at, 'blank') }
  end

  context 'retrial_started_at' do
    let(:claim) { FactoryGirl.create(:claim, case_type: retrial_case_type) }

    it 'should be present for retrials' do
      should_error_if_not_present(claim, :retrial_started_at, "blank")
    end

    it 'should error if later than retrial_concluded_at' do
      should_errror_if_later_than_other_date(claim, :retrial_started_at, :retrial_concluded_at, "blank")
    end

    it 'should error if earlier than claims earliest repo order date' do
      should_error_if_earlier_than_earliest_repo_date(claim, :retrial_started_at, 'blank')
    end

    it 'should error if too far in the past' do
      should_error_if_too_far_in_the_past(claim, :retrial_started_at, 'blank')
    end

    it 'shoud NOT error if first day of trial is before the claims earliest rep order' do
      stub_earliest_rep_order(claim, 1.month.ago)
      claim.first_day_of_trial = 2.months.ago
      expect(claim.valid?).to be true
      expect(claim.errors[:retrial_started_at]).to be_empty
    end
  end

end
