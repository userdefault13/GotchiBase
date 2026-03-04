class Order < ApplicationRecord
  belongs_to :user
  has_many :trades_as_taker, class_name: "Trade", foreign_key: :taker_order_id, dependent: :nullify
  has_many :trades_as_maker, class_name: "Trade", foreign_key: :maker_order_id, dependent: :nullify

  SIDES = %w[bid ask].freeze
  TYPES = %w[limit market].freeze
  STATUSES = %w[open partial filled cancelled].freeze

  validates :side, presence: true, inclusion: { in: SIDES }
  validates :order_type, presence: true, inclusion: { in: TYPES }
  validates :amount, numericality: { greater_than: 0 }
  validates :price, numericality: { greater_than: 0 }, allow_nil: true
  validates :status, inclusion: { in: STATUSES }
  validate :price_required_for_limit

  scope :open_orders, -> { where(status: %w[open partial]) }
  scope :bids, -> { where(side: "bid") }
  scope :asks, -> { where(side: "ask") }
  scope :best_bids, -> { bids.open_orders.order(price: :desc) }
  scope :best_asks, -> { asks.open_orders.order(price: :asc) }

  def remaining_amount
    amount - filled_amount
  end

  def filled?
    status == "filled"
  end

  def open?
    status == "open" || status == "partial"
  end

  private

  def price_required_for_limit
    if order_type == "limit" && price.blank?
      errors.add(:price, "is required for limit orders")
    end
  end
end
