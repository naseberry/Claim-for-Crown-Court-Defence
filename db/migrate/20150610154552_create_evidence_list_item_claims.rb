class CreateEvidenceListItemClaims < ActiveRecord::Migration[4.2]
  def change
    create_table :evidence_list_item_claims do |t|
      t.belongs_to :claim, null: false, index: true
      t.belongs_to :evidence_list_item, null: false, index: true

      t.timestamps null: true
    end

    add_index :evidence_list_item_claims,
							[:claim_id,:evidence_list_item_id],
							unique: true,
							name: 'evidence_list_item_claims_claim_id_evidence_list_item_id'
  end
end
