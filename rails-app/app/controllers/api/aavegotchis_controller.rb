module Api
  class AavegotchisController < ApplicationController
    before_action :set_aavegotchi, only: [:show, :stake, :unstake, :claim, :equip]

    def summon
      user = User.find(params[:user_id])
      gotchi = create_aavegotchi(user)
      Transaction.create!(aavegotchi: gotchi, action_type: :summon, amount: 0)
      render json: gotchi, status: :created
    end

    def index
      user = User.find(params[:id])
      render json: user.aavegotchis
    end

    def show
      render json: @aavegotchi
    end

    def stake
      amount = params[:amount]&.to_d || 0
      return render json: { error: "Amount required" }, status: :unprocessable_entity if amount <= 0

      wallet = @aavegotchi.owner.wallets.find_by!(token_type: "adai")
      return render json: { error: "Insufficient balance" }, status: :unprocessable_entity if wallet.balance < amount

      ActiveRecord::Base.transaction do
        Transaction.create!(aavegotchi: @aavegotchi, action_type: :stake, amount: amount)
        wallet.update!(balance: wallet.balance - amount)
        @aavegotchi.update!(collateral_value: @aavegotchi.collateral_value + amount)
      end
      render json: @aavegotchi.reload
    end

    def unstake
      amount = params[:amount]&.to_d || @aavegotchi.collateral_value
      return render json: { error: "Nothing to unstake" }, status: :unprocessable_entity if amount <= 0
      return render json: { error: "Exceeds staked amount" }, status: :unprocessable_entity if amount > @aavegotchi.collateral_value

      wallet = @aavegotchi.owner.wallets.find_by!(token_type: "adai")

      ActiveRecord::Base.transaction do
        Transaction.create!(aavegotchi: @aavegotchi, action_type: :unstake, amount: amount)
        wallet.update!(balance: wallet.balance + amount)
        @aavegotchi.update!(collateral_value: @aavegotchi.collateral_value - amount)
      end
      render json: @aavegotchi.reload
    end

    def claim
      amount = @aavegotchi.claimable_yield
      return render json: { error: "No yield to claim" }, status: :unprocessable_entity if amount <= 0

      wallet = @aavegotchi.owner.wallets.find_by!(token_type: "ghst")

      ActiveRecord::Base.transaction do
        Transaction.create!(aavegotchi: @aavegotchi, action_type: :claim_yield, amount: amount)
        wallet.update!(balance: wallet.balance + amount)
        @aavegotchi.update!(claimable_yield: 0)
      end
      render json: @aavegotchi.reload
    end

    def equip
      wearable_id = params[:wearable_id]&.to_i
      @aavegotchi.update!(equipped_wearable_id: wearable_id)
      Transaction.create!(aavegotchi: @aavegotchi, action_type: :equip, amount: 0, metadata: { wearable_id: wearable_id })
      render json: @aavegotchi.reload
    end

    private

    def set_aavegotchi
      @aavegotchi = Aavegotchi.find(params[:id])
    end

    def create_aavegotchi(user)
      brs = rand(1..1000)
      traits = {
        energy: rand(1..100),
        kinship: rand(1..100),
        experience: rand(1..100),
        spookiness: rand(1..100),
        brain_size: rand(1..100),
        eye_shape: rand(1..100)
      }
      Aavegotchi.create!(
        owner: user,
        base_rarity_score: brs,
        collateral_value: 0,
        claimable_yield: 0,
        traits: traits
      )
    end
  end
end
