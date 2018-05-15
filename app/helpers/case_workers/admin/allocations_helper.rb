module CaseWorkers::Admin::AllocationsHelper
  def allocation_scheme_filters
    %w[agfs lgfs]
  end

  def allocation_filters_for_scheme(scheme)
    {
      'agfs' => %w[all fixed_fee cracked trial guilty_plea redetermination awaiting_written_reasons disk_evidence],
      'lgfs' => %w[all fixed_fee graduated_fees interim_fees warrants interim_disbursements
                   risk_based_bills redetermination awaiting_written_reasons disk_evidence]
    }[scheme.to_s] || []
  end

  def owner_column_header
    params[:scheme].blank? || params[:scheme] == 'agfs' ? I18n.t('common.advocate') : I18n.t('common.litigator')
  end
end
