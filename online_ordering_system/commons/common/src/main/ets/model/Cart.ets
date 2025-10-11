import { Dish } from "./Menu";
import { SelectedCustomization } from "./Order";

export class ShoppingCart {
  restaurantId?: string;
  items: Array<CartItem> = [];
  totalQuantity: number = 0;
  totalAmount: number = 0;
  lastUpdateTime: number = 0;

  constructor() {
    this.loadFromStorage();
  }

  // 从本地存储加载购物车数据
  private loadFromStorage(): void {
    // 实现从Preferences加载购物车数据的逻辑
  }

  // 保存购物车数据到本地存储
  saveToStorage(): void {
    // 实现保存到Preferences的逻辑
  }

  // 清空购物车
  clear(): void {
    this.restaurantId = undefined;
    this.items = [];
    this.totalQuantity = 0;
    this.totalAmount = 0;
    this.saveToStorage();
  }
}

export class CartItem {
  dish: Dish = new Dish();
  quantity: number = 0;
  customizations: Array<SelectedCustomization> = [];
  note?: string;

  get totalPrice(): number {
    let basePrice = this.dish.price * this.quantity;
    let customizationPrice = this.customizations.reduce((total, customization) => {
      return total + customization.selectedChoices.reduce((choiceTotal, choice) => {
        return choiceTotal + choice.price * this.quantity;
      }, 0);
    }, 0);
    return basePrice + customizationPrice;
  }
}