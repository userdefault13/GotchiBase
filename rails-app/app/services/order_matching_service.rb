# frozen_string_literal: true

class OrderMatchingService
  class InsufficientBalanceError < StandardError; end

  def initialize(order)
    @order = order
    @remaining = order.amount - order.filled_amount
    @filled_this_run = 0
  end

  def match!
    return if @remaining <= 0
    return if @order.status == "cancelled"

    ActiveRecord::Base.transaction do
      if @order.side == "bid"
        match_bid
      else
        match_ask
      end
    end
  end

  private

  def match_bid
    makers = Order.asks.open_orders.order(price: :asc)
    makers = makers.where("price <= ?", @order.price) if @order.order_type == "limit" && @order.price.present?

    makers.each do |maker|
      break if @remaining <= 0

      fill_amount = [@remaining, maker.remaining_amount].min
      fill_price = maker.price
      cost = fill_price * fill_amount

      buyer_adai = @order.user.wallets.find_by(token_type: "adai")
      raise InsufficientBalanceError, "Insufficient aDAI" if buyer_adai.nil? || buyer_adai.balance < cost

      seller_ghst = maker.user.wallets.find_by(token_type: "ghst")
      raise InsufficientBalanceError, "Seller insufficient GHST" if seller_ghst.nil? || seller_ghst.balance < fill_amount

      execute_trade(taker: @order, maker: maker, buyer: @order.user, seller: maker.user, price: fill_price, amount: fill_amount)

      update_order_status(maker, fill_amount)
      @remaining -= fill_amount
      @filled_this_run += fill_amount
    end

    update_order_status(@order, @filled_this_run)
  end

  def match_ask
    makers = Order.bids.open_orders.order(price: :desc)
    makers = makers.where("price >= ?", @order.price) if @order.order_type == "limit" && @order.price.present?

    makers.each do |maker|
      break if @remaining <= 0

      fill_amount = [@remaining, maker.remaining_amount].min
      fill_price = maker.price
      cost = fill_price * fill_amount

      seller_ghst = @order.user.wallets.find_by(token_type: "ghst")
      raise InsufficientBalanceError, "Insufficient GHST" if seller_ghst.nil? || seller_ghst.balance < fill_amount

      buyer_adai = maker.user.wallets.find_by(token_type: "adai")
      raise InsufficientBalanceError, "Buyer insufficient aDAI" if buyer_adai.nil? || buyer_adai.balance < cost

      execute_trade(taker: @order, maker: maker, buyer: maker.user, seller: @order.user, price: fill_price, amount: fill_amount)

      update_order_status(maker, fill_amount)
      @remaining -= fill_amount
      @filled_this_run += fill_amount
    end

    update_order_status(@order, @filled_this_run)
  end

  def execute_trade(taker:, maker:, buyer:, seller:, price:, amount:)
    cost = price * amount

    Trade.create!(
      taker_order: taker,
      maker_order: maker,
      buyer: buyer,
      seller: seller,
      price: price,
      amount: amount
    )

    buyer_ghst = buyer.wallets.find_by!(token_type: "ghst")
    buyer_adai = buyer.wallets.find_by!(token_type: "adai")
    seller_ghst = seller.wallets.find_by!(token_type: "ghst")
    seller_adai = seller.wallets.find_by!(token_type: "adai")

    buyer_adai.update!(balance: buyer_adai.balance - cost)
    buyer_ghst.update!(balance: buyer_ghst.balance + amount)
    seller_adai.update!(balance: seller_adai.balance + cost)
    seller_ghst.update!(balance: seller_ghst.balance - amount)
  end

  def update_order_status(order, fill_amount)
    return if fill_amount <= 0

    new_filled = order.filled_amount + fill_amount
    status = new_filled >= order.amount ? "filled" : "partial"
    order.update!(filled_amount: new_filled, status: status)
  end
end
