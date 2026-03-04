class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.references :aavegotchi, null: false, foreign_key: true
      t.integer :action_type, null: false
      t.decimal :amount, precision: 20, scale: 8, default: 0
      t.jsonb :metadata, default: {}
      t.timestamps
    end
  end
end
