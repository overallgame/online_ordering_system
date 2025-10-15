import { Order, OrderItem, OrderStatus, OrderType, PaymentStatus } from 'common';
import { CartItem } from '../viewModel/CartViewModel';

// 订单状态枚举
export enum OrderState {
  IDLE = 'idle',
  CREATING = 'creating',
  CREATED = 'created',
  PAYING = 'paying',
  PAID = 'paid',
  FAILED = 'failed'
}

// 订单结果
export interface OrderResult {
  success: boolean;
  order?: Order;
  error?: string;
}

// 订单 ViewModel
export class OrderViewModel {
  orderState: OrderState = OrderState.IDLE;
  currentOrder: Order | null = null;
  orders: Order[] = [];

  // 创建订单
  public async createOrder(
    userId: string,
    cartItems: CartItem[],
    orderType: 'dine_in' | 'delivery',
    deliveryAddress?: string,
    estimatedDeliveryTime?: number
  ): Promise<OrderResult> {
    this.orderState = OrderState.CREATING;

    try {
      const order = new Order();
      order.orderId = this.generateOrderId();
      order.userId = userId;
      order.restaurantId = 'restaurant_001';
      order.orderType = orderType === 'dine_in' ? OrderType.DINE_IN : OrderType.DELIVERY;
      order.createTime = Date.now();
      order.updateTime = Date.now();
      order.status = OrderStatus.PENDING;
      order.paymentStatus = PaymentStatus.PENDING;
      
      if (deliveryAddress) {
        order.deliveryAddress = deliveryAddress;
      }
      
      if (estimatedDeliveryTime) {
        order.estimatedDeliveryTime = estimatedDeliveryTime;
      }

      // 转换购物车商品为订单商品
      order.items = this.convertCartItemsToOrderItems(cartItems);
      
      // 计算金额
      this.calculateOrderAmounts(order);

      // 保存订单
      this.orders.push(order);
      this.currentOrder = order;
      this.orderState = OrderState.CREATED;

      return { success: true, order };
    } catch (error) {
      this.orderState = OrderState.FAILED;
      return { success: false, error: '创建订单失败' };
    }
  }

  // 支付订单
  public async payOrder(orderId: string): Promise<boolean> {
    this.orderState = OrderState.PAYING;

    try {
      const order = this.orders.find(o => o.orderId === orderId);
      if (order) {
        // 模拟支付延迟
        await new Promise<void>(resolve => setTimeout(resolve, 1000));
        
        order.paymentStatus = PaymentStatus.PAID;
        order.status = OrderStatus.CONFIRMED;
        order.updateTime = Date.now();
        
        this.orderState = OrderState.PAID;
        return true;
      }
      return false;
    } catch (error) {
      this.orderState = OrderState.FAILED;
      return false;
    }
  }

  // 获取订单
  public getOrder(orderId: string): Order | undefined {
    return this.orders.find(o => o.orderId === orderId);
  }

  // 获取用户订单列表
  public getUserOrders(userId: string): Order[] {
    return this.orders.filter(o => o.userId === userId);
  }

  // 重置状态
  public resetState(): void {
    this.orderState = OrderState.IDLE;
    this.currentOrder = null;
  }

  // 转换购物车商品为订单商品
  private convertCartItemsToOrderItems(cartItems: CartItem[]): OrderItem[] {
    return cartItems.map(cartItem => {
      const orderItem = new OrderItem();
      orderItem.itemId = this.generateItemId();
      orderItem.quantity = cartItem.quantity;
      
      if (cartItem.combo) {
        orderItem.combo = cartItem.combo;
        orderItem.unitPrice = cartItem.combo.price;
      } else if (cartItem.dish) {
        orderItem.dish = cartItem.dish;
        orderItem.unitPrice = cartItem.dish.price;
      }
      
      orderItem.totalPrice = orderItem.unitPrice * orderItem.quantity;
      
      return orderItem;
    });
  }

  // 计算订单金额
  private calculateOrderAmounts(order: Order): void {
    order.totalAmount = order.items.reduce((total, item) => total + item.totalPrice, 0);
    order.discountAmount = order.totalAmount * 0.25; // 25% 折扣
    order.finalAmount = order.totalAmount - order.discountAmount;
  }

  // 生成订单ID
  private generateOrderId(): string {
    return 'ORDER_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
  }

  // 生成商品ID
  private generateItemId(): string {
    return 'ITEM_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
  }
}
