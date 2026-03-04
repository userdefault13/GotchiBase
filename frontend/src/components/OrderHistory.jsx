import { useState } from 'react';
import { api } from '../api';

export default function OrderHistory({ orders, user, onCancel }) {
  const [cancelling, setCancelling] = useState(null);

  const handleCancel = async (id) => {
    setCancelling(id);
    try {
      await api.orders.cancel(id);
      onCancel?.();
    } catch {
      // ignore
    } finally {
      setCancelling(null);
    }
  };

  if (!user) {
    return (
      <div className="p-4 bg-[var(--bg-card)] rounded-xl border border-[var(--border)]">
        <h2 className="text-lg font-semibold mb-4">Order History</h2>
        <p className="text-[var(--text-secondary)] text-sm">Log in to see your orders</p>
      </div>
    );
  }

  return (
    <div className="p-4 bg-[var(--bg-card)] rounded-xl border border-[var(--border)]">
      <h2 className="text-lg font-semibold mb-4">Order History</h2>
      {!orders?.length ? (
        <p className="text-[var(--text-secondary)] text-sm">No orders yet</p>
      ) : (
        <div className="space-y-2 max-h-80 overflow-y-auto">
          {orders.map((o) => (
            <div
              key={o.id}
              className="py-2 px-3 bg-[var(--bg-dark)] rounded-lg text-sm"
            >
              <div className="flex justify-between items-start">
                <span
                  className={
                    o.side === 'bid' ? 'text-[var(--accent-green)]' : 'text-[var(--accent-red)]'
                  }
                >
                  {o.side === 'bid' ? 'Buy' : 'Sell'}
                </span>
                <span
                  className={`text-xs ${
                    o.status === 'filled'
                      ? 'text-[var(--accent-green)]'
                      : o.status === 'cancelled'
                        ? 'text-[var(--text-secondary)]'
                        : 'text-yellow-500'
                  }`}
                >
                  {o.status}
                </span>
              </div>
              <div className="mt-1 text-[var(--text-secondary)]">
                {Number(o.amount).toFixed(2)} GHST
                {o.price != null && ` @ ${Number(o.price).toFixed(4)}`}
              </div>
              {o.filled_amount > 0 && (
                <div className="text-xs text-[var(--text-secondary)]">
                  Filled: {Number(o.filled_amount).toFixed(2)}
                </div>
              )}
              {o.status === 'open' && (
                <button
                  onClick={() => handleCancel(o.id)}
                  disabled={cancelling === o.id}
                  className="mt-2 text-xs text-[var(--accent-red)] hover:underline disabled:opacity-50"
                >
                  {cancelling === o.id ? 'Cancelling...' : 'Cancel'}
                </button>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
