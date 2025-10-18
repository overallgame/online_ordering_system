import { Order, CartItem, OrderStatus, PaymentStatus } from 'common';
import { OrderRepository } from '../repository/OrderRepository';
import { OrderDataConverter } from '../util/OrderDataConverter';

// 订单操作结果接口
interface OrderOperationResult {
  success: boolean;
  order?: Order;
  error?: string;
}

export class OrderViewModel {
  private repository: OrderRepository;
  private listeners: Array<(order: Order | null) => void> = [];
  private error?: string = undefined;
  private currentOrder: Order | null = null;

  constructor() {
    this.repository = OrderRepository.getInstance();
  }

  addListener(listener: (order: Order | null) => void): void {
    this.listeners.push(listener);
  }

  removeListener(listener: (order: Order | null) => void): void {
    const index = this.listeners.indexOf(listener);
    if (index > -1) {
      this.listeners.splice(index, 1);
    }
  }

  private notifyListeners(): void {
    this.listeners.forEach(listener => listener(this.currentOrder));
  }

  getCurrentOrder(): Order | null {
    return this.currentOrder;
  }

  async createOrder(
    cartItems: CartItem[],
    orderType: 'dine_in' | 'delivery',
    deliveryAddress?: string,
    estimatedDeliveryTime?: number,
    remark?: string,
    isPaid: boolean = true
  ): Promise<OrderOperationResult> {
    try {
      if (!cartItems || cartItems.length === 0) {
        this.error = '购物车为空，无法创建订单';
        return { success: false, error: this.error };
      }

      this.error = undefined;

      const result = await this.repository.createAndSubmitOrder(
        cartItems,
        orderType,
        estimatedDeliveryTime,
        remark,
        isPaid
      );

      if (result.success && result.data) {
        this.currentOrder = OrderDataConverter.convertOrderSubmitToOrder(result.data, cartItems, isPaid);
        this.notifyListeners();
        
        console.log('Order created successfully:', this.currentOrder.orderId, 'Paid:', isPaid);
        return { success: true, order: this.currentOrder };
      } else {
        this.error = result.error || '订单创建失败';
        return { success: false, error: this.error };
      }
    } catch (error) {
      this.error = '网络错误，请检查网络连接';
      console.error('Failed to create order:', error);
      return { success: false, error: this.error };
    } finally {
    }
  }

  reset(): void {
    this.currentOrder = null;
    this.error = undefined;
    this.notifyListeners();
  }

  destroy(): void {
    this.listeners = [];
    this.reset();
  }
}