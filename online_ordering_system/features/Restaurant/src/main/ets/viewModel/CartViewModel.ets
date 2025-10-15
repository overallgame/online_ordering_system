import { Combo, Dish } from 'common';

export interface CartItem {
  combo?: Combo;
  dish?: Dish;
  quantity: number;
  addedTime: number;
}

export class CartViewModel {
  items: CartItem[] = [];
  totalQuantity: number = 0;
  totalAmount: number = 0;

  // 添加套餐到购物车
  addToCart(combo: Combo): void {
    const existingItem = this.items.find(item => item.combo?.comboId === combo.comboId);
    
    if (existingItem) {
      existingItem.quantity += 1;
    } else {
      this.items.push({
        combo: combo,
        quantity: 1,
        addedTime: Date.now()
      });
    }
    
    this.updateTotals();
  }

  // 添加菜品到购物车
  addDishToCart(dish: Dish): void {
    const existingItem = this.items.find(item => item.dish?.dishId === dish.dishId);
    
    if (existingItem) {
      existingItem.quantity += 1;
    } else {
      this.items.push({
        dish: dish,
        quantity: 1,
        addedTime: Date.now()
      });
    }
    
    this.updateTotals();
  }

  // 从购物车移除套餐
  removeFromCart(comboId: string): void {
    this.items = this.items.filter(item => item.combo?.comboId !== comboId);
    this.updateTotals();
  }

  // 从购物车移除菜品
  removeDishFromCart(dishId: string): void {
    this.items = this.items.filter(item => item.dish?.dishId !== dishId);
    this.updateTotals();
  }

  // 更新套餐数量
  updateQuantity(comboId: string, quantity: number): void {
    if (quantity <= 0) {
      this.removeFromCart(comboId);
      return;
    }
    
    const item = this.items.find(item => item.combo?.comboId === comboId);
    if (item) {
      item.quantity = quantity;
      this.updateTotals();
    }
  }

  // 更新菜品数量
  updateDishQuantity(dishId: string, quantity: number): void {
    if (quantity <= 0) {
      this.removeDishFromCart(dishId);
      return;
    }
    
    const item = this.items.find(item => item.dish?.dishId === dishId);
    if (item) {
      item.quantity = quantity;
      this.updateTotals();
    }
  }

  // 清空购物车
  clearCart(): void {
    this.items = [];
    this.updateTotals();
  }

  // 更新总计
  private updateTotals(): void {
    this.totalQuantity = this.items.reduce((total, item) => total + item.quantity, 0);
    this.totalAmount = this.items.reduce((total, item) => {
      if (item.combo) {
        return total + (item.combo.price * item.quantity);
      } else if (item.dish) {
        return total + (item.dish.price * item.quantity);
      }
      return total;
    }, 0);
  }

  // 获取购物车中的套餐数量
  getItemQuantity(comboId: string): number {
    const item = this.items.find(item => item.combo?.comboId === comboId);
    return item ? item.quantity : 0;
  }

  // 获取购物车中的菜品数量
  getDishQuantity(dishId: string): number {
    const item = this.items.find(item => item.dish?.dishId === dishId);
    return item ? item.quantity : 0;
  }

  // 检查购物车是否为空
  get isEmpty(): boolean {
    return this.items.length === 0;
  }
}
