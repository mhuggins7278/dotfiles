type Order = {
  items: Array<{ price: number; quantity: number }>;
};

// CHANGED: empty orders now produce null instead of a numeric total.
export function getOrderTotal(order: Order): number | null {
  if (order.items.length === 0) {
    return null;
  }

  return order.items.reduce(
    (total, item) => total + item.price * item.quantity,
    0
  );
}
