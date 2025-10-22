import { ApiClient, ApiEndpoints, ApiResponse, CartItem } from 'common';
import { OrderSubmitDTO, OrderSubmitVO, OrdersPaymentDTO, PaymentResponse } from '../model/OrderApiModels';
import { OrderDataConverter } from '../util/OrderDataConverter';

interface OrderApiResponse {
  code: number;
  data: OrderSubmitVO;
  msg: string;
}

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

  async submitOrder(orderSubmitDTO: OrderSubmitDTO): Promise<ApiResponse<OrderApiResponse>> {
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

      const response = await this.apiClient.post<OrderApiResponse>(
        ApiEndpoints.ORDER_SUBMIT,
        orderSubmitDTO
      );
      console.log("submitOrder", JSON.stringify(response));

      if (response.success && response.data) {
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
    addressBookId: number,
    estimatedDeliveryTime: number,
  ): Promise<OrderApiResponse> {
    try {
      // 创建订单提交参数
      const orderSubmitDTO = OrderDataConverter.createOrderSubmitDTO(
        cartItems,
        orderType,
        addressBookId,
        estimatedDeliveryTime,
      );

      // 提交订单
      const result = await this.submitOrder(orderSubmitDTO);

      if (result.success && result.data) {
        return result.data;
      } else {
        return {
          code: result.code || 500,
          msg: result.error || '订单创建失败',
          data: {} as OrderSubmitVO
        };
      }
    } catch (error) {
      console.error('Failed to create and submit order:', error);
      return {
        code: 500,
        msg: '创建订单失败',
        data: {} as OrderSubmitVO
      };
    }
  }

  // 订单支付
  async payOrder(orderNumber: string, payMethod: number = 0): Promise<ApiResponse<PaymentResponse>> {
    try {
      const paymentDTO: OrdersPaymentDTO = {
        orderNumber: orderNumber,
        payMethod: payMethod
      };

      const response = await this.apiClient.put<PaymentResponse>(
        '/user/order/payment',
        paymentDTO
      );

      if (response.success && response.data) {
        return response;
      } else {
        console.warn('Failed to pay order:', response.error);
        return {
          success: false,
          error: response.error || '支付失败',
          code: response.code || 500
        };
      }
    } catch (error) {
      console.error('Failed to pay order:', error);
      return {
        success: false,
        error: '网络错误，请检查网络连接',
        code: 500
      };
    }
  }
}
