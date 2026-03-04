class CreateAavegotchis < ActiveRecord::Migration[7.2]
  def change
    create_table :aavegotchis do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.integer :base_rarity_score, null: false
      t.decimal :collateral_value, precision: 20, scale: 8, null: false, default: 0
      t.decimal :claimable_yield, precision: 20, scale: 8, null: false, default: 0
      t.jsonb :traits, default: {}
      t.integer :equipped_wearable_id
      t.timestamps
    end
  end
end
