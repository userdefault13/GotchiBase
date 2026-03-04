class CreateWallets < ActiveRecord::Migration[7.2]
  def change
    create_table :wallets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token_type, null: false, default: "ghst"
      t.decimal :balance, precision: 20, scale: 8, null: false, default: 0
      t.timestamps
    end
    add_index :wallets, [:user_id, :token_type], unique: true
  end
end
