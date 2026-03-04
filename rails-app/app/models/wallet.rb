class Wallet < ApplicationRecord
  TOKEN_TYPES = %w[ghst adai].freeze

  belongs_to :user

  validates :token_type, presence: true, inclusion: { in: TOKEN_TYPES }
  validates :balance, numericality: { greater_than_or_equal_to: 0 }
  validates :token_type, uniqueness: { scope: :user_id }
end
