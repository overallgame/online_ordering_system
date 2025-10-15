import { CartItem } from "../viewModel/CartViewModel";


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

// 导航参数接口 - 为每个页面定义明确的参数类型
export interface DishDetailParams {
  dishId: string;
  hideCart?: boolean;
}

export interface ComboDetailParams {
  comboId: string;
  hideCart?: boolean;
}

export interface ComboRecommendParams {
  // 套餐推荐页面暂无参数
}

export interface OnlineOrderParams {
  // 在线点餐页面暂无参数
}

export interface DeliveryParams {
  // 外卖配送页面暂无参数
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

// 通用参数类型 - 用于类型安全的参数传递
export type NavigationParams = 
  | DishDetailParams 
  | ComboDetailParams 
  | ComboRecommendParams 
  | OnlineOrderParams 
  | DeliveryParams 
  | CheckoutParams 
  | PaymentSuccessParams;
