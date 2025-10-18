import { Order, OrderStatus, PaymentStatus, OrderType, PaymentMethod } from 'common';
import { OrderService, PaymentResult } from '../service/OrderService';
import {OrderServiceTest} from '../test/OrderServiceTest'
import { OrderDataConverter } from '../util/OrderDataConverter';
import {AppDataManager} from 'common'
/**
 * 订单ViewModel - 处理订单相关的业务逻辑
 */
@Observed
export class OrderViewModel {
  // 订单列表
  orders: Order[] = [];
  // 加载状态
  isLoading: boolean = false;
  // 刷新状态
  isRefreshing: boolean = false;
  // 分页信息
  currentPage: number = 1;
  hasMore: boolean = true;
  totalCount: number = 0;
  pageSize: number = 10;
  
  // 筛选条件
  selectedStatus?: number; // 订单状态筛选
  beginTime?: string; // 开始时间
  endTime?: string; // 结束时间
  
  // 订单服务
  private orderService: OrderService;
  // 当前用户ID
  private userId: string = '';

  constructor() {
    this.setUserId(AppDataManager.getInstance().getCurrentUser()?.userId)
    OrderServiceTest.runAllTests();
    this.orderService = OrderService.getInstance();
  }

  /**
   * 设置用户ID
   */
  setUserId(userId: string | undefined ): void {
    if(userId)
    {
      this.userId = userId;
    }

  }

  /**
   * 设置筛选条件
   */
  setFilter(status?: number, beginTime?: string, endTime?: string): void {
    this.selectedStatus = status;
    this.beginTime = beginTime;
    this.endTime = endTime;
  }

  /**
   * 清除筛选条件
   */
  clearFilter(): void {
    this.selectedStatus = undefined;
    this.beginTime = undefined;
    this.endTime = undefined;
  }

  /**
   * 加载订单列表
   */
  async loadOrders(refresh: boolean = false): Promise<void> {
    if (refresh) {
      this.isRefreshing = true;
      this.currentPage = 1;
      this.orders = [];
      this.hasMore = true;
    } else {
      this.isLoading = true;
    }

    try {
      // 使用历史订单接口获取用户订单
      const response = await this.orderService.getHistoryOrders(
        this.currentPage, 
        this.pageSize, 
        this.selectedStatus
      );

      if (response.success && response.data) {
        if (refresh) {
          this.orders = response.data.orders;
        } else {
          this.orders = [...this.orders, ...response.data.orders];
        }
        this.totalCount = response.data.total;
        this.hasMore = this.orders.length < this.totalCount;
        this.currentPage++;
      } else {
        console.error('加载订单失败:', response.error);
      }
    } catch (error) {
      console.error('加载订单时发生错误:', error);
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
    }
  }

  /**
   * 刷新订单列表
   */
  async refreshOrders(): Promise<void> {
    await this.loadOrders(true);
  }

  /**
   * 加载更多订单
   */
  async loadMoreOrders(): Promise<void> {
    if (!this.isLoading && this.hasMore) {
      await this.loadOrders(false);
    }
  }


  /**
   * 取消订单
   */
  async cancelOrder(orderId: string): Promise<boolean> {
    try {
      const response = await this.orderService.cancelOrder(orderId);
      
      if (response.success) {
        // 更新本地订单状态
        const orderIndex = this.orders.findIndex(order => order.orderId === orderId);
        if (orderIndex !== -1) {
          this.orders[orderIndex].status = OrderStatus.CANCELLED;
          this.orders[orderIndex].updateTime = Date.now();
        }
        return true;
      } else {
        console.error('取消订单失败:', response.error);
        return false;
      }
    } catch (error) {
      console.error('取消订单时发生错误:', error);
      return false;
    }
  }

  /**
   * 删除订单
   */
  async deleteOrder(orderId: string): Promise<boolean> {
    try {
      const response = await this.orderService.deleteOrder(orderId);
      
      if (response.success) {
        // 从本地列表中移除订单
        this.orders = this.orders.filter(order => order.orderId !== orderId);
        this.totalCount--;
        return true;
      } else {
        console.error('删除订单失败:', response.error);
        return false;
      }
    } catch (error) {
      console.error('删除订单时发生错误:', error);
      return false;
    }
  }

