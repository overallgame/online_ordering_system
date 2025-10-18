import { Cart, CartItem, Dish, Combo } from 'common';
import { CartRepository } from '../repository/CartRepository';

export class CartViewModel {
  private cart: Cart;
  private repository: CartRepository;
  private listeners: Array<(cart: Cart) => void> = [];
  private autoSaveTimer?: number;
  private pageType: string; // 页面类型标识
  
  constructor(userId: string = '', restaurantId: string = '', pageType: string = 'default') {
    this.cart = new Cart(userId, restaurantId);
    this.repository = CartRepository.getInstance();
    this.pageType = pageType;
  }
  
  // 添加监听器
  addListener(listener: (cart: Cart) => void): void {
    this.listeners.push(listener);
  }
  
  // 移除监听器
  removeListener(listener: (cart: Cart) => void): void {
    const index = this.listeners.indexOf(listener);
    if (index > -1) {
      this.listeners.splice(index, 1);
    }
  }
  
  // 通知所有监听器
  private notifyListeners(): void {
    this.listeners.forEach(listener => listener(this.cart));
  }

  // 获取购物车商品列表
  getItems(): CartItem[] {
    return this.cart.items;
  }

  // 通过ID添加商品到购物车
  async addItemById(dishId?: number, comboId?: number, note?: string): Promise<boolean> {
    if (!dishId && !comboId) {
      return false;
    }

    try {
      const randomNote = note || CartViewModel.generateRandomNote();
      
      const success = await this.repository.addToCart(dishId, comboId, randomNote);
      
      if (success) {
        await this.loadCart();
        return true;
      } else {
        return false;
      }
    } catch (error) {
      console.error('Failed to add item to cart by ID:', error);
      return false;
    }
  }

  // 通过ID移除商品
  async removeItemById(dishId?: number, comboId?: number, note?: string): Promise<boolean> {
    if (!dishId && !comboId) {
      return false;
    }
    
    try {
      const success = await this.repository.removeFromCart(dishId, comboId, note);
      
      if (success) {
        await this.loadCart();
        return true;
      } else {
        return false;
      }
    } catch (error) {
      console.error('Failed to remove item from cart by ID:', error);
      return false;
    }
  }

  async clearCart(): Promise<boolean> {
    try {
      const success = await this.repository.clearCart();
      
      if (success) {
        await this.loadCart();
        return true;
      } else {
        return false;
      }
    } catch (error) {
      console.error('Failed to clear cart:', error);
      return false;
    }
  }

  async loadCart(): Promise<boolean> {
    try {
      const networkCart = await this.repository.getCartList();
      
      if (networkCart) {
        const filteredItems = this.filterItemsByPageType(networkCart.items);
        this.cart.items = filteredItems;
        this.cart.updateTotals();
        this.notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (error) {
      console.error(`${this.pageType}: Failed to load cart:`, error);
      return false;
    }
  }
  
  // 根据页面类型过滤商品
  private filterItemsByPageType(items: CartItem[]): CartItem[] {
    return items.filter(item => {
      switch (this.pageType) {
        case 'delivery':
          return item.dish !== undefined && item.combo === undefined;
        case 'online':
          return item.dish !== undefined && item.combo === undefined;
        case 'combo':
          return item.combo !== undefined && item.dish === undefined;
        default:
          return true;
      }
    });
  }

  // 生成随机note
  private static generateRandomNote(): string {
    const notes = [
      '微辣',
      '中辣',
      '特辣',
      '不辣',
      '少盐',
      '多盐',
      '少油',
      '多油',
      '不要香菜',
      '多加香菜',
      '不要葱',
      '多加葱',
      '不要蒜',
      '多加蒜',
      '清淡口味',
      '重口味',
      '现做',
      '打包带走',
      '堂食',
      '外卖'
    ];

    const randomIndex = Math.floor(Math.random() * notes.length);
    return notes[randomIndex];
  }

  // 自动保存购物车（定时保存）
  startAutoSave(intervalMs: number = 30000): void {
    // 停止之前的定时器
    if (this.autoSaveTimer) {
      clearInterval(this.autoSaveTimer);
    }

    // 启动新的定时器
    this.autoSaveTimer = setInterval(async () => {
      if (!this.cart.isEmpty && !this.cart.isPaid) {
        // 从网络重新加载购物车数据，确保数据同步
        await this.loadCart();
        console.log(`${this.pageType}: Cart auto-synced`);
      }
    }, intervalMs);
  }

  // 停止自动保存
  stopAutoSave(): void {
    if (this.autoSaveTimer) {
      clearInterval(this.autoSaveTimer);
      this.autoSaveTimer = undefined;
    }
  }

  // 销毁ViewModel
  destroy(): void {
    this.stopAutoSave();
    this.listeners = [];
  }
}
