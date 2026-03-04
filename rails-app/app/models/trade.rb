class Trade < ApplicationRecord
  belongs_to :taker_order, class_name: "Order"
  belongs_to :maker_order, class_name: "Order"
  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"

  validates :price, :amount, numericality: { greater_than: 0 }
end
