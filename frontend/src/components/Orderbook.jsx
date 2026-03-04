export default function Orderbook({ data }) {
  if (!data) return null;

  const { bids = [], asks = [], spread, best_bid, best_ask } = data;
  const maxSize = Math.max(
    ...bids.map(([, s]) => s),
    ...asks.map(([, s]) => s),
    1
  );

  const Row = ({ price, size, isBid }) => (
    <div className="flex text-sm relative">
      <span
        className={`flex-1 ${isBid ? 'text-[var(--accent-green)]' : 'text-[var(--accent-red)]'}`}
      >
        {Number(price).toFixed(4)}
      </span>
      <span className="w-16 text-right font-mono">{Number(size).toFixed(2)}</span>
      <div
        className="absolute inset-y-0 opacity-20 -z-10 rounded"
        style={{
          width: `${(size / maxSize) * 100}%`,
          backgroundColor: isBid ? 'var(--accent-green)' : 'var(--accent-red)',
          right: isBid ? 0 : 'auto',
          left: isBid ? 'auto' : 0,
        }}
      />
    </div>
  );

  return (
    <div className="p-4 bg-[var(--bg-card)] rounded-xl border border-[var(--border)]">
      <h2 className="text-lg font-semibold mb-4">Order Book</h2>
      <div className="grid grid-cols-2 gap-2 text-[var(--text-secondary)] text-xs mb-2">
        <span>Price (aDAI)</span>
        <span className="text-right">Size (GHST)</span>
      </div>
      <div className="space-y-1 max-h-48 overflow-y-auto">
        {asks
          .slice()
          .reverse()
          .map(([price, size], i) => (
            <div key={`ask-${i}`} className="relative py-0.5">
              <Row price={price} size={size} isBid={false} />
            </div>
          ))}
      </div>
      {spread != null && (
        <div className="py-2 my-2 border-y border-[var(--border)] text-center">
          <span className="text-[var(--text-secondary)] text-sm">
            Spread: {Number(spread).toFixed(4)}
          </span>
        </div>
      )}
      <div className="space-y-1 max-h-48 overflow-y-auto">
        {bids.map(([price, size], i) => (
          <div key={`bid-${i}`} className="relative py-0.5">
            <Row price={price} size={size} isBid />
          </div>
        ))}
      </div>
    </div>
  );
}
