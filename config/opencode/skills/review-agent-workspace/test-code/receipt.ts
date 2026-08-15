import { getOrderTotal } from './order-total';

export function renderReceipt(order: {
  items: Array<{ price: number; quantity: number }>;
}) {
  return `Total: $${getOrderTotal(order).toFixed(2)}`;
}
