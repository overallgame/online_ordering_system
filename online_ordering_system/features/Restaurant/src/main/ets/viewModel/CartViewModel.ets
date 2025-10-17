import { Cart, CartItem, Dish, Combo } from 'common';
import { CartRepository } from '../repository/CartRepository';

export class CartViewModel {
  private cart: Cart;
  private repository: CartRepository;
  private listeners: Array<(cart: Cart) => void> = [];
  
  constructor(userId: string = '', restaurantId: string = '') {
    this.cart = new Cart(userId, restaurantId);
    this.repository = CartRepository.getInstance();
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
  
  // 检查购物车是否为空
  isEmpty(): boolean {
    return this.cart.isEmpty;
  }
  
  // 添加商品到购物车
  async addItem(dish?: Dish, combo?: Combo, quantity: number = 1, note?: string): Promise<boolean> {
    try {
      // 参数验证
      if (!dish && !combo) {
        console.error('Either dish or combo must be provided');
        return false;
      }
      
      if (quantity <= 0) {
        console.error('Quantity must be greater than 0');
        return false;
      }
      
      const cartItem = new CartItem(dish, combo, quantity);
      if (note) {
        cartItem.note = note;
      }
      
      this.cart.addItem(cartItem);
      this.notifyListeners();
      
      // 保存到本地存储
      const saveSuccess = await this.repository.saveCart(this.cart);
      if (!saveSuccess) {
        console.warn('Failed to save cart to local storage');
      }
      
      console.log('Item added to cart:', cartItem.name);
      return true;
    } catch (error) {
      console.error('Failed to add item to cart:', error);
      return false;
    }
  }
  
  // 更新商品数量
  async updateItemQuantity(itemId: string, quantity: number): Promise<boolean> {
    try {
      // 参数验证
      if (!itemId) {
        console.error('Item ID is required');
        return false;
      }
      
      if (quantity < 0) {
        console.error('Quantity cannot be negative');
        return false;
      }
      
      this.cart.updateItemQuantity(itemId, quantity);
      this.notifyListeners();
      
      // 保存到本地存储
      const saveSuccess = await this.repository.saveCart(this.cart);
      if (!saveSuccess) {
        console.warn('Failed to save cart to local storage');
      }
      
      console.log('Item quantity updated:', itemId, quantity);
      return true;
    } catch (error) {
      console.error('Failed to update item quantity:', error);
      return false;
    }
  }
  
  // 移除商品
  async removeItem(itemId: string): Promise<boolean> {
    try {
      this.cart.removeItem(itemId);
      this.notifyListeners();
      
      // 保存到本地存储
      await this.repository.saveCart(this.cart);
      
      console.log('Item removed from cart:', itemId);
      return true;
    } catch (error) {
      console.error('Failed to remove item from cart:', error);
      return false;
    }
  }
  
  // 清空购物车
  async clearCart(): Promise<boolean> {
    try {
      this.cart.clear();
      this.notifyListeners();
      
      // 清空本地存储
      await this.repository.clearCart();
      
      console.log('Cart cleared');
      return true;
    } catch (error) {
      console.error('Failed to clear cart:', error);
      return false;
    }
  }
  
  // 加载购物车
  async loadCart(): Promise<boolean> {
    try {
      const savedCart = await this.repository.loadCart();
      if (savedCart) {
        this.cart = savedCart;
        this.notifyListeners();
        console.log('Cart loaded from storage');
        return true;
      }
      return false;
    } catch (error) {
      console.error('Failed to load cart:', error);
      return false;
    }
  }
  
  // 同步购物车到后端
  async syncCart(userId: string): Promise<boolean> {
    try {
      const syncedCart = await this.repository.syncCart(userId);
      if (syncedCart) {
        this.cart = syncedCart;
        this.notifyListeners();
        console.log('Cart synced with backend');
        return true;
      }
      return false;
    } catch (error) {
      console.error('Failed to sync cart:', error);
      return false;
    }
  }
  
  // 保存购物车到后端
  async saveCartToBackend(): Promise<boolean> {
    try {
      const success = await this.repository.saveCartToBackend(this.cart);
      if (success) {
        this.notifyListeners();
        console.log('Cart saved to backend');
      }
      return success;
    } catch (error) {
      console.error('Failed to save cart to backend:', error);
      return false;
    }
  }
  
  // 检查是否需要同步
  async needsSync(): Promise<boolean> {
    try {
      return await this.repository.needsSync();
    } catch (error) {
      console.error('Failed to check sync status:', error);
      return false;
    }
  }
  
  // 标记购物车为已支付
  async markAsPaid(): Promise<boolean> {
    try {
      this.cart.markAsPaid();
      
      // 保存到历史记录
      await this.repository.saveCartHistory(this.cart);
      
      // 清空当前购物车
      await this.clearCart();
      
      console.log('Cart marked as paid');
      return true;
    } catch (error) {
      console.error('Failed to mark cart as paid:', error);
      return false;
    }
  }
  
  // 设置用户ID
  setUserId(userId: string): void {
    this.cart.userId = userId;
  }
  
  // 设置餐厅ID
  setRestaurantId(restaurantId: string): void {
    this.cart.restaurantId = restaurantId;
  }
  
  // 获取购物车历史记录
  async getCartHistory(): Promise<Cart[]> {
    try {
      return await this.repository.getCartHistory();
    } catch (error) {
      console.error('Failed to get cart history:', error);
      return [];
    }
  }
  
  // 自动保存购物车（定时保存）
  startAutoSave(intervalMs: number = 30000): void {
    setInterval(async () => {
      if (!this.cart.isEmpty && !this.cart.isPaid) {
        await this.repository.saveCart(this.cart);
        console.log('Cart auto-saved');
      }
    }, intervalMs);
  }
  
  // 销毁ViewModel
  destroy(): void {
    this.listeners = [];
  }
}