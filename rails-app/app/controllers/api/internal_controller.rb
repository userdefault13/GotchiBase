module Api
  class InternalController < ApplicationController
    def staked_gotchis
      gotchis = Aavegotchi.where("collateral_value > 0").select(:id, :owner_id, :collateral_value, :claimable_yield)
      render json: gotchis
    end

    def apply_yield
      gotchi = Aavegotchi.find(params[:gotchi_id])
      amount = params[:amount].to_s.to_d
      return render json: { error: "Invalid amount" }, status: :unprocessable_entity if amount <= 0

      gotchi.update!(claimable_yield: gotchi.claimable_yield + amount)
      render json: { ok: true, gotchi_id: gotchi.id, new_claimable: gotchi.claimable_yield }
    end
  end
end
