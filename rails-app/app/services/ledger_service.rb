class LedgerService
  def initialize(transaction)
    @transaction = transaction
    @aavegotchi = transaction.aavegotchi
    @owner = @aavegotchi.owner
  end

  def record_entries
    case @transaction.action_type
    when "summon"
      # No ledger entries for summon (no money movement)
    when "stake"
      record_stake
    when "unstake"
      record_unstake
    when "claim_yield"
      record_claim_yield
    when "equip"
      # No ledger entries for equip
    end
  end

  private

  def record_stake
    amount = @transaction.amount
    return if amount <= 0

    # Debit: user's aDAI wallet
    create_entry(account_for(:adai, @owner.id), debit: amount, credit: 0)
    # Credit: gotchi collateral
    create_entry(account_for(:gotchi_collateral, @aavegotchi.id), debit: 0, credit: amount)
  end

  def record_unstake
    amount = @transaction.amount
    return if amount <= 0

    # Debit: gotchi collateral
    create_entry(account_for(:gotchi_collateral, @aavegotchi.id), debit: amount, credit: 0)
    # Credit: user's aDAI wallet
    create_entry(account_for(:adai, @owner.id), debit: 0, credit: amount)
  end

  def record_claim_yield
    amount = @transaction.amount
    return if amount <= 0

    # Debit: gotchi yield pool
    create_entry(account_for(:gotchi_yield, @aavegotchi.id), debit: amount, credit: 0)
    # Credit: user's GHST wallet
    create_entry(account_for(:ghst, @owner.id), debit: 0, credit: amount)
  end

  def create_entry(account, debit:, credit:)
    @transaction.ledger_entries.create!(
      account: account,
      debit: debit,
      credit: credit
    )
  end

  def account_for(type, id)
    "#{type}:#{id}"
  end
end
