module Api
  class UsersController < ApplicationController
    def find
      user = User.find_by(username: params[:username])
      if user
        render json: user
      else
        render json: { error: "User not found" }, status: :not_found
      end
    end

    def create
      user = User.new(user_params)
      if user.save
        create_initial_wallets(user)
        render json: user, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:username)
    end

    def create_initial_wallets(user)
      Wallet.create!(user: user, token_type: "ghst", balance: 1000)
      Wallet.create!(user: user, token_type: "adai", balance: 1000)
    end
  end
end
