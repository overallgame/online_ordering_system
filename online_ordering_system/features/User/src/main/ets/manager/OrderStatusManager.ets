import { Order, OrderStatus } from 'common';

/**
 * 订单状态变化监听器接口
 */
export interface OrderStatusListener {
  onOrderStatusChanged(orderId: string, oldStatus: OrderStatus, newStatus: OrderStatus): void;
}

/**
 * 订单状态管理器 - 负责管理订单状态变化和通知
 */
export class OrderStatusManager {
  private static instance: OrderStatusManager;
  private listeners: OrderStatusListener[] = [];
  private orderStatusMap: Map<string, OrderStatus> = new Map();

  private constructor() {}

  public static getInstance(): OrderStatusManager {
    if (!OrderStatusManager.instance) {
      OrderStatusManager.instance = new OrderStatusManager();
    }
    return OrderStatusManager.instance;
  }

  /**
   * 添加订单状态监听器
   */
  addListener(listener: OrderStatusListener): void {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener);
    }
  }

  /**
   * 移除订单状态监听器
   */
  removeListener(listener: OrderStatusListener): void {
    const index = this.listeners.indexOf(listener);
    if (index > -1) {
      this.listeners.splice(index, 1);
    }
  }

  /**
   * 更新订单状态
   */
  updateOrderStatus(orderId: string, newStatus: OrderStatus): void {
    const oldStatus = this.orderStatusMap.get(orderId);
    
    if (oldStatus !== newStatus) {
      this.orderStatusMap.set(orderId, newStatus);
      
      // 通知所有监听器
      this.listeners.forEach(listener => {
        try {
          listener.onOrderStatusChanged(orderId, oldStatus || OrderStatus.PENDING, newStatus);
        } catch (error) {
          console.error('订单状态变化通知失败:', error);
        }
      });
      
      console.log(`订单 ${orderId} 状态从 ${oldStatus} 更新为 ${newStatus}`);
    }
  }

  /**
   * 获取订单当前状态
   */
  getOrderStatus(orderId: string): OrderStatus | undefined {
    return this.orderStatusMap.get(orderId);
  }

  /**
   * 批量更新订单状态
   */
  updateOrdersStatus(orders: Order[]): void {
    orders.forEach(order => {
      this.orderStatusMap.set(order.orderId, order.status);
    });
  }

  /**
   * 清除所有状态
   */
  clear(): void {
    this.orderStatusMap.clear();
    this.listeners = [];
  }
}
