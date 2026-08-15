import { getOrderTotal } from './order-total';

export function createCharge(order: {
  items: Array<{ price: number; quantity: number }>;
}) {
  const total = getOrderTotal(order);
  return { amount: total.toFixed(2) };
}
