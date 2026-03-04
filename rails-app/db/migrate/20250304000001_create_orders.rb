class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :side, null: false
      t.string :order_type, null: false
      t.decimal :price, precision: 20, scale: 8
      t.decimal :amount, precision: 20, scale: 8, null: false
      t.decimal :filled_amount, precision: 20, scale: 8, default: 0, null: false
      t.string :status, null: false, default: "open"

      t.timestamps
    end

    add_index :orders, [:status, :side, :created_at]
    add_index :orders, [:side, :price] # for orderbook queries
  end
end
