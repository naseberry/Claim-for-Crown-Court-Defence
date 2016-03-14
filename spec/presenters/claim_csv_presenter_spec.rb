require 'rails_helper'

RSpec.describe ClaimCsvPresenter do

  let(:claim)               { create(:redetermination_claim) }
  let(:subject)             { ClaimCsvPresenter.new(claim, view) }

  context '#present!' do

    context 'generates a line of CSV for each time a claim passes through the system' do

      context 'with identical values for' do

        it 'case_number' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include(claim.case_number)
            expect(claim_journeys.second).to include(claim.case_number)
          end
        end

        it 'supplier number' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include(claim.supplier_number)
            expect(claim_journeys.second).to include(claim.supplier_number)
          end
        end

        it 'organisation/provider_name' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include(claim.owner.provider.name)
            expect(claim_journeys.second).to include(claim.owner.provider.name)
          end
        end

        it 'case_type' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include(claim.case_type.name)
            expect(claim_journeys.second).to include(claim.case_type.name)
          end
        end

        it 'total (inc VAT)' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include(claim.total_including_vat.to_s)
            expect(claim_journeys.second).to include(claim.total_including_vat.to_s)
          end
        end

      end

      context 'and unique values for' do
        before { Timecop.freeze(Time.now) }
        after  { Timecop.return }

        it 'submission type' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include('new')
            expect(claim_journeys.second).to include('redetermination')
          end
        end

        it 'date submitted' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include((Time.now - 3.day).to_s)
            expect(claim_journeys.second).to include((Time.now).to_s)
          end
        end

        it 'date allocated' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include((Time.now - 2.day).to_s)
            expect(claim_journeys.second).to include('n/a', 'n/a')
          end
        end

        it 'date of last assessment' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include((Time.now - 1.day).to_s)
            expect(claim_journeys.second).to include('n/a', 'n/a')
          end
        end

        it 'current/end state' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include('authorised')
            expect(claim_journeys.second).to include('submitted')
          end
        end

      end

      context 'deallocation' do
        let(:claim) { create(:allocated_claim) }

        before {
          case_worker = claim.case_workers.first
          claim.case_workers.destroy_all; claim.deallocate!
          claim.case_workers << case_worker; claim.allocate!
          claim.case_workers.destroy_all; claim.deallocate!
        }

        it 'should not be reflected in the MI' do
          ClaimCsvPresenter.new(claim, view).present! do |csv|
            expect(csv[0]).not_to include('deallocated')
          end
        end

        it 'and the claim should be refelcted as being in the state prior to allocation' do
          ClaimCsvPresenter.new(claim, view).present! do |csv|
            expect(csv[0]).to include('submitted')
          end
        end
      end
    end
  end
end
