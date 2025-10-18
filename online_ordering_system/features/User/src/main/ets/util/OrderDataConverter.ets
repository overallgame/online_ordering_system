import { Order, OrderItem, OrderStatus, PaymentStatus, PaymentMethod, OrderType, Dish } from 'common';

/**
 * 接口数据模型定义（根据苍穹外卖接口文档）
 */
export interface ApiOrderDetail {
  id: number;
  name: string;
  orderId: number;
  dishId: number;
  setmealId?: number;
  dishFlavor?: string;
  number: number;
  amount: number;
  image: string;
}

export interface ApiOrder {
  id: number;
  number: string;
  status: number;
  userId: number;
  addressBookId: number;
  orderTime: string;
  checkoutTime: string;
  payMethod: number;
  payStatus: number;
  amount: number;
  remark: string;
  userName?: string;
  phone: string;
  address: string;
  consignee: string;
  cancelReason?: string;
  rejectionReason?: string;
  cancelTime?: string;
  estimatedDeliveryTime: string;
  deliveryStatus: number;
  deliveryTime?: string;
  packAmount: number;
  tablewareNumber: number;
  tablewareStatus: number;
  orderDetailList: ApiOrderDetail[];
}

export interface ApiOrderListResponse {
  total: number;
  records: ApiOrder[];
}

/**
 * 管理端订单搜索接口响应数据结构
 */
export interface AdminOrderSearchData {
  total: number;
  records: ApiOrder[];
}

export interface AdminOrderSearchResponse {
  code: number;
  msg: string | null;
  data: AdminOrderSearchData;
}

/**
 * 历史订单接口响应数据结构（根据苍穹外卖接口文档）
 */
export interface HistoryOrderData {
  total: number;
  records: ApiOrder[];
}

export interface HistoryOrderResponse {
  code: number;
  msg: string | null;
  data: HistoryOrderData;
}

/**
 * 订单数据转换器
 */
export class OrderDataConverter {
  
  /**
   * 将接口订单状态转换为应用订单状态
   */
  static convertOrderStatus(apiStatus: number): OrderStatus {
    const statusMap: Record<number, OrderStatus> = {
      1: OrderStatus.PENDING,      // 待付款
      2: OrderStatus.CONFIRMED,    // 已付款
      3: OrderStatus.PREPARING,    // 制作中
      4: OrderStatus.READY,        // 待取餐
      5: OrderStatus.COMPLETED,    // 已完成
      6: OrderStatus.CANCELLED     // 已取消
    };
    return statusMap[apiStatus] || OrderStatus.PENDING;
  }

  /**
   * 将接口支付状态转换为应用支付状态
   */
  static convertPaymentStatus(apiPayStatus: number): PaymentStatus {
    const statusMap: Record<number, PaymentStatus> = {
      0: PaymentStatus.PENDING,    // 待支付
      1: PaymentStatus.PAID,       // 已支付
      2: PaymentStatus.FAILED,     // 支付失败
      3: PaymentStatus.REFUNDED    // 已退款
    };
    return statusMap[apiPayStatus] || PaymentStatus.PENDING;
  }

  /**
   * 将接口支付方式转换为应用支付方式
   */
  static convertPaymentMethod(apiPayMethod: number): PaymentMethod {
    const methodMap: Record<number, PaymentMethod> = {
      1: PaymentMethod.WECHAT,     // 微信支付
      2: PaymentMethod.ALIPAY,     // 支付宝
      3: PaymentMethod.CASH        // 现金
    };
    return methodMap[apiPayMethod] || PaymentMethod.WECHAT;
  }

  /**
   * 将接口订单详情转换为应用订单项
   */
  static convertOrderDetail(apiDetail: ApiOrderDetail): OrderItem {
    const orderItem = new OrderItem();
    orderItem.itemId = apiDetail.id.toString();
    orderItem.quantity = apiDetail.number;
    orderItem.unitPrice = apiDetail.amount / apiDetail.number;
    orderItem.totalPrice = apiDetail.amount;
    orderItem.note = apiDetail.dishFlavor || '';
    
    // 创建Dish对象
    const dish = new Dish();
    dish.dishId = apiDetail.dishId.toString();
    dish.name = apiDetail.name;
    dish.price = orderItem.unitPrice;
    dish.image = apiDetail.image;
    dish.description = ''; // 接口中没有描述信息
    dish.category = ''; // 接口中没有分类信息
    dish.isAvailable = true; // 默认可用
    dish.stock = 0; // 接口中没有库存信息
    dish.tags = []; // 接口中没有标签信息
    dish.preparationTime = 15; // 默认准备时间15分钟
    dish.rating = 0; // 接口中没有评分信息
    dish.reviewCount = 0; // 接口中没有评论数量信息
    
    orderItem.dish = dish;
    
    return orderItem;
  }

