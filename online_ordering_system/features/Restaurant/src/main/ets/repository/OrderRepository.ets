import { ApiClient, ApiEndpoints, ApiResponse, CartItem } from 'common';
import { OrderSubmitDTO, OrderSubmitVO } from '../model/OrderApiModels';
import { OrderDataConverter } from '../util/OrderDataConverter';

export class OrderRepository {
  private static instance: OrderRepository;
  private apiClient: ApiClient = ApiClient.getInstance();

  private constructor() {}

  static getInstance(): OrderRepository {
    if (!OrderRepository.instance) {
      OrderRepository.instance = new OrderRepository();
    }
    return OrderRepository.instance;
  }

  async submitOrder(orderSubmitDTO: OrderSubmitDTO): Promise<ApiResponse<OrderSubmitVO>> {
    try {
      // 验证参数
      const validation = OrderDataConverter.validateOrderSubmitDTO(orderSubmitDTO);
      if (!validation.valid) {
        return {
          success: false,
          error: validation.error || '订单参数验证失败',
          code: 400
        };
      }

      const response: ApiResponse<OrderSubmitVO> = await this.apiClient.post(
        ApiEndpoints.ORDER_SUBMIT,
        orderSubmitDTO
      );

      if (response.success && response.data) {
        console.log('Order submitted successfully:', response.data.orderNumber);
        return response;
      } else {
        console.warn('Failed to submit order:', response.error);
        return {
          success: false,
          error: response.error || '订单提交失败',
          code: response.code || 500
        };
      }
    } catch (error) {
      console.error('Failed to submit order:', error);
      return {
        success: false,
        error: '网络错误，请检查网络连接',
        code: 500
      };
    }
  }

  async createAndSubmitOrder(
    cartItems: CartItem[],
    orderType: 'dine_in' | 'delivery',
    estimatedDeliveryTime?: number,
    remark?: string
  ): Promise<ApiResponse<OrderSubmitVO>> {
    try {
      // 创建订单提交参数
      const orderSubmitDTO = OrderDataConverter.createOrderSubmitDTO(
        cartItems,
        orderType,
        estimatedDeliveryTime,
        remark
      );

      // 提交订单
      return await this.submitOrder(orderSubmitDTO);
    } catch (error) {
      console.error('Failed to create and submit order:', error);
      return {
        success: false,
        error: '创建订单失败',
        code: 500
      };
    }
  }

  async submitOrderWithRetry(
    orderSubmitDTO: OrderSubmitDTO,
    maxRetries: number = 3
  ): Promise<ApiResponse<OrderSubmitVO>> {
    for (let i = 0; i < maxRetries; i++) {
      try {
        const result = await this.submitOrder(orderSubmitDTO);
        if (result.success) {
          return result;
        }
        
        console.warn(`Order submit attempt ${i + 1} failed, retrying...`);
      } catch (error) {
        console.error(`Order submit attempt ${i + 1} failed:`, error);
        if (i === maxRetries - 1) {
          return {
            success: false,
            error: '订单提交失败，请重试',
            code: 500
          };
        }
      }
    }
    
    return {
      success: false,
      error: '订单提交失败，请重试',
      code: 500
    };
  }

  calculateOrderAmount(cartItems: CartItem[], orderType: 'dine_in' | 'delivery'): number {
    const baseAmount = cartItems.reduce((total, item) => {
      const price = item.combo?.price || item.dish?.price || 0;
      return total + (price * item.quantity);
    }, 0);

    // 外卖需要加打包费
    const packAmount = orderType === 'delivery' ? 2 : 0;
    
    return baseAmount + packAmount;
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
    if (scheduledTime) {
      return scheduledTime;
    }

    const now = new Date();
    const preparationTime = OrderDataConverter.calculatePreparationTime(cartItems);
    
    if (orderType === 'delivery') {
      // 外卖：准备时间 + 15分钟配送时间
      return now.getTime() + (preparationTime + 15) * 60 * 1000;
    } else {
      // 堂食：准备时间
      return now.getTime() + preparationTime * 60 * 1000;
    }
  }
}
