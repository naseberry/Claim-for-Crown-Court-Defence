class CaseWorkers::Admin::AllocationsController < CaseWorkers::Admin::ApplicationController
  include PaginationHelpers

  before_action :set_case_workers, only: %i[new create]
  before_action :set_claims, only: %i[new create]
  before_action :process_claim_ids, only: [:create], if: :quantity_allocation?

  def new
    @allocation = Allocation.new
  end

  def create
    @allocation = Allocation.new(allocation_params.merge(current_user: current_user))
    if @allocation.save
      redirect_with_feedback(@allocation)
    else
      render :new
    end
  end

  private

  def redirect_with_feedback(allocation)
    flash[:notice] = notification(allocation)
    redirect_to case_workers_admin_allocations_path(tab: tab, scheme: scheme)
  end

  def quantity_allocation?
    quantity_to_allocate.positive?
  end

  def quantity_to_allocate
    params[:quantity_to_allocate].to_i
  end

  def process_claim_ids
    params[:allocation][:claim_ids] = @claims.first(quantity_to_allocate).map(&:id).map(&:to_s)
  end

  def set_case_workers
    @case_workers = ::CaseWorker.active.includes(:user)
  end

  def set_claims
    return unless tab == 'allocated'
    @claims = Claims::CaseWorkerClaims.new(current_user: current_user, action: tab, criteria: criteria_params).claims
    add_claim_carousel_info
  end

  def scheme
    %w[agfs lgfs].include?(params[:scheme]) ? params[:scheme] : 'agfs'
  end

  def tab
    %w[allocated unallocated].include?(params[:tab]) ? params[:tab] : 'unallocated'
  end

  def filter
    params[:filter] || 'all'
  end

  def value_band_id
    params[:value_band_id] || 0
  end

  def search_terms
    params[:search]
  end

  def allocation_params
    allocator_params = params.require(:allocation).permit(:case_worker_id, :deallocate, claim_ids: [])
    allocator_params.to_h.merge(allocating: is_allocating?)
  end

  def notification(allocation)
    claims = allocation.successful_claims
    case_worker = allocation.case_worker
    message = "#{claims.size} #{'claim'.pluralize(claims.size)}"

    if case_worker
      "#{message} allocated to #{case_worker.name}"
    else
      "#{message} returned to allocation pool"
    end
  end

  def is_allocating?
    params[:commit] == 'Allocate'
  end

  def default_page_size
    25
  end

  def sort_column
    'last_submitted_at'
  end

  def sort_direction
    'asc'
  end

  def criteria_params
    limit = quantity_allocation? ? quantity_to_allocate : page_size
    { sorting: sort_column, direction: sort_direction, scheme: scheme, filter: filter,
      page: current_page, limit: limit, search: search_terms, value_band_id: value_band_id }
  end
end
