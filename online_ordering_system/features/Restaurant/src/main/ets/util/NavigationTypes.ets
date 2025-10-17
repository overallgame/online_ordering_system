import { CartItem } from "common";

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

export interface CheckoutParams {
  orderId?: string;
  source?: string;
  cartItems?: CartItem[];
}

export interface PaymentSuccessParams {
  orderId: string;
  totalAmount: number;
}
