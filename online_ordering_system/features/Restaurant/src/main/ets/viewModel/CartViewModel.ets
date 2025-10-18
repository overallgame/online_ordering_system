import { Cart, CartItem, Dish, Combo } from 'common';
import { CartRepository } from '../repository/CartRepository';

export class CartViewModel {
  private cart: Cart;
  private repository: CartRepository;
  private listeners: Array<(cart: Cart) => void> = [];
  private autoSaveTimer?: number;
  private isLoading: boolean = false;
  private error?: string = undefined;
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
  
  // 获取当前购物车
  getCart(): Cart {
    return this.cart;
  }
  
  // 获取购物车商品列表
  getItems(): CartItem[] {
    return this.cart.items;
  }
  
  // 获取购物车商品数量
  getItemCount(): number {
    return this.cart.totalQuantity;
  }
  
  // 获取购物车商品种类数
  getItemTypesCount(): number {
    return this.cart.itemCount;
  }
  
  // 获取总金额
  getTotalAmount(): number {
    return this.cart.totalAmount;
  }
  
  // 获取折扣金额
  getDiscountAmount(): number {
    return this.cart.discountAmount;
  }
  
  // 获取最终金额
  getFinalAmount(): number {
    return this.cart.finalAmount;
  }
  
  // 获取加载状态
  getIsLoading(): boolean {
    return this.isLoading;
  }
  
  // 获取错误信息
  getError(): string | undefined {
    return this.error;
  }
  
  // 清除错误
  clearError(): void {
    this.error = undefined;
  }
  
  // 添加商品到购物车
  async addItem(dish?: Dish, combo?: Combo, quantity: number = 1, note?: string): Promise<boolean> {
    // 参数验证
    if (!dish && !combo) {
      this.error = 'Either dish or combo must be provided';
      console.error('Either dish or combo must be provided');
      return false;
    }
    
    if (quantity <= 0) {
      this.error = 'Quantity must be greater than 0';
      console.error('Quantity must be greater than 0');
      return false;
    }
    
    this.isLoading = true;
    this.error = undefined;
    
    try {
      // 直接调用网络API添加商品
      const success = await this.repository.addToCart(
        dish?.dishId ? parseInt(dish.dishId) : undefined,
        combo?.comboId ? parseInt(combo.comboId) : undefined,
        note
      );
      
      if (success) {
        // 添加成功后重新加载购物车，确保显示正确的商品
        await this.loadCart();
        return true;
      } else {
        this.error = '网络同步失败，请重试';
        return false;
      }
    } catch (error) {
      console.error('Failed to add item to cart:', error);
      this.error = '网络连接失败，请检查网络';
      return false;
    } finally {
      this.isLoading = false;
    }
  }
  
  // 更新商品数量
  async updateItemQuantity(itemId: string, quantity: number): Promise<boolean> {
    // 参数验证
    if (!itemId) {
      console.error('Item ID is required');
      return false;
    }
    
    if (quantity < 0) {
      console.error('Quantity cannot be negative');
      return false;
    }
    
    // 找到对应的商品项
    const cartItem = this.cart.items.find(item => item.id === itemId);
    if (!cartItem) {
      console.error('Cart item not found:', itemId);
      return false;
    }
    
    try {
      // 调用网络API更新数量
      const success = await this.repository.updateItemQuantity(
        quantity,
        cartItem.dish?.dishId ? parseInt(cartItem.dish.dishId) : undefined,
        cartItem.combo?.comboId ? parseInt(cartItem.combo.comboId) : undefined,
        cartItem.note
      );
      
      if (success) {
        // 更新成功后重新加载购物车
        await this.loadCart();
        return true;
      } else {
        this.error = '网络同步失败，请重试';
        return false;
      }
    } catch (error) {
      console.error('Failed to update item quantity:', error);
      this.error = '网络连接失败，请检查网络';
      return false;
    }
  }
  
  // 移除商品
  async removeItem(itemId: string): Promise<boolean> {
    // 找到对应的商品项
    const cartItem = this.cart.items.find(item => item.id === itemId);
    if (!cartItem) {
      console.error('Cart item not found:', itemId);
      return false;
    }
    
    try {
      // 调用网络API移除商品
      const success = await this.repository.removeFromCart(
        cartItem.dish?.dishId ? parseInt(cartItem.dish.dishId) : undefined,
        cartItem.combo?.comboId ? parseInt(cartItem.combo.comboId) : undefined,
        cartItem.note
      );
      
      if (success) {
        // 移除成功后重新加载购物车
        await this.loadCart();
        return true;
      } else {
        this.error = '网络同步失败，请重试';
        return false;
      }
    } catch (error) {
      console.error('Failed to remove item from cart:', error);
      this.error = '网络连接失败，请检查网络';
      return false;
    }
  }
  
  // 清空购物车
  async clearCart(): Promise<boolean> {
    try {
      // 调用网络API清空购物车
      const success = await this.repository.clearCart();
      
      if (success) {
        // 清空成功后重新加载购物车
        await this.loadCart();
        return true;
      } else {
        this.error = '网络同步失败，请重试';
        return false;
      }
    } catch (error) {
      console.error('Failed to clear cart:', error);
      this.error = '网络连接失败，请检查网络';
      return false;
    }
  }
  
  // 加载购物车（从后端加载，但只显示当前页面的商品）
  async loadCart(): Promise<boolean> {
    try {
      // 从网络API加载购物车
      const networkCart = await this.repository.getCartList();
      
      if (networkCart) {
        // 根据页面类型过滤商品，只显示当前页面类型的商品
        const filteredItems = this.filterItemsByPageType(networkCart.items);
        this.cart.items = filteredItems;
        this.cart.updateTotals();
        this.notifyListeners();
        console.log(`${this.pageType}: Cart loaded with ${filteredItems.length} items`);
        return true;
      } else {
        console.warn(`${this.pageType}: Failed to load cart from network`);
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
      // 根据页面类型决定显示哪些商品
      switch (this.pageType) {
        case 'delivery':
          // 外卖配送页只显示菜品
          return item.dish !== undefined && item.combo === undefined;
        case 'online':
          // 在线点餐页只显示菜品
          return item.dish !== undefined && item.combo === undefined;
        case 'combo':
          // 套餐推荐页只显示套餐
          return item.combo !== undefined && item.dish === undefined;
        default:
          // 默认显示所有商品
          return true;
      }
    });
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
