import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { api } from '../api';

export default function Login({ onLogin }) {
  const [username, setUsername] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const user = await api.users.find(username);
      onLogin(user);
      navigate('/');
    } catch (err) {
      setError(err.message || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[var(--bg-dark)]">
      <div className="w-full max-w-sm p-8 bg-[var(--bg-card)] rounded-xl border border-[var(--border)]">
        <h1 className="text-2xl font-bold text-center mb-6">gotchibase</h1>
        <h2 className="text-lg text-[var(--text-secondary)] text-center mb-6">Log in</h2>
        <form onSubmit={handleSubmit} className="space-y-4">
          <input
            type="text"
            placeholder="Username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            className="w-full px-4 py-3 bg-[var(--bg-dark)] border border-[var(--border)] rounded-lg text-[var(--text-primary)] placeholder-[var(--text-secondary)] focus:outline-none focus:border-[var(--accent-blue)]"
            required
          />
          {error && <p className="text-sm text-[var(--accent-red)]">{error}</p>}
          <button
            type="submit"
            disabled={loading}
            className="w-full py-3 bg-[var(--accent-blue)] text-white font-semibold rounded-lg hover:opacity-90 disabled:opacity-50"
          >
            {loading ? 'Logging in...' : 'Log in'}
          </button>
        </form>
        <p className="mt-6 text-center text-sm text-[var(--text-secondary)]">
          Don't have an account?{' '}
          <Link to="/register" className="text-[var(--accent-blue)] hover:underline">
            Register
          </Link>
        </p>
      </div>
    </div>
  );
}
