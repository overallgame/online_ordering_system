import { Order, CartItem, OrderStatus, PaymentStatus } from 'common';
import { OrderRepository } from '../repository/OrderRepository';
import { OrderDataConverter } from '../util/OrderDataConverter';

// 订单操作结果接口
interface OrderOperationResult {
  success: boolean;
  order?: Order;
  error?: string;
}

/**
 * 订单ViewModel
 * 负责订单相关的业务逻辑和状态管理
 */
export class OrderViewModel {
  private repository: OrderRepository;
  private listeners: Array<(order: Order | null) => void> = [];
  private isLoading: boolean = false;
  private error?: string = undefined;
  private currentOrder: Order | null = null;

  constructor() {
    this.repository = OrderRepository.getInstance();
  }

  // ==================== 状态管理 ====================

  /**
   * 添加监听器
   * @param listener 监听器函数
   */
  addListener(listener: (order: Order | null) => void): void {
    this.listeners.push(listener);
  }

  /**
   * 移除监听器
   * @param listener 监听器函数
   */
  removeListener(listener: (order: Order | null) => void): void {
    const index = this.listeners.indexOf(listener);
    if (index > -1) {
      this.listeners.splice(index, 1);
    }
  }

  /**
   * 通知所有监听器
   */
  private notifyListeners(): void {
    this.listeners.forEach(listener => listener(this.currentOrder));
  }

  /**
   * 获取当前订单
   */
  getCurrentOrder(): Order | null {
    return this.currentOrder;
  }

  /**
   * 获取加载状态
   */
  getIsLoading(): boolean {
    return this.isLoading;
  }

  /**
   * 获取错误信息
   */
  getError(): string | undefined {
    return this.error;
  }

  /**
   * 清除错误
   */
  clearError(): void {
    this.error = undefined;
  }

  // ==================== 订单操作 ====================

  /**
   * 创建订单
   * @param cartItems 购物车商品
   * @param orderType 订单类型
   * @param deliveryAddress 配送地址
   * @param estimatedDeliveryTime 预计送达时间
   * @param remark 备注
   * @returns 订单创建结果
   */
  async createOrder(
    cartItems: CartItem[],
    orderType: 'dine_in' | 'delivery',
    deliveryAddress?: string,
    estimatedDeliveryTime?: number,
    remark?: string
  ): Promise<OrderOperationResult> {
    try {
      // 参数验证
      if (!cartItems || cartItems.length === 0) {
        this.error = '购物车为空，无法创建订单';
        return { success: false, error: this.error };
      }

      this.isLoading = true;
      this.error = undefined;

      // 调用Repository创建订单
      const result = await this.repository.createAndSubmitOrder(
        cartItems,
        orderType,
        estimatedDeliveryTime,
        remark
      );

      if (result.success && result.data) {
        // 转换API响应为Order对象
        this.currentOrder = OrderDataConverter.convertOrderSubmitToOrder(result.data, cartItems);
        this.notifyListeners();
        
        console.log('Order created successfully:', this.currentOrder.orderId);
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
      this.isLoading = false;
    }
  }

  /**
   * 支付订单
   * @param orderId 订单ID
   * @returns 支付结果
   */
  async payOrder(orderId: string): Promise<boolean> {
    try {
      this.isLoading = true;
      this.error = undefined;

      // 模拟支付过程
      await new Promise<void>(resolve => setTimeout(resolve, 2000));

      // 更新订单状态
      if (this.currentOrder && this.currentOrder.orderId === orderId) {
        this.currentOrder.paymentStatus = PaymentStatus.PAID;
        this.currentOrder.status = OrderStatus.CONFIRMED;
        this.notifyListeners();
      }

      console.log('Order paid successfully:', orderId);
      return true;
    } catch (error) {
      this.error = '支付失败，请重试';
      console.error('Failed to pay order:', error);
      return false;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 取消订单
   * @param orderId 订单ID
   * @returns 取消结果
   */
  async cancelOrder(orderId: string): Promise<boolean> {
    try {
      this.isLoading = true;
      this.error = undefined;

      // 更新订单状态
      if (this.currentOrder && this.currentOrder.orderId === orderId) {
        this.currentOrder.status = OrderStatus.CANCELLED;
        this.notifyListeners();
      }

      console.log('Order cancelled successfully:', orderId);
      return true;
    } catch (error) {
      this.error = '取消订单失败';
      console.error('Failed to cancel order:', error);
      return false;
    } finally {
      this.isLoading = false;
    }
  }

  // ==================== 工具方法 ====================

  /**
   * 计算订单金额
   * @param cartItems 购物车商品
   * @param orderType 订单类型
   * @returns 订单金额
   */
  calculateOrderAmount(cartItems: CartItem[], orderType: 'dine_in' | 'delivery'): number {
    return this.repository.calculateOrderAmount(cartItems, orderType);
  }

  /**
   * 计算预计送达时间
   * @param cartItems 购物车商品
   * @param orderType 订单类型
   * @param scheduledTime 预约时间（可选）
   * @returns 预计送达时间戳
   */
  calculateEstimatedDeliveryTime(
    cartItems: CartItem[],
    orderType: 'dine_in' | 'delivery',
    scheduledTime?: number
  ): number {
    return this.repository.calculateEstimatedDeliveryTime(cartItems, orderType, scheduledTime);
  }

  /**
   * 格式化订单时间
   * @param timestamp 时间戳
   * @returns 格式化后的时间字符串
   */
  formatOrderTime(timestamp: number): string {
    return OrderDataConverter.formatOrderTime(timestamp);
  }

  /**
   * 重置ViewModel状态
   */
  reset(): void {
    this.currentOrder = null;
    this.error = undefined;
    this.isLoading = false;
    this.notifyListeners();
  }

  /**
   * 销毁ViewModel
   */
  destroy(): void {
    this.listeners = [];
    this.reset();
  }
}