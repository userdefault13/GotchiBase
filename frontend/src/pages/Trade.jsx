import { useState, useEffect } from 'react';
import { api } from '../api';
import Orderbook from '../components/Orderbook';
import TradeForm from '../components/TradeForm';
import PriceChart from '../components/PriceChart';
import OrderHistory from '../components/OrderHistory';

export default function Trade({ user }) {
  const [orderbook, setOrderbook] = useState(null);
  const [trades, setTrades] = useState([]);
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  const refresh = async () => {
    try {
      const [ob, t, o] = await Promise.all([
        api.orderbook(),
        api.trades.index(50),
        user ? api.orders.index(user.id) : [],
      ]);
      setOrderbook(ob);
      setTrades(t);
      setOrders(o);
    } catch {
      // ignore
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    refresh();
    const id = setInterval(refresh, 3000);
    return () => clearInterval(id);
  }, [user?.id]);

  const onOrderPlaced = () => refresh();

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Trade GHST/aDAI</h1>
      {loading ? (
        <p className="text-[var(--text-secondary)]">Loading...</p>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2 space-y-6">
            <PriceChart trades={trades} />
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Orderbook data={orderbook} />
              <TradeForm user={user} onOrderPlaced={onOrderPlaced} />
            </div>
          </div>
          <div>
            <OrderHistory orders={orders} user={user} onCancel={refresh} />
          </div>
        </div>
      )}
    </div>
  );
}
