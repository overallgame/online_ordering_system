import { CartItem } from "common";


// 导航路径类型定义 - 参照成功案例
export interface NavPath {
  name: string;
  params?: Record<string, Object>;
}

// 页面名称枚举
export enum PageName {
  HOME = 'HomePage',
  DISH_DETAIL = 'dishDetail',
  COMBO_DETAIL = 'comboDetail',
  COMBO_RECOMMEND = 'comboRecommend',
  ONLINE_ORDER = 'onlineOrder',
  DELIVERY = 'delivery',
  CHECKOUT = 'checkout',
  PAYMENT_SUCCESS = 'paymentSuccess'
}

export interface ComboDetailParams {
  comboId: string;
  hideCart?: boolean;
}

export interface CheckoutParams {
  orderId?: string;
  source?: string;
  cartItems?: CartItem[];
}

export interface PaymentSuccessParams {
  orderId: string;
  totalAmount: number;
}
