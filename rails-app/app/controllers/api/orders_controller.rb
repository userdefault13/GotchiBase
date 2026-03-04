module Api
  class OrdersController < ApplicationController
    before_action :set_order, only: [:destroy]

    def index
      user_id = params[:user_id]
      return render json: { error: "user_id required" }, status: :bad_request if user_id.blank?

      orders = Order.where(user_id: user_id).order(created_at: :desc)
      orders = orders.where(status: params[:status]) if params[:status].present?
      orders = orders.where(side: params[:side]) if params[:side].present?
      orders = orders.limit(params[:limit] || 50)

      render json: orders
    end

    def create
      user_id = order_params[:user_id]
      return render json: { error: "user_id required" }, status: :bad_request if user_id.blank?

      user = User.find_by(id: user_id)
      return render json: { error: "User not found" }, status: :not_found unless user

      order = Order.new(
        user: user,
        side: order_params[:side],
        order_type: order_params[:order_type],
        price: order_params[:price].presence&.to_d,
        amount: order_params[:amount].to_d
      )

      if order.save
        begin
          OrderMatchingService.new(order).match!
        rescue OrderMatchingService::InsufficientBalanceError => e
          order.destroy
          return render json: { error: e.message }, status: :unprocessable_entity
        end
        render json: order.reload, status: :created
      else
        render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      unless @order.open?
        return render json: { error: "Cannot cancel filled or cancelled order" }, status: :unprocessable_entity
      end

      @order.update!(status: "cancelled")
      render json: @order
    end

    private

    def order_params
      params.permit(:user_id, :side, :order_type, :price, :amount)
    end

    def set_order
      @order = Order.find(params[:id])
    end
  end
end
