import { CartItem, Order, OrderItem, OrderStatus, PaymentStatus } from 'common';
import { OrderSubmitDTO, OrderSubmitVO } from '../model/OrderApiModels';

// 验证结果接口
interface ValidationResult {
  valid: boolean;
  error?: string;
}

export class OrderDataConverter {

  static convertOrderSubmitToOrder(orderSubmitVO: OrderSubmitVO, cartItems?: CartItem[], isPaid: boolean = true): Order {
    const order = new Order();
    order.orderId = orderSubmitVO.id.toString();
    order.totalAmount = orderSubmitVO.orderAmount;
    order.finalAmount = orderSubmitVO.orderAmount;
    order.createTime = new Date(orderSubmitVO.orderTime).getTime();
    order.status = OrderStatus.PENDING;
    order.paymentStatus = isPaid ? PaymentStatus.PAID : PaymentStatus.PENDING;

    if (cartItems && cartItems.length > 0) {
      order.items = OrderDataConverter.convertCartItemsToOrderItems(cartItems);
    }
    
    return order;
  }

  static convertCartItemsToOrderItems(cartItems: CartItem[]): OrderItem[] {
    return cartItems.map((cartItem, index) => {
      const orderItem = new OrderItem();
      orderItem.itemId = `${Date.now()}_${index}`;
      orderItem.quantity = cartItem.quantity;
      orderItem.unitPrice = cartItem.combo?.price || cartItem.dish?.price || 0;
      orderItem.totalPrice = (cartItem.combo?.price || cartItem.dish?.price || 0) * cartItem.quantity;
      orderItem.customizations = [];
      orderItem.note = cartItem.note || '';

      if (cartItem.dish) {
        orderItem.dish = cartItem.dish;
      }
      if (cartItem.combo) {
        orderItem.combo = cartItem.combo;
      }

      return orderItem;
    });
  }

  static createOrderSubmitDTO(
    cartItems: CartItem[],
    orderType: 'dine_in' | 'delivery',
    addressBookId: number,
    estimatedDeliveryTime?: number,
    remark?: string,
    isPaid: boolean = true
  ): OrderSubmitDTO {
    // 计算总金额
    const baseAmount = cartItems.reduce((total, item) => {
      const price = item.combo?.price || item.dish?.price || 0;
      return total + (price * item.quantity);
    }, 0);

    // 计算打包费
    const packAmount = orderType === 'delivery' ? 2 : 0;
    const totalAmount = baseAmount + packAmount;

    // 格式化送达时间
    const formatDeliveryTime = (timestamp?: number): string => {
      if (!timestamp) {
        return new Date().toISOString().slice(0, 19).replace('T', ' ');
      }
      return new Date(timestamp).toISOString().slice(0, 19).replace('T', ' ');
    };

    return {
      addressBookId: addressBookId,
      amount: totalAmount,
      deliveryStatus: orderType === 'delivery' ? 1 : 0,
      estimatedDeliveryTime: formatDeliveryTime(estimatedDeliveryTime),
      packAmount: orderType === 'delivery' ? 2 : 0,
      payMethod: isPaid ? 1 : 0,
      remark: remark || '',
      tablewareNumber: orderType === 'delivery' ? 1 : 0,
      tablewareStatus: orderType === 'delivery' ? 1 : 0
    };
  }

  static validateOrderSubmitDTO(dto: OrderSubmitDTO): ValidationResult {
    if (!dto.addressBookId && dto.deliveryStatus === 1) {
      return { valid: false, error: '外卖订单需要选择配送地址' };
    }
    
    if (dto.amount <= 0) {
      return { valid: false, error: '订单金额必须大于0' };
    }
    
    if (!dto.estimatedDeliveryTime) {
      return { valid: false, error: '必须设置预计送达时间' };
    }
    
    return { valid: true };
  }

  static formatOrderTime(orderTime: number): string {
    const date = new Date(orderTime);
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    
    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }

  static calculatePreparationTime(cartItems: CartItem[]): number {
    let maxPreparationTime = 0;
    cartItems.forEach(item => {
      const preparationTime = item.combo?.preparationTime || item.dish?.preparationTime || 0;
      maxPreparationTime = Math.max(maxPreparationTime, preparationTime);
    });
    return maxPreparationTime;
  }
}
