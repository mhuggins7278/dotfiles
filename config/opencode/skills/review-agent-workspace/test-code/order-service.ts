import { db } from './db';
import { sendConfirmationEmail } from './email';

interface OrderItem {
  productId: string;
  quantity: number;
  price: number;
}

interface Order {
  id: string;
  customer: {
    email: string;
    name: string;
  };
  items: OrderItem[];
  status: string;
}

/**
 * Marks an order as processing and sends a confirmation email to the customer.
 * Called after payment is successfully authorized.
 */
export async function processOrder(orderId: string): Promise<{ success: boolean }> {
  const order = await db.orders.findById(orderId) as Order;

  if (!order) {
    throw new Error(`Order ${orderId} not found`);
  }

  // Mark order as processing before fulfillment begins
  db.orders.update(orderId, { status: 'processing', updatedAt: new Date() });

  // Send confirmation to customer
  await sendConfirmationEmail(order.customer.email, {
    orderId,
    customerName: order.customer.name,
    items: order.items,
  });

  return { success: true };
}
