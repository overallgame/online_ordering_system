import { ApiClient, ApiEndpoints, ApiResponse } from 'common';
import { Order, OrderStatus, PaymentStatus, PaymentMethod } from 'common';
import { OrderDataConverter, ApiOrderListResponse, ApiOrder, AdminOrderSearchResponse, HistoryOrderResponse } from '../util/OrderDataConverter';
import { MockOrderDataGenerator } from '../util/MockOrderDataGenerator';
import { OrderStatusManager } from '../manager/OrderStatusManager';

/**
 * 订单列表响应接口
 */
export interface OrderListResponse {
  orders: Order[];
  total: number;
  page: number;
  pageSize: number;
}

/**
 * 操作结果接口
 */
export interface OperationResult {
  success: boolean;
}

export interface PayOrder {
  orderId: string;
  paymentMethod: PaymentMethod;
}

export interface CancelOrder {
  orderId: string;
}

export interface PayOrderRequest {
  orderNumber: string;
  payMethod: number;
}

export interface EmptyRequest {
  // 空请求体接口
}

/**
 * 支付结果接口
 */
export interface PaymentResult {
  success: boolean;
  paymentUrl?: string;
}

/**
 * 订单服务类 - 处理订单相关的API调用
 */
export class OrderService {
  private static instance: OrderService;
  private apiClient: ApiClient;

  private constructor() {
    this.apiClient = ApiClient.getInstance();
  }

  public static getInstance(): OrderService {
    if (!OrderService.instance) {
      OrderService.instance = new OrderService();
    }
    return OrderService.instance;
  }


  /**
   * 获取用户历史订单列表
   * @param page 页码
   * @param pageSize 每页数量
   * @param status 订单状态筛选（可选）
   * @returns 订单列表
   */
  async getHistoryOrders(
    page: number = 1, 
    pageSize: number = 10,
    status?: number
  ): Promise<ApiResponse<OrderListResponse>> {
    //return this.getMockOrderData(page, pageSize, status);
    try {
      let endpoint = `${ApiEndpoints.HISTORY_ORDERS}?pageNum=${page}&pageSize=${pageSize}`;
      if (status !== undefined) {
        endpoint += `&status=${status}`;
      }

      // 根据接口文档，历史订单接口返回的数据结构包含code、msg、data字段
      const response = await this.apiClient.get<HistoryOrderResponse>(endpoint);

      if (response.success && response.data) {
        // 检查接口返回的code字段
        if (response.data.code === 1 && response.data.data) {
          // 转换接口数据为应用数据
          const orders = OrderDataConverter.convertHistoryOrderList(response.data.data);
          const convertedResponse: OrderListResponse = {
            orders: orders,
            total: response.data.data.total,
            page: page,
            pageSize: pageSize
          };

          console.log('获取历史订单列表成功');
          return {
            success: true,
            data: convertedResponse
          };
        } else {
          console.error('获取历史订单列表失败:', response.data.msg);
          return {
            success: false,
            error: response.data.msg || '获取订单列表失败'
          };
        }
      } else {
        console.error('获取历史订单列表失败:', response.error);
        return {
          success: false,
          error: response.error || '获取订单列表失败'
        };
      }
    } catch (error) {
      console.error('获取历史订单列表时发生错误:', error);

      // 当网络请求失败时，返回模拟数据用于测试
      console.log('网络请求失败，返回模拟订单数据用于测试');
      return this.getMockOrderData(page, pageSize, status);
    }
  }

  /**
   * 获取模拟订单数据（用于测试）
   * @param page 页码
   * @param pageSize 每页数量
   * @param status 订单状态筛选（可选）
   * @returns 模拟订单列表
   */
  private getMockOrderData(
    page: number = 1, 
    pageSize: number = 10,
    status?: number
  ): ApiResponse<OrderListResponse> {
    try {
      // 生成所有模拟订单
      let allMockOrders = MockOrderDataGenerator.generateMockOrders();

      // 分页处理
      const startIndex = (page - 1) * pageSize;
      const endIndex = startIndex + pageSize;
      const pagedOrders = allMockOrders.slice(startIndex, endIndex);
      
      const convertedResponse: OrderListResponse = {
        orders: pagedOrders,
        total: allMockOrders.length,
        page: page,
        pageSize: pageSize
      };
      
      console.log(`返回模拟订单数据: 第${page}页，共${pagedOrders.length}条订单，总计${allMockOrders.length}条`);
      
      return {
        success: true,
        data: convertedResponse
      };
    } catch (error) {
      console.error('生成模拟订单数据时发生错误:', error);
      return {
        success: false,
        error: '生成模拟数据失败'
      };
    }
  }

