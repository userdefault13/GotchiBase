module Api
  class TradesController < ApplicationController
    def index
      limit = [params[:limit].to_i, 100].clamp(1, 100)
      trades = Trade.order(created_at: :desc).limit(limit)

      render json: trades.map { |t|
        {
          id: t.id,
          price: t.price.to_f,
          amount: t.amount.to_f,
          created_at: t.created_at.iso8601,
          buyer_id: t.buyer_id,
          seller_id: t.seller_id,
          side: "buy"
        }
      }
    end
  end
end
