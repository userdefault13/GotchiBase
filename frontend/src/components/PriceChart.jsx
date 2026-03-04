import { useMemo } from 'react';

export default function PriceChart({ trades }) {
  const { points, minP, maxP } = useMemo(() => {
    if (!trades?.length) return { points: [], minP: 0, maxP: 1 };
    const sorted = [...trades].sort(
      (a, b) => new Date(a.created_at) - new Date(b.created_at)
    );
    const prices = sorted.map((t) => Number(t.price));
    const minP = Math.min(...prices) * 0.999;
    const maxP = Math.max(...prices) * 1.001 || 1;
    const points = sorted.map((t, i) => ({
      x: i,
      price: Number(t.price),
      time: t.created_at,
    }));
    return { points, minP, maxP };
  }, [trades]);

  if (points.length === 0) {
    return (
      <div className="p-6 bg-[var(--bg-card)] rounded-xl border border-[var(--border)] h-64 flex items-center justify-center text-[var(--text-secondary)]">
        No trade data yet
      </div>
    );
  }

  const height = 200;
  const width = 100;
  const toY = (p) => height - ((p - minP) / (maxP - minP)) * height;

  return (
    <div className="p-6 bg-[var(--bg-card)] rounded-xl border border-[var(--border)]">
      <h2 className="text-lg font-semibold mb-4">Price Chart (GHST/aDAI)</h2>
      <div className="h-64 flex items-end gap-px">
        {points.map((pt, i) => (
          <div
            key={i}
            className="flex-1 min-w-0 bg-[var(--accent-blue)] rounded-t opacity-80 hover:opacity-100 transition-opacity"
            style={{
              height: `${((pt.price - minP) / (maxP - minP)) * 100}%`,
              minHeight: '2px',
            }}
            title={`${pt.price.toFixed(4)} @ ${new Date(pt.time).toLocaleString()}`}
          />
        ))}
      </div>
      <div className="flex justify-between mt-2 text-xs text-[var(--text-secondary)]">
        <span>{minP.toFixed(4)}</span>
        <span>{maxP.toFixed(4)}</span>
      </div>
    </div>
  );
}
