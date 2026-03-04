import { Link } from 'react-router-dom';
import { useState, useEffect } from 'react';
import { api } from '../api';

export default function Dashboard({ user }) {
  const [wallets, setWallets] = useState([]);
  const [recentTrades, setRecentTrades] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) {
      setLoading(false);
      return;
    }
    const load = async () => {
      try {
        const [w, t] = await Promise.all([
          api.wallets.index(user.id),
          api.trades.index(10),
        ]);
        setWallets(w);
        setRecentTrades(t);
      } catch {
        // ignore
      } finally {
        setLoading(false);
      }
    };
    load();
    const id = setInterval(load, 3000);
    return () => clearInterval(id);
  }, [user]);

  const ghst = wallets.find((w) => w.token_type === 'ghst');
  const adai = wallets.find((w) => w.token_type === 'adai');

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Dashboard</h1>
      {!user ? (
        <p className="text-[var(--text-secondary)]">
          <Link to="/login" className="text-[var(--accent-blue)] hover:underline">Log in</Link> or{' '}
          <Link to="/register" className="text-[var(--accent-blue)] hover:underline">register</Link> to view your dashboard.
        </p>
      ) : loading ? (
        <p className="text-[var(--text-secondary)]">Loading...</p>
      ) : (
        <>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="p-6 bg-[var(--bg-card)] rounded-xl border border-[var(--border)]">
              <p className="text-sm text-[var(--text-secondary)]">GHST Balance</p>
              <p className="text-2xl font-bold mt-1">
                {ghst ? Number(ghst.balance).toFixed(2) : '—'}
              </p>
            </div>
            <div className="p-6 bg-[var(--bg-card)] rounded-xl border border-[var(--border)]">
              <p className="text-sm text-[var(--text-secondary)]">aDAI Balance</p>
              <p className="text-2xl font-bold mt-1">
                {adai ? Number(adai.balance).toFixed(2) : '—'}
              </p>
            </div>
            <div className="p-6 bg-[var(--bg-card)] rounded-xl border border-[var(--border)] flex items-center">
              <Link
                to="/trade"
                className="w-full py-3 bg-[var(--accent-blue)] text-white font-semibold rounded-lg text-center hover:opacity-90"
              >
                Trade GHST/aDAI
              </Link>
            </div>
          </div>
          <div className="p-6 bg-[var(--bg-card)] rounded-xl border border-[var(--border)]">
            <h2 className="text-lg font-semibold mb-4">Recent Trades</h2>
            {recentTrades.length === 0 ? (
              <p className="text-[var(--text-secondary)]">No recent trades</p>
            ) : (
              <div className="space-y-2">
                {recentTrades.slice(0, 5).map((t) => (
                  <div
                    key={t.id}
                    className="flex justify-between py-2 border-b border-[var(--border)] last:border-0"
                  >
                    <span
                      className={
                        t.side === 'buy' ? 'text-[var(--accent-green)]' : 'text-[var(--accent-red)]'
                      }
                    >
                      {t.side === 'buy' ? 'Buy' : 'Sell'}
                    </span>
                    <span>{Number(t.amount).toFixed(2)} GHST</span>
                    <span className="text-[var(--text-secondary)]">
                      @ {Number(t.price).toFixed(4)} aDAI
                    </span>
                  </div>
                ))}
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
}
