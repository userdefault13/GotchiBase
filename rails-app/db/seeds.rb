Order.destroy_all
Trade.destroy_all
Transaction.destroy_all
LedgerEntry.destroy_all
Aavegotchi.destroy_all
Wallet.destroy_all
User.destroy_all

5.times do |i|
  user = User.create!(username: "player#{i + 1}")
  Wallet.create!(user: user, token_type: "ghst", balance: 1000)
  Wallet.create!(user: user, token_type: "adai", balance: 1000)

  rand(2..3).times do
    brs = rand(1..1000)
    traits = {
      energy: rand(1..100),
      kinship: rand(1..100),
      experience: rand(1..100),
      spookiness: rand(1..100),
      brain_size: rand(1..100),
      eye_shape: rand(1..100)
    }
    gotchi = Aavegotchi.create!(
      owner: user,
      base_rarity_score: brs,
      collateral_value: 0,
      claimable_yield: 0,
      traits: traits
    )
    Transaction.create!(aavegotchi: gotchi, action_type: :summon, amount: 0)
  end
end

# Seed orderbook: GHST/aDAI around 1.0
users = User.all.to_a
return if users.empty?

# Bids: buy GHST with aDAI (users need aDAI)
[0.95, 0.96, 0.97, 0.98, 0.99].each_with_index do |price, i|
  user = users[i % users.size]
  Order.create!(user: user, side: "bid", order_type: "limit", price: price, amount: 50 + rand(50))
end

# Asks: sell GHST for aDAI (users need GHST)
[1.01, 1.02, 1.03, 1.04, 1.05].each_with_index do |price, i|
  user = users[(i + 2) % users.size] # different users
  Order.create!(user: user, side: "ask", order_type: "limit", price: price, amount: 50 + rand(50))
end

puts "Seeded #{User.count} users, #{Aavegotchi.count} Gotchis, #{Order.count} orders"
