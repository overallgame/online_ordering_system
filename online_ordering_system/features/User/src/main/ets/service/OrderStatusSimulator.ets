import { OrderStatus } from 'common';
import { OrderStatusManager } from '../manager/OrderStatusManager';

/**
 * 订单状态更新项接口
 */
export interface OrderStatusUpdate {
  orderId: string;
  status: OrderStatus;
}

/**
 * 订单状态模拟器 - 用于模拟订单状态变化
 */
export class OrderStatusSimulator {
  private static instance: OrderStatusSimulator;
  private intervalId: number | null = null;
  private orderIds: string[] = [];

  private constructor() {}

  public static getInstance(): OrderStatusSimulator {
    if (!OrderStatusSimulator.instance) {
      OrderStatusSimulator.instance = new OrderStatusSimulator();
    }
    return OrderStatusSimulator.instance;
  }

  /**
   * 开始模拟订单状态变化
   */
  startSimulation(orderIds: string[]): void {
    this.orderIds = orderIds;
    this.stopSimulation(); // 停止之前的模拟
    
    console.log('开始模拟订单状态变化...');
    
    // 每10秒模拟一次状态变化
    this.intervalId = setInterval(() => {
      this.simulateStatusChange();
    }, 10000);
  }

  /**
   * 停止模拟
   */
  stopSimulation(): void {
    if (this.intervalId !== null) {
      clearInterval(this.intervalId);
      this.intervalId = null;
      console.log('停止模拟订单状态变化');
    }
  }

  /**
   * 模拟状态变化
   */
  private simulateStatusChange(): void {
    if (this.orderIds.length === 0) return;

    // 随机选择一个订单
    const randomIndex = Math.floor(Math.random() * this.orderIds.length);
    const orderId = this.orderIds[randomIndex];
    
    // 获取当前状态
    const currentStatus = OrderStatusManager.getInstance().getOrderStatus(orderId);
    
    // 模拟状态流转
    let newStatus: OrderStatus;
    switch (currentStatus) {
      case OrderStatus.PENDING:
        newStatus = OrderStatus.CONFIRMED;
        break;
      case OrderStatus.CONFIRMED:
        newStatus = OrderStatus.PREPARING;
        break;
      case OrderStatus.PREPARING:
        newStatus = OrderStatus.READY;
        break;
      case OrderStatus.READY:
        newStatus = OrderStatus.COMPLETED;
        break;
      default:
        // 如果已经是完成状态，重新开始
        newStatus = OrderStatus.PENDING;
        break;
    }

    // 更新状态
    OrderStatusManager.getInstance().updateOrderStatus(orderId, newStatus);
    
    console.log(`模拟状态变化: 订单 ${orderId} 状态变为 ${newStatus}`);
  }

  /**
   * 手动触发状态变化
   */
  triggerStatusChange(orderId: string, newStatus: OrderStatus): void {
    OrderStatusManager.getInstance().updateOrderStatus(orderId, newStatus);
    console.log(`手动触发状态变化: 订单 ${orderId} 状态变为 ${newStatus}`);
  }

  /**
   * 批量更新订单状态
   */
  batchUpdateStatus(updates: OrderStatusUpdate[]): void {
    updates.forEach(update => {
      OrderStatusManager.getInstance().updateOrderStatus(update.orderId, update.status);
    });
    console.log(`批量更新了 ${updates.length} 个订单的状态`);
  }
}
