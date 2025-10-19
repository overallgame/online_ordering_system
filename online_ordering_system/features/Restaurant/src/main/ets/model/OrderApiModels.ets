/**
 * 订单相关API数据模型
 */

// 订单提交请求参数
export interface OrderSubmitDTO {
  addressBookId: number;
  amount: number;
  deliveryStatus: number; // 1立即送出 0选择具体时间
  estimatedDeliveryTime: string; // yyyy-MM-dd HH:mm:ss
  packAmount: number;
  payMethod: number;
  remark: string;
  tablewareNumber: number;
  tablewareStatus: number; // 1按餐量提供 0选择具体数量
}

// 订单提交响应数据
export interface OrderSubmitVO {
  id: number; // 订单id
  orderAmount: number; // 订单金额
  orderNumber: string; // 订单号
  orderTime: string; // 下单时间
}

// API响应格式
export interface OrderSubmitApiResponse {
  code: number;
  data: OrderSubmitVO;
  msg: string;
}

// 订单支付请求参数
export interface OrdersPaymentDTO {
  orderNumber: string; // 订单号
  payMethod: number; // 支付方式
}

// 订单支付响应数据
export interface PaymentResponse {
  code: number;
  data: object;
  msg: string;
}