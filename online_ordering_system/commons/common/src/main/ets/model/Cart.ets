import { CartItem } from './CartItem';

export class Cart {
  id: string = '';
  userId: string = '';
  restaurantId: string = '';
  items: CartItem[] = [];
  totalQuantity: number = 0;
  totalAmount: number = 0;
  discountAmount: number = 0;
  finalAmount: number = 0;
  createdAt: number = Date.now();
  updatedAt: number = Date.now();
  isPaid: boolean = false;
  isSaved: boolean = false; // 是否已保存到后端
  
  constructor(userId: string = '', restaurantId: string = '') {
    this.id = this.generateId();
    this.userId = userId;
    this.restaurantId = restaurantId;
    this.createdAt = Date.now();
    this.updatedAt = Date.now();
  }
  
  // 生成唯一ID
  private generateId(): string {
    return `cart_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
  
  // 添加商品到购物车
  addItem(item: CartItem): void {
    const existingItem = this.findExistingItem(item);
    
    if (existingItem) {
      // 如果商品已存在，增加数量
      existingItem.quantity += item.quantity;
    } else {
      // 如果商品不存在，添加新商品
      this.items.push(item);
    }
    
    this.updateTotals();
    this.updatedAt = Date.now();
  }
  
  // 查找已存在的商品
  private findExistingItem(newItem: CartItem): CartItem | undefined {
    return this.items.find(item => {
      if (newItem.dish && item.dish) {
        return item.dish.dishId === newItem.dish.dishId && item.note === newItem.note;
      }
      if (newItem.combo && item.combo) {
        return item.combo.comboId === newItem.combo.comboId && item.note === newItem.note;
      }
      return false;
    });
  }
  
  // 更新商品数量
  updateItemQuantity(itemId: string, quantity: number): void {
    const item = this.items.find(item => item.id === itemId);
    if (item) {
      if (quantity <= 0) {
        this.removeItem(itemId);
      } else {
        item.quantity = quantity;
        this.updateTotals();
        this.updatedAt = Date.now();
      }
    }
  }
  
  // 移除商品
  removeItem(itemId: string): void {
    const index = this.items.findIndex(item => item.id === itemId);
    if (index > -1) {
      this.items.splice(index, 1);
      this.updateTotals();
      this.updatedAt = Date.now();
    }
  }
  
  // 清空购物车
  clear(): void {
    this.items = [];
    this.updateTotals();
    this.updatedAt = Date.now();
  }
  
  // 更新总计
  updateTotals(): void {
    this.totalQuantity = this.items.reduce((total, item) => total + item.quantity, 0);
    this.totalAmount = this.items.reduce((total, item) => total + item.subtotal, 0);
    
    // 计算折扣（假设25%折扣）
    this.discountAmount = this.totalAmount * 0.25;
    this.finalAmount = this.totalAmount * 0.75;
  }
  
  // 检查购物车是否为空
  get isEmpty(): boolean {
    return this.items.length === 0;
  }
  
  // 获取购物车商品数量
  get itemCount(): number {
    return this.items.length;
  }
  
  // 标记为已保存
  markAsSaved(): void {
    this.isSaved = true;
    this.updatedAt = Date.now();
  }
  
  // 标记为已支付
  markAsPaid(): void {
    this.isPaid = true;
    this.updatedAt = Date.now();
  }
  
  // 克隆购物车
  clone(): Cart {
    const cloned = new Cart(this.userId, this.restaurantId);
    cloned.id = this.id;
    cloned.items = this.items.map(item => item.clone());
    cloned.totalQuantity = this.totalQuantity;
    cloned.totalAmount = this.totalAmount;
    cloned.discountAmount = this.discountAmount;
    cloned.finalAmount = this.finalAmount;
    cloned.createdAt = this.createdAt;
    cloned.updatedAt = this.updatedAt;
    cloned.isPaid = this.isPaid;
    cloned.isSaved = this.isSaved;
    return cloned;
  }
}