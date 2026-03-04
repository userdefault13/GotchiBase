module Api
  class WalletsController < ApplicationController
    def index
      user = User.find(params[:id])
      render json: user.wallets
    end
  end
end
