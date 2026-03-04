const API_BASE = '/api';

async function request(path, options = {}) {
  const res = await fetch(`${API_BASE}${path}`, {
    headers: { 'Content-Type': 'application/json', ...options.headers },
    ...options,
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || data.errors?.[0] || res.statusText);
  return data;
}

export const api = {
  users: {
    create: (username) => request('/users', {
      method: 'POST',
      body: JSON.stringify({ user: { username } }),
    }),
    find: (username) => request(`/users/find?username=${encodeURIComponent(username)}`),
  },
  wallets: {
    index: (userId) => request(`/users/${userId}/wallets`),
  },
  gotchis: {
    index: (userId) => request(`/users/${userId}/gotchis`),
    show: (id) => request(`/gotchis/${id}`),
    summon: (userId) => request('/summon', {
      method: 'POST',
      body: JSON.stringify({ user_id: userId }),
    }),
    stake: (id, amount) => request(`/stake/${id}`, {
      method: 'POST',
      body: JSON.stringify({ amount: amount.toString() }),
    }),
    unstake: (id, amount) =>
      request(`/unstake/${id}`, {
        method: 'POST',
        body: JSON.stringify(amount != null ? { amount: amount.toString() } : {}),
      }),
    claim: (id) => request(`/claim/${id}`, { method: 'POST' }),
  },
  orderbook: () => request('/orderbook'),
  orders: {
    index: (userId, params = {}) => {
      const q = new URLSearchParams({ user_id: userId, ...params });
      return request(`/orders?${q}`);
    },
    create: (body) => request('/orders', {
      method: 'POST',
      body: JSON.stringify(body),
    }),
    cancel: (id) => request(`/orders/${id}`, { method: 'DELETE' }),
  },
  trades: {
    index: (limit = 50) => request(`/trades?limit=${limit}`),
  },
};
