class Aavegotchi < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :transactions, dependent: :nullify

  validates :base_rarity_score, inclusion: { in: 1..1000 }
  validates :collateral_value, numericality: { greater_than_or_equal_to: 0 }
  validates :claimable_yield, numericality: { greater_than_or_equal_to: 0 }

  def staked?
    collateral_value.positive?
  end
end
