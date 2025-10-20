import { Order, CartItem, PaymentStatus } from 'common';
import { OrderRepository } from '../repository/OrderRepository';
import { OrderDataConverter } from '../util/OrderDataConverter';

// 订单操作结果接口
interface OrderOperationResult {
  success: boolean;
  order?: Order | null;
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
    addressBookId: number,
    estimatedDeliveryTime: number,
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
        addressBookId,
        estimatedDeliveryTime,
      );

      if (result.code === 1 && result.data) {
        this.currentOrder = OrderDataConverter.convertOrderSubmitToOrder(result.data, cartItems);
        this.notifyListeners();
        return { success: true, order: this.currentOrder };
      } else {
        this.error = result.msg || '订单创建失败';
        return { success: false, error: this.error };
      }
    } catch (error) {
      this.error = '网络错误，请检查网络连接';
      console.error('Failed to create order:', error);
      return { success: false, error: this.error };
    } finally {
    }
  }

  // 支付订单
  async payOrder(orderNumber: string, payMethod: number = 0): Promise<OrderOperationResult> {
    try {
      this.error = undefined;
      const result = await this.repository.payOrder(orderNumber, payMethod);
      
      if (result.success && result.data) {
        if (this.currentOrder) {
          this.currentOrder.paymentStatus = PaymentStatus.PAID;
          this.notifyListeners();
        }
        return { success: true, order: this.currentOrder };
      } else {
        this.error = result.error || '支付失败';
        return { success: false, error: this.error };
      }
    } catch (error) {
      this.error = '网络错误，请检查网络连接';
      console.error('Failed to pay order:', error);
      return { success: false, error: this.error };
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