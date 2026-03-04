import { useState, useEffect } from 'react';
import { api } from '../api';

export default function Gotchis({ user }) {
  const [gotchis, setGotchis] = useState([]);
  const [loading, setLoading] = useState(true);
  const [summoning, setSummoning] = useState(false);
  const [staking, setStaking] = useState(null);
  const [unstaking, setUnstaking] = useState(null);
  const [claiming, setClaiming] = useState(null);

  const load = async () => {
    if (!user) return;
    try {
      const g = await api.gotchis.index(user.id);
      setGotchis(g);
    } catch {
      // ignore
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, [user?.id]);

  const handleSummon = async () => {
    if (!user) return;
    setSummoning(true);
    try {
      await api.gotchis.summon(user.id);
      load();
    } catch (err) {
      alert(err.message || 'Summon failed');
    } finally {
      setSummoning(false);
    }
  };

  const handleStake = async (id, amount) => {
    setStaking(id);
    try {
      await api.gotchis.stake(id, amount);
      load();
    } catch (err) {
      alert(err.message || 'Stake failed');
    } finally {
      setStaking(null);
    }
  };

  const handleUnstake = async (id, amount) => {
    setUnstaking(id);
    try {
      await api.gotchis.unstake(id, amount);
      load();
    } catch (err) {
      alert(err.message || 'Unstake failed');
    } finally {
      setUnstaking(null);
    }
  };

  const handleClaim = async (id) => {
    setClaiming(id);
    try {
      await api.gotchis.claim(id);
      load();
    } catch (err) {
      alert(err.message || 'Claim failed');
    } finally {
      setClaiming(null);
    }
  };

  if (!user) {
    return (
      <div className="space-y-6">
        <h1 className="text-2xl font-bold">Gotchis</h1>
        <p className="text-[var(--text-secondary)]">Log in to view and manage your Gotchis</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Gotchis</h1>
      <div className="flex gap-4 items-center">
        <button
          onClick={handleSummon}
          disabled={summoning}
          className="px-6 py-3 bg-[var(--accent-blue)] text-white font-semibold rounded-lg hover:opacity-90 disabled:opacity-50"
        >
          {summoning ? 'Summoning...' : 'Summon Gotchi'}
        </button>
      </div>
      {loading ? (
        <p className="text-[var(--text-secondary)]">Loading...</p>
      ) : gotchis.length === 0 ? (
        <p className="text-[var(--text-secondary)]">No Gotchis yet. Summon one!</p>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {gotchis.map((g) => (
            <div
              key={g.id}
              className="p-6 bg-[var(--bg-card)] rounded-xl border border-[var(--border)]"
            >
              <h3 className="font-semibold text-lg">Gotchi #{g.id}</h3>
              <p className="text-sm text-[var(--text-secondary)] mt-1">
                BRS: {g.base_rarity_score}
              </p>
              <p className="text-sm mt-2">
                Staked: {Number(g.collateral_value || 0).toFixed(2)} aDAI
              </p>
              <p className="text-sm">
                Claimable: {Number(g.claimable_yield || 0).toFixed(2)} GHST
              </p>
              <div className="mt-4 flex flex-wrap gap-2">
                <input
                  type="number"
                  placeholder="Stake amount"
                  className="w-24 px-2 py-1 bg-[var(--bg-dark)] border border-[var(--border)] rounded text-sm"
                  id={`stake-${g.id}`}
                />
                <button
                  onClick={() => {
                    const inp = document.getElementById(`stake-${g.id}`);
                    handleStake(g.id, inp?.value || 0);
                  }}
                  disabled={staking === g.id}
                  className="px-3 py-1 bg-[var(--accent-green)] text-black text-sm rounded hover:opacity-90 disabled:opacity-50"
                >
                  Stake
                </button>
                {(g.collateral_value || 0) > 0 && (
                  <button
                    onClick={() => handleUnstake(g.id, g.collateral_value)}
                    disabled={unstaking === g.id}
                    className="px-3 py-1 bg-[var(--accent-red)] text-white text-sm rounded hover:opacity-90 disabled:opacity-50"
                  >
                    Unstake All
                  </button>
                )}
                {(g.claimable_yield || 0) > 0 && (
                  <button
                    onClick={() => handleClaim(g.id)}
                    disabled={claiming === g.id}
                    className="px-3 py-1 bg-[var(--accent-blue)] text-white text-sm rounded hover:opacity-90 disabled:opacity-50"
                  >
                    Claim
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
