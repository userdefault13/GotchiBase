import { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/Layout';
import Login from './pages/Login';
import Register from './pages/Register';
import Dashboard from './pages/Dashboard';
import Trade from './pages/Trade';
import Portfolio from './pages/Portfolio';
import Gotchis from './pages/Gotchis';

const USER_KEY = 'gotchibase_user';

function App() {
  const [user, setUser] = useState(null);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    try {
      const stored = localStorage.getItem(USER_KEY);
      if (stored) setUser(JSON.parse(stored));
    } catch {
      // ignore
    } finally {
      setReady(true);
    }
  }, []);

  const handleLogin = (u) => {
    setUser(u);
    localStorage.setItem(USER_KEY, JSON.stringify(u));
  };

  const handleLogout = () => {
    setUser(null);
    localStorage.removeItem(USER_KEY);
  };

  if (!ready) return null;

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login onLogin={handleLogin} />} />
        <Route path="/register" element={<Register onLogin={handleLogin} />} />
        <Route
          path="/"
          element={
            <Layout user={user} onLogout={handleLogout} />
          }
        >
          <Route index element={<Dashboard user={user} />} />
          <Route path="trade" element={<Trade user={user} />} />
          <Route path="portfolio" element={<Portfolio user={user} />} />
          <Route path="gotchis" element={<Gotchis user={user} />} />
        </Route>
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