  /**
   * 获取订单详情
   * @param orderId 订单ID
   * @returns 订单详情
   */
  async getOrderDetail(orderId: string): Promise<ApiResponse<Order>> {
    try {
      const response = await this.apiClient.get<ApiOrder>(`${ApiEndpoints.ORDER_DETAIL}/${orderId}`);
      
      if (response.success && response.data) {
        // 转换接口数据为应用数据
        const order = OrderDataConverter.convertOrder(response.data);
        console.log('获取订单详情成功');
        return {
          success: true,
          data: order
        };
      } else {
        console.error('获取订单详情失败:', response.error);
        return {
          success: false,
          error: response.error || '获取订单详情失败'
        };
      }
    } catch (error) {
      console.error('获取订单详情时发生错误:', error);
      return {
        success: false,
        error: '网络连接失败，请检查网络设置'
      };
    }
  }

  /**
   * 取消订单
   * @param orderId 订单ID
   * @returns 取消结果
   */
  async cancelOrder(orderId: string): Promise<ApiResponse<OperationResult>> {
    try {
      const emptyData: EmptyRequest = {};
      const response = await this.apiClient.put<OperationResult>(`${ApiEndpoints.CANCEL_ORDER}/${orderId}`, emptyData);

      if (response.success) {
        console.log('取消订单成功');
        // 通知订单状态变化
        OrderStatusManager.getInstance().updateOrderStatus(orderId, OrderStatus.CANCELLED);
        return response;
      } else {
        console.error('取消订单失败:', response.error);
        return response;
      }
    } catch (error) {
      console.error('取消订单时发生错误:', error);
      return {
        success: false,
        error: '网络连接失败，请检查网络设置'
      };
    }
  }

  /**
   * 删除订单
   * @param orderId 订单ID
   * @returns 删除结果
   */
  async deleteOrder(orderId: string): Promise<ApiResponse<OperationResult>> {
    try {
      const response = await this.apiClient.delete<OperationResult>(`${ApiEndpoints.CANCEL_ORDER}/${orderId}`);
      
      if (response.success) {
        console.log('删除订单成功');
        return response;
      } else {
        console.error('删除订单失败:', response.error);
        return response;
      }
    } catch (error) {
      console.error('删除订单时发生错误:', error);
      return {
        success: false,
        error: '网络连接失败，请检查网络设置'
      };
    }
  }

  /**
   * 支付订单
   * @param orderNumber 订单号
   * @param payMethod 支付方式
   * @returns 支付结果
   */
  async payOrder(orderNumber: string, payMethod: number,order:Order): Promise<ApiResponse<PaymentResult>> {
    try {
      const payOrderData: PayOrderRequest = {
        orderNumber:order.orderId,
        payMethod
      };
      const response = await this.apiClient.put<PaymentResult>(ApiEndpoints.ORDER_PAYMENT, payOrderData);

      if (response.success) {
        console.log('支付订单成功');
        // 通知订单状态变化
        OrderStatusManager.getInstance().updateOrderStatus(order.orderId, OrderStatus.CONFIRMED);
        return response;
      } else {
        console.error('支付订单失败:', response.error);
        return response;
      }
    } catch (error) {
      console.error('支付订单时发生错误:', error);
      return {
        success: false,
        error: '网络连接失败，请检查网络设置'
      };
    }
  }

  /**
   * 催单
   * @param orderId 订单ID
   * @returns 催单结果
   */
  async remindOrder(orderId: string): Promise<ApiResponse<OperationResult>> {
    try {
      const response = await this.apiClient.get<OperationResult>(`${ApiEndpoints.ORDER_REMINDER}/${orderId}`);

      if (response.success) {
        console.log('催单成功');
        return response;
      } else {
        console.error('催单失败:', response.error);
        return response;
      }
    } catch (error) {
      console.error('催单时发生错误:', error);
      return {
        success: false,
        error: '网络连接失败，请检查网络设置'
      };
    }
  }

  /**
   * 再来一单
   * @param orderId 订单ID
   * @returns 再来一单结果
   */
  async repeatOrder(orderId: string): Promise<ApiResponse<OperationResult>> {
    try {
      const emptyData: EmptyRequest = {};
      const response = await this.apiClient.post<OperationResult>(`${ApiEndpoints.ORDER_REPETITION}/${orderId}`, emptyData);

      if (response.success) {
        console.log('再来一单成功');
        return response;
      } else {
        console.error('再来一单失败:', response.error);
        return response;
      }
    } catch (error) {
      console.error('再来一单时发生错误:', error);
      return {
        success: false,
        error: '网络连接失败，请检查网络设置'
      };
    }
  }
 }
