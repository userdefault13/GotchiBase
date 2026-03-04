class User < ApplicationRecord
  has_many :wallets, dependent: :destroy
  has_many :aavegotchis, foreign_key: :owner_id, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :trades_as_buyer, class_name: "Trade", foreign_key: :buyer_id, dependent: :nullify
  has_many :trades_as_seller, class_name: "Trade", foreign_key: :seller_id, dependent: :nullify

  validates :username, presence: true, uniqueness: true
end
