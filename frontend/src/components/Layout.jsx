import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import TopBar from './TopBar';
import { useState, useEffect } from 'react';
import { api } from '../api';

export default function Layout({ user, onLogout }) {
  const [lastPrice, setLastPrice] = useState(null);

  useEffect(() => {
    const fetchPrice = async () => {
      try {
        const data = await api.orderbook();
        const { best_bid, best_ask } = data;
        const mid =
          best_bid != null && best_ask != null
            ? (best_bid + best_ask) / 2
            : best_bid ?? best_ask;
        if (mid != null) setLastPrice(mid);
      } catch {
        // ignore
      }
    };
    fetchPrice();
    const id = setInterval(fetchPrice, 3000);
    return () => clearInterval(id);
  }, []);

  return (
    <div className="flex min-h-screen">
      <Sidebar user={user} onLogout={onLogout} />
      <div className="flex-1 flex flex-col min-w-0 max-lg:ml-64">
        <TopBar price={lastPrice} change24h={0} />
        <main className="flex-1 p-6 overflow-auto">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
