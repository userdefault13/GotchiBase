require 'sinatra'
require 'pg'
require 'json'

set :bind, '0.0.0.0'
set :port, 4567

def db_conn
  @db_conn ||= PG.connect(ENV.fetch('DATABASE_URL', 'postgres://postgres:password@localhost:5433/gotchi_forge'))
end

before do
  content_type :json
end

get '/' do
  { status: 'ok', service: 'sinatra-reports' }.to_json
end

get '/leaderboard/rarity' do
  results = db_conn.exec_params(
    'SELECT id, owner_id, base_rarity_score, collateral_value FROM aavegotchis ORDER BY base_rarity_score DESC LIMIT 10'
  )
  results.map do |r|
    {
      id: r['id'].to_i,
      owner_id: r['owner_id'].to_i,
      base_rarity_score: r['base_rarity_score'].to_i,
      collateral_value: r['collateral_value'].to_f
    }
  end.to_json
end

get '/leaderboard/yield' do
  results = db_conn.exec_params(
    'SELECT a.id, a.owner_id, a.claimable_yield, a.collateral_value FROM aavegotchis a WHERE a.claimable_yield > 0 OR a.collateral_value > 0 ORDER BY a.claimable_yield DESC LIMIT 10'
  )
  results.map do |r|
    {
      id: r['id'].to_i,
      owner_id: r['owner_id'].to_i,
      claimable_yield: r['claimable_yield'].to_f,
      collateral_value: r['collateral_value'].to_f
    }
  end.to_json
end

get '/dashboard' do
  total_staked = db_conn.exec_params('SELECT COALESCE(SUM(collateral_value), 0) as v FROM aavegotchis').first['v'].to_f
  total_yield = db_conn.exec_params('SELECT COALESCE(SUM(claimable_yield), 0) as v FROM aavegotchis').first['v'].to_f
  user_count = db_conn.exec_params('SELECT COUNT(*) as c FROM users').first['c'].to_i
  gotchi_count = db_conn.exec_params('SELECT COUNT(*) as c FROM aavegotchis').first['c'].to_i

  {
    total_staked: total_staked,
    total_claimable_yield: total_yield,
    user_count: user_count,
    gotchi_count: gotchi_count
  }.to_json
end
