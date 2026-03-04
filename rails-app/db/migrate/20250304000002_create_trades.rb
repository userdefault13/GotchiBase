class CreateTrades < ActiveRecord::Migration[7.2]
  def change
    create_table :trades do |t|
      t.references :taker_order, null: false, foreign_key: { to_table: :orders }
      t.references :maker_order, null: false, foreign_key: { to_table: :orders }
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.decimal :price, precision: 20, scale: 8, null: false
      t.decimal :amount, precision: 20, scale: 8, null: false

      t.timestamps
    end

    add_index :trades, :created_at
  end
end
