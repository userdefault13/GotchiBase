import { useState } from 'react';
import { api } from '../api';

export default function TradeForm({ user, onOrderPlaced }) {
  const [side, setSide] = useState('bid');
  const [orderType, setOrderType] = useState('limit');
  const [price, setPrice] = useState('');
  const [amount, setAmount] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!user) {
      setError('Please log in to trade');
      return;
    }
    setError('');
    setLoading(true);
    try {
      await api.orders.create({
        user_id: user.id,
        side: side === 'bid' ? 'bid' : 'ask',
        order_type: orderType,
        price: orderType === 'limit' ? price : undefined,
        amount,
      });
      setAmount('');
      setPrice('');
      onOrderPlaced?.();
    } catch (err) {
      setError(err.message || 'Order failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-4 bg-[var(--bg-card)] rounded-xl border border-[var(--border)]">
      <h2 className="text-lg font-semibold mb-4">Place Order</h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="flex gap-2">
          <button
            type="button"
            onClick={() => setSide('bid')}
            className={`flex-1 py-2 rounded-lg font-medium ${
              side === 'bid'
                ? 'bg-[var(--accent-green)] text-black'
                : 'bg-[var(--bg-hover)] text-[var(--text-secondary)]'
            }`}
          >
            Buy
          </button>
          <button
            type="button"
            onClick={() => setSide('ask')}
            className={`flex-1 py-2 rounded-lg font-medium ${
              side === 'ask'
                ? 'bg-[var(--accent-red)] text-white'
                : 'bg-[var(--bg-hover)] text-[var(--text-secondary)]'
            }`}
          >
            Sell
          </button>
        </div>
        <div className="flex gap-2">
          <button
            type="button"
            onClick={() => setOrderType('limit')}
            className={`flex-1 py-2 rounded-lg text-sm ${
              orderType === 'limit'
                ? 'bg-[var(--accent-blue)] text-white'
                : 'bg-[var(--bg-hover)] text-[var(--text-secondary)]'
            }`}
          >
            Limit
          </button>
          <button
            type="button"
            onClick={() => setOrderType('market')}
            className={`flex-1 py-2 rounded-lg text-sm ${
              orderType === 'market'
                ? 'bg-[var(--accent-blue)] text-white'
                : 'bg-[var(--bg-hover)] text-[var(--text-secondary)]'
            }`}
          >
            Market
          </button>
        </div>
        {orderType === 'limit' && (
          <div>
            <label className="block text-sm text-[var(--text-secondary)] mb-1">
              Price (aDAI)
            </label>
            <input
              type="number"
              step="0.0001"
              min="0"
              value={price}
              onChange={(e) => setPrice(e.target.value)}
              className="w-full px-4 py-2 bg-[var(--bg-dark)] border border-[var(--border)] rounded-lg"
              required={orderType === 'limit'}
            />
          </div>
        )}
        <div>
          <label className="block text-sm text-[var(--text-secondary)] mb-1">
            Amount (GHST)
          </label>
          <input
            type="number"
            step="0.01"
            min="0"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            className="w-full px-4 py-2 bg-[var(--bg-dark)] border border-[var(--border)] rounded-lg"
            required
          />
        </div>
        {error && <p className="text-sm text-[var(--accent-red)]">{error}</p>}
        <button
          type="submit"
          disabled={loading || !amount}
          className={`w-full py-3 font-semibold rounded-lg ${
            side === 'bid'
              ? 'bg-[var(--accent-green)] text-black'
              : 'bg-[var(--accent-red)] text-white'
          } disabled:opacity-50`}
        >
          {loading ? 'Placing...' : side === 'bid' ? 'Buy GHST' : 'Sell GHST'}
        </button>
      </form>
    </div>
  );
}