  /**
   * 支付订单
   */
  async payOrder(orderNumber: string, payMethod: number): Promise<PaymentResult> {
    try {
      const response = await this.orderService.payOrder(orderNumber, payMethod);
      
      if (response.success) {
        // 更新本地订单状态
        const orderIndex = this.orders.findIndex(order => order.orderId === orderNumber);
        if (orderIndex !== -1) {
          this.orders[orderIndex].paymentStatus = PaymentStatus.PAID;
          this.orders[orderIndex].status = OrderStatus.CONFIRMED;
          this.orders[orderIndex].updateTime = Date.now();
        }
        return { success: true, paymentUrl: response.data?.paymentUrl };
      } else {
        console.error('支付订单失败:', response.error);
        return { success: false };
      }
    } catch (error) {
      console.error('支付订单时发生错误:', error);
      return { success: false };
    }
  }

  /**
   * 催单
   */
  async remindOrder(orderId: string): Promise<boolean> {
    try {
      const response = await this.orderService.remindOrder(orderId);
      
      if (response.success) {
        console.log('催单成功');
        return true;
      } else {
        console.error('催单失败:', response.error);
        return false;
      }
    } catch (error) {
      console.error('催单时发生错误:', error);
      return false;
    }
  }

  /**
   * 再来一单
   */
  async repeatOrder(orderId: string): Promise<boolean> {
    try {
      const response = await this.orderService.repeatOrder(orderId);
      
      if (response.success) {
        console.log('再来一单成功');
        return true;
      } else {
        console.error('再来一单失败:', response.error);
        return false;
      }
    } catch (error) {
      console.error('再来一单时发生错误:', error);
      return false;
    }
  }

  /**
   * 设置状态筛选
   */
  setStatusFilter(status?: number): void {
    this.selectedStatus = status;
    this.currentPage = 1;
    this.orders = [];
    this.hasMore = true;
  }

  /**
   * 获取订单详情
   */
  async getOrderDetail(orderId: string): Promise<Order | null> {
    try {
      const response = await this.orderService.getOrderDetail(orderId);
      
      if (response.success && response.data) {
        return response.data;
      } else {
        console.error('获取订单详情失败:', response.error);
        return null;
      }
    } catch (error) {
      console.error('获取订单详情时发生错误:', error);
      return null;
    }
  }

  /**
   * 获取状态显示文本
   */
  getStatusText(status: OrderStatus): string {
    return OrderDataConverter.getStatusText(status);
  }

  /**
   * 获取状态颜色
   */
  getStatusColor(status: OrderStatus): string {
    return OrderDataConverter.getStatusColor(status);
  }

  /**
   * 获取订单类型显示文本
   */
  getOrderTypeText(orderType: OrderType): string {
    const typeMap: Record<OrderType, string> = {
      [OrderType.DINE_IN]: '进店用餐',
      [OrderType.TAKEAWAY]: '自取',
      [OrderType.DELIVERY]: '外卖配送'
    };
    return typeMap[orderType] || '未知类型';
  }

  /**
   * 格式化时间
   */
  formatTime(timestamp: number): string {
    return OrderDataConverter.formatTime(timestamp);
  }

  /**
   * 检查订单是否可以取消
   */
  canCancelOrder(order: Order): boolean {
    return order.status === OrderStatus.PENDING && order.paymentStatus === PaymentStatus.PENDING;
  }

  /**
   * 检查订单是否可以删除
   */
  canDeleteOrder(order: Order): boolean {
    return order.status === OrderStatus.COMPLETED || order.status === OrderStatus.CANCELLED;
  }

  /**
   * 检查订单是否可以支付
   */
  canPayOrder(order: Order): boolean {
    return order.status === OrderStatus.PENDING && order.paymentStatus === PaymentStatus.PENDING;
  }
}
