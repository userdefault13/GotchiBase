class Transaction < ApplicationRecord
  ACTION_TYPES = {
    summon: 0,
    stake: 1,
    unstake: 2,
    claim_yield: 3,
    equip: 4
  }.freeze

  belongs_to :aavegotchi
  has_many :ledger_entries, dependent: :destroy

  enum :action_type, ACTION_TYPES

  after_create :update_balances

  private

  def update_balances
    LedgerService.new(self).record_entries
  end
end
