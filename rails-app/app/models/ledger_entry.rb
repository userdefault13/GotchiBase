class LedgerEntry < ApplicationRecord
  belongs_to :aavegotchi_transaction, class_name: "Transaction", foreign_key: :transaction_id

  validates :account, presence: true
  validates :debit, numericality: { greater_than_or_equal_to: 0 }
  validates :credit, numericality: { greater_than_or_equal_to: 0 }
end
