import { ShoppingCart } from "./Cart";
import { Restaurant } from "./Restaurant";
import { User } from "./User";

export class AppState {
  // 当前用户
  currentUser: User | null = null;

  // 当前选择的餐厅
  currentRestaurant: Restaurant | null = null;

  // 购物车
  shoppingCart: ShoppingCart = new ShoppingCart();

  // 网络状态
  isOnline: boolean = true;

  // 应用主题
  theme: 'light' | 'dark' = 'light';

  // 地理位置
  location: Location | null = null;

  // 通知设置
  notifications: NotificationSettings = new NotificationSettings();
}

export class Location {
  latitude: number = 0;
  longitude: number = 0;
  address: string = '';
  city: string = '';
}

export class NotificationSettings {
  orderUpdates: boolean = true;
  promotions: boolean = true;
  systemMessages: boolean = true;
}

export { ShoppingCart, User };
