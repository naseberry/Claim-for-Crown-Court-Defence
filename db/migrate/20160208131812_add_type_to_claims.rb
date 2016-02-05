class AddTypeToClaims < ActiveRecord::Migration
  def up
    add_column :claims, :type, :string
    ActiveRecord::Base.connection.execute "UPDATE claims SET type = 'Claim::AdvocateClaim'"
  end

  def remove_column
  	remove_column :claims, :type
  end
end
