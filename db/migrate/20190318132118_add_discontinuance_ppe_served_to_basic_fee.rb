class AddDiscontinuancePpeServedToBasicFee < ActiveRecord::Migration[5.1]
  def change
    add_column :fees, :discontinuance_ppe_served, :boolean, default: false
  end
end

