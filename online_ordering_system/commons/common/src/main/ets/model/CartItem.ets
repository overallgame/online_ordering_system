import { Dish } from "./Menu";
import { Combo } from "./Combo";

export class CartItem {
  id: string = '';
  dish?: Dish;
  combo?: Combo;
  quantity: number = 1;
  note?: string = '';
  addedTime: number = Date.now();
  
  constructor(dish?: Dish, combo?: Combo, quantity: number = 1) {
    this.id = this.generateId();
    this.dish = dish;
    this.combo = combo;
    this.quantity = quantity;
    this.addedTime = Date.now();
  }
  
  // 生成唯一ID
  private generateId(): string {
    return `cart_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
  
  // 获取商品名称
  get name(): string {
    return this.dish?.name || this.combo?.name || '';
  }
  
  // 获取商品价格
  get price(): number {
    return this.dish?.price || this.combo?.price || 0;
  }
  
  // 获取商品图片
  get image(): string {
    return this.dish?.image || this.combo?.icon || '';
  }
  
  // 获取商品描述
  get description(): string {
    return this.dish?.description || this.combo?.description || '';
  }
  
  // 获取小计价格
  get subtotal(): number {
    return this.price * this.quantity;
  }
  
  // 获取准备时间
  get preparationTime(): number {
    return this.dish?.preparationTime || this.combo?.preparationTime || 0;
  }
  
  // 克隆购物车项
  clone(): CartItem {
    const cloned = new CartItem(this.dish, this.combo, this.quantity);
    cloned.id = this.id;
    cloned.note = this.note;
    cloned.addedTime = this.addedTime;
    return cloned;
  }
}
