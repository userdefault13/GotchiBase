class CreateLedgerEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :ledger_entries do |t|
      t.references :transaction, null: false, foreign_key: true
      t.string :account, null: false
      t.decimal :debit, precision: 20, scale: 8, null: false, default: 0
      t.decimal :credit, precision: 20, scale: 8, null: false, default: 0
      t.timestamps
    end
    add_index :ledger_entries, :account
  end
end
