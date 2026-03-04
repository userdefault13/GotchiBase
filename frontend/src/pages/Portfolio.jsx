import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../api';
import OrderHistory from '../components/OrderHistory';

export default function Portfolio({ user }) {
  const [wallets, setWallets] = useState([]);
  const [gotchis, setGotchis] = useState([]);
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  const load = async () => {
    if (!user) {
      setLoading(false);
      return;
    }
    try {
      const [w, g, o] = await Promise.all([
        api.wallets.index(user.id),
        api.gotchis.index(user.id),
        api.orders.index(user.id),
      ]);
      setWallets(w);
      setGotchis(g);
      setOrders(o);
    } catch {
      // ignore
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!user) {
      setLoading(false);
      return;
    }
    load();
    const id = setInterval(load, 3000);
    return () => clearInterval(id);
  }, [user?.id]);

  const ghst = wallets.find((w) => w.token_type === 'ghst');
  const adai = wallets.find((w) => w.token_type === 'adai');

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Portfolio</h1>
      {loading ? (
        <p className="text-[var(--text-secondary)]">Loading...</p>
      ) : (
        <>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="p-6 bg-[var(--bg-card)] rounded-xl border border-[var(--border)]">
              <h2 className="text-lg font-semibold mb-4">Balances</h2>
              <div className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-[var(--text-secondary)]">GHST</span>
                  <span className="font-mono">
                    {ghst ? Number(ghst.balance).toFixed(2) : '—'}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-[var(--text-secondary)]">aDAI</span>
                  <span className="font-mono">
                    {adai ? Number(adai.balance).toFixed(2) : '—'}
                  </span>
                </div>
              </div>
            </div>
            <div className="p-6 bg-[var(--bg-card)] rounded-xl border border-[var(--border)]">
              <h2 className="text-lg font-semibold mb-4">Gotchis</h2>
              <p className="text-[var(--text-secondary)] mb-4">
                {gotchis.length} Gotchi{gotchis.length !== 1 ? 's' : ''}
              </p>
              <Link
                to="/gotchis"
                className="text-[var(--accent-blue)] hover:underline"
              >
                View Gotchis →
              </Link>
            </div>
          </div>
          <OrderHistory orders={orders} user={user} onCancel={load} />
        </>
      )}
    </div>
  );
}
