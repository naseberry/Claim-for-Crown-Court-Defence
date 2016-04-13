# == Schema Information
#
# Table name: fees
#
#  id                    :integer          not null, primary key
#  claim_id              :integer
#  fee_type_id           :integer
#  quantity              :integer
#  amount                :decimal(, )
#  created_at            :datetime
#  updated_at            :datetime
#  uuid                  :uuid
#  rate                  :decimal(, )
#  type                  :string
#  warrant_issued_date   :date
#  warrant_executed_date :date
#  sub_type_id           :integer
#

class Fee::WarrantFee < Fee::BaseFee

  belongs_to :fee_type, class_name: Fee::WarrantFeeType

  validates_with Fee::WarrantFeeValidator

  acts_as_gov_uk_date :warrant_issued_date, :warrant_executed_date

  def is_warrant?
    true
  end

  def self.instance
    Fee::WarrantFee.first
  end

end
