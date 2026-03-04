module Api
  class OrderbookController < ApplicationController
    def show
      bids = aggregate_depth(Order.bids.open_orders, :desc)
      asks = aggregate_depth(Order.asks.open_orders, :asc)

      best_bid = bids.first&.first
      best_ask = asks.first&.first
      spread = (best_bid && best_ask) ? (best_ask - best_bid) : nil

      render json: {
        bids: bids,
        asks: asks,
        spread: spread,
        best_bid: best_bid,
        best_ask: best_ask
      }
    end

    private

    def aggregate_depth(scope, sort_dir)
      aggregated = scope.each_with_object(Hash.new(0)) do |o, h|
        rem = o.remaining_amount
        h[o.price] += rem if rem > 0
      end
      sorted = sort_dir == :desc ? aggregated.sort_by { |p, _| -p } : aggregated.sort_by { |p, _| p }
      sorted.first(20).map { |p, s| [p.to_f, s.to_f] }
    end
  end
end
