require 'rails_helper'

RSpec.describe CaseWorkers::Admin::AllocationsController, type: :controller do
  let(:admin_case_worker) { create(:case_worker, :admin) }

  before { sign_in(admin_case_worker.user) }

  describe 'POST #create' do
    let(:case_worker) { create(:case_worker) }
    let(:commit_action) { 'Allocate' }
    let(:allocating) { true }
    let(:create_allocation_params) {
      {
        allocation: {
          case_worker_id: case_worker.id,
          claim_ids: ['4', ''],
        },
        commit: commit_action
      }
    }
    let(:case_worker_claims_instance) { double(Claims::CaseWorkerClaims, claims: claims_collection) }
    let(:claims_collection) { double(Remote::Claim, remote?: true, first: double('page of claims', map: [1, 3, 4])) }
    let(:allocation) { double(Allocation, successful_claims: 'successful_claims_collection', case_worker: case_worker) }

    let(:expected_params) {
      {
        'case_worker_id' => case_worker.id.to_s,
        'claim_ids' => [ '4', '' ],
        'allocating' => allocating
      }
    }
    let(:expected_params_with_user) {
      {
        'case_worker_id' => case_worker.id.to_s,
        'claim_ids' => [ '4', '' ],
        'allocating' => allocating,
        'current_user' => admin_case_worker.user
      }
    }

    before do
      expect(Allocation).to receive(:new).with(expected_params)
      expect(Allocation).to receive(:new).with(expected_params_with_user).and_return(allocation)
    end

    context 'when the allocation is successful' do
      it 'redirects to allocation page' do
        expect(allocation).to receive(:save).and_return(true)
        post :create, params: create_allocation_params
        expect(response).to redirect_to(case_workers_admin_allocations_path(tab: 'unallocated', scheme: 'agfs'))
      end
    end

    context 'when the allocation failed' do
      it 'renders new' do
        expect(allocation).to receive(:save).and_return(false)
        post :create, params: create_allocation_params
        expect(response).to render_template(:new)
      end
    end

    context 'when tab is "allocated"' do
      let(:tab) { 'allocated' }
      let(:commit_action) { 'Re-allocate' }
      let(:allocating) { false }
      let(:create_allocation_params) {
        {
          allocation: {
            case_worker_id: case_worker.id,
            claim_ids: ['4', ''],
          },
          tab: tab,
          commit: commit_action
        }
      }

      before do
        expect(Claims::CaseWorkerClaims).to receive(:new).and_return(case_worker_claims_instance)
      end

      context 'when the allocation is successful' do
        it 'redirects to allocation page' do
          expect(allocation).to receive(:save).and_return(true)
          post :create, params: create_allocation_params
          expect(response).to redirect_to(case_workers_admin_allocations_path(tab: tab, scheme: 'agfs'))
        end
      end

      context 'when the allocation failed' do
        it 'renders new' do
          expect(allocation).to receive(:save).and_return(false)
          post :create, params: create_allocation_params
          expect(response).to render_template(:new)
        end
      end

      context 'and is a deallocation' do
        let(:create_allocation_params) {
          {
            allocation: {
              deallocate: true,
              case_worker_id: case_worker.id,
              claim_ids: ['4', ''],
            },
            tab: tab,
            commit: commit_action
          }
        }
        let(:expected_params) {
          {
            'case_worker_id' => case_worker.id.to_s,
            'deallocate' => 'true',
            'claim_ids' => [ '4', '' ],
            'allocating' => allocating
          }
        }
        let(:expected_params_with_user) {
          {
            'case_worker_id' => case_worker.id.to_s,
            'deallocate' => 'true',
            'claim_ids' => [ '4', '' ],
            'allocating' => allocating,
            'current_user' => admin_case_worker.user
          }
        }

        context 'when the deallocation is successful' do
          it 'redirects to allocation page' do
            expect(allocation).to receive(:save).and_return(true)
            post :create, params: create_allocation_params
            expect(response).to redirect_to(case_workers_admin_allocations_path(tab: tab, scheme: 'agfs'))
          end
        end

        context 'when the deallocation failed' do
          it 'renders new' do
            expect(allocation).to receive(:save).and_return(false)
            post :create, params: create_allocation_params
            expect(response).to render_template(:new)
          end
        end
      end
    end
  end

  describe 'GET #new' do
    let(:active_case_workers) { ::CaseWorker.active }

    it 'assigns only the active case workers' do
      expect(Claims::CaseWorkerClaims).not_to receive(:new)

      get :new

      expect(assigns(:case_workers)).to match_array(active_case_workers)
      expect(assigns(:claims)).to be_nil
    end

    context 'when tab is "allocated"' do
      let(:tab) { 'allocated' }
      let(:standard_allocation_params) {
        {
          sorting: 'last_submitted_at',
          direction: 'asc',
          scheme: 'agfs',
          filter: 'all',
          page: 0,
          limit: 25,
          search: nil,
          value_band_id: 0
        }
      }
      let(:mock_claim_1) { double('MockClaim', id: 1) }
      let(:mock_claim_2) { double('MockClaim', id: 2) }
      let(:claims_collection) { double('claims collection', remote?: true, first: [ mock_claim_1, mock_claim_2 ] ) }

      it 'assigns the active case workers and the list of allocated claims' do
        claims_service = double(Claims::CaseWorkerClaims)
        expect(Claims::CaseWorkerClaims)
          .to receive(:new)
          .with(
            current_user: admin_case_worker.user,
            action: tab,
            criteria: standard_allocation_params)
          .and_return(claims_service)
        expect(claims_service).to receive(:claims).and_return(claims_collection)

        get :new, params: { tab: tab }

        expect(assigns(:case_workers)).to match_array(active_case_workers)
        expect(assigns(:claims)).to eq claims_collection
      end
    end
  end
end
