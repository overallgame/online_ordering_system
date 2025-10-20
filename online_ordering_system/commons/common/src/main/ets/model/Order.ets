import { CustomizationChoice, Dish } from "./Menu";
import { Combo } from "./Combo";
import { PaymentMethod } from "./User";

export class Order {
  orderId: string = '';
  orderNumber: string = ''; // 订单号
  userId: string = '';
  restaurantId: string = '';
  items: Array<OrderItem> = [];
  totalAmount: number = 0;
  discountAmount: number = 0;
  finalAmount: number = 0;
  status: OrderStatus = OrderStatus.PENDING;
  orderType: OrderType = OrderType.DINE_IN;
  createTime: number = 0;
  updateTime: number = 0;
  estimatedDeliveryTime?: number;
  actualDeliveryTime?: number;
  paymentMethod: PaymentMethod = PaymentMethod.WECHAT;
  paymentStatus: PaymentStatus = PaymentStatus.PENDING;
  tableNumber?: string;
  deliveryAddress?: string;
  customerNote?: string;
}

export class OrderItem {
  itemId: string = '';
  dish?: Dish;
  combo?: Combo;
  quantity: number = 0;//数量
  unitPrice: number = 0;
  totalPrice: number = 0;
  customizations: Array<SelectedCustomization> = [];
  note?: string;
}

export class SelectedCustomization {
  optionId: string = '';
  optionName: string = '';
  selectedChoices: Array<CustomizationChoice> = [];
}

export enum OrderStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  ACCEPTED = 'accepted',
  DELIVERING = 'delivering',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled'
}

export enum OrderType {
  DINE_IN = 'dine_in',
  TAKEAWAY = 'takeaway',
  DELIVERY = 'delivery'
}

export enum PaymentStatus {
  UNPAID = 'unpaid',
  PENDING = 'pending',
  PAID = 'paid',
  FAILED = 'failed',
  REFUNDED = 'refunded'
}