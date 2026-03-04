export default function TopBar({ pair = 'GHST/aDAI', price, change24h }) {
  return (
    <header className="h-14 border-b border-[var(--border)] flex items-center px-6 bg-[var(--bg-card)]">
      <div className="flex items-center gap-6">
        <span className="font-semibold text-[var(--text-primary)]">{pair}</span>
        {price != null && (
          <span className="text-[var(--text-secondary)]">
            ${Number(price).toFixed(4)}
          </span>
        )}
        {change24h != null && (
          <span
            className={`text-sm font-medium ${
              Number(change24h) >= 0 ? 'text-[var(--accent-green)]' : 'text-[var(--accent-red)]'
            }`}
          >
            {Number(change24h) >= 0 ? '+' : ''}{Number(change24h).toFixed(2)}%
          </span>
        )}
      </div>
    </header>
  );
}
