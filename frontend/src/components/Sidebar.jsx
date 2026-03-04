import { NavLink } from 'react-router-dom';

const navItems = [
  { to: '/', label: 'Dashboard' },
  { to: '/trade', label: 'Trade' },
  { to: '/portfolio', label: 'Portfolio' },
  { to: '/gotchis', label: 'Gotchis' },
];

export default function Sidebar({ user, onLogout }) {
  return (
    <aside className="w-64 min-h-screen bg-[var(--bg-card)] border-r border-[var(--border)] flex flex-col shrink-0 max-lg:fixed max-lg:z-50 max-lg:left-0 max-lg:top-0 max-lg:h-full">
      <div className="p-6 border-b border-[var(--border)]">
        <h1 className="text-xl font-bold text-[var(--accent-blue)]">gotchibase</h1>
      </div>
      <nav className="flex-1 p-4 space-y-1">
        {navItems.map(({ to, label }) => (
          <NavLink
            key={to}
            to={to}
            className={({ isActive }) =>
              `block px-4 py-3 rounded-lg transition-colors ${
                isActive
                  ? 'bg-[var(--bg-hover)] text-[var(--accent-blue)]'
                  : 'text-[var(--text-secondary)] hover:bg-[var(--bg-hover)] hover:text-[var(--text-primary)]'
              }`
            }
          >
            {label}
          </NavLink>
        ))}
      </nav>
      {user && (
        <div className="p-4 border-t border-[var(--border)]">
          <p className="text-sm text-[var(--text-secondary)] truncate">{user.username}</p>
          <button
            onClick={onLogout}
            className="mt-2 text-sm text-[var(--accent-red)] hover:underline"
          >
            Log out
          </button>
        </div>
      )}
    </aside>
  );
}
