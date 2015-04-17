class Fee < ActiveRecord::Base
  belongs_to :fee_category

  has_many :claim_fees, dependent: :destroy
  has_many :claims, through: :claim_fees

  validates :fee_category, presence: true
  validates :description, presence: true, uniqueness: { case_sensitive: false }
  validates :code, presence: true, uniqueness: { case_sensitive: false }
end