  /**
   * 将接口订单转换为应用订单
   */
  static convertOrder(apiOrder: ApiOrder): Order {
    const order = new Order();
    
    // 基础信息
    order.orderId = apiOrder.id.toString();
    order.userId = apiOrder.userId.toString();
    order.restaurantId = '1'; // 默认餐厅ID，实际应该从接口获取
    
    // 金额信息
    order.totalAmount = apiOrder.amount;
    order.finalAmount = apiOrder.amount;
    order.discountAmount = 0; // 接口中没有折扣信息，设为0
    
    // 状态信息
    order.status = OrderDataConverter.convertOrderStatus(apiOrder.status);
    order.paymentStatus = OrderDataConverter.convertPaymentStatus(apiOrder.payStatus);
    order.paymentMethod = OrderDataConverter.convertPaymentMethod(apiOrder.payMethod);
    
    // 时间信息
    order.createTime = OrderDataConverter.parseTimeString(apiOrder.orderTime);
    order.updateTime = OrderDataConverter.parseTimeString(apiOrder.checkoutTime || apiOrder.orderTime);
    
    // 地址信息
    order.deliveryAddress = apiOrder.address;
    order.customerNote = apiOrder.remark;
    
    // 转换订单详情
    order.items = apiOrder.orderDetailList.map(detail => OrderDataConverter.convertOrderDetail(detail));
    
    return order;
  }

  /**
   * 将接口订单列表转换为应用订单列表
   */
  static convertOrderList(apiResponse: ApiOrderListResponse): Order[] {
    return apiResponse.records.map(order => OrderDataConverter.convertOrder(order));
  }



  /**
   * 将历史订单接口响应转换为应用订单列表
   */
  static convertHistoryOrderList(apiData: HistoryOrderData): Order[] {
    if (apiData && apiData.records) {
      return apiData.records.map(order => OrderDataConverter.convertOrder(order));
    }
    return [];
  }


  /**
   * 解析时间字符串为时间戳
   */
  static parseTimeString(timeStr: string): number {
    if (!timeStr) return 0;
    try {
      return new Date(timeStr).getTime();
    } catch (error) {
      console.warn('解析时间字符串失败:', timeStr, error);
      return 0;
    }
  }

  /**
   * 获取订单状态显示文本
   */
  static getStatusText(status: OrderStatus): string {
    const statusMap: Record<OrderStatus, string> = {
      [OrderStatus.PENDING]: '待付款',
      [OrderStatus.CONFIRMED]: '已付款',
      [OrderStatus.PREPARING]: '制作中',
      [OrderStatus.READY]: '待取餐',
      [OrderStatus.COMPLETED]: '已完成',
      [OrderStatus.CANCELLED]: '已取消'
    };
    return statusMap[status] || '未知状态';
  }

  /**
   * 获取订单状态颜色
   */
  static getStatusColor(status: OrderStatus): string {
    const colorMap: Record<OrderStatus, string> = {
      [OrderStatus.PENDING]: '#FF6B35',
      [OrderStatus.CONFIRMED]: '#4CAF50',
      [OrderStatus.PREPARING]: '#FF9800',
      [OrderStatus.READY]: '#2196F3',
      [OrderStatus.COMPLETED]: '#9E9E9E',
      [OrderStatus.CANCELLED]: '#F44336'
    };
    return colorMap[status] || '#9E9E9E';
  }

  /**
   * 格式化时间显示
   */
  static formatTime(timestamp: number): string {
    if (timestamp === 0) {
      return '未知时间';
    }
    const date = new Date(timestamp);
    
    // 手动格式化时间，避免使用toLocaleString的结构化类型问题
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    
    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }
}
