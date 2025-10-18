import { Cart, CartItem, Dish, Combo } from 'common';
import { ShoppingCartItem } from '../model/CartApiModels';

export class CartDataConverter {

  static convertApiDataToCart(apiItems: ShoppingCartItem[]): Cart {
    const cart = new Cart();
    
    // 合并相同商品
    const mergedItems = CartDataConverter.mergeSameItems(apiItems);
    
    cart.items = mergedItems.map(item => CartDataConverter.convertApiItemToCartItem(item));
    cart.totalAmount = CartDataConverter.calculateTotalAmount(mergedItems);
    cart.totalQuantity = CartDataConverter.calculateTotalQuantity(mergedItems);
    
    console.log(`[CartDataConverter] Original items: ${apiItems.length}, Merged items: ${mergedItems.length}`);
    
    return cart;
  }

  static convertApiItemToCartItem(apiItem: ShoppingCartItem): CartItem {
    const cartItem = new CartItem();
    
    cartItem.id = apiItem.id.toString();
    cartItem.quantity = apiItem.number;
    cartItem.note = apiItem.dishFlavor || '';
    cartItem.addedTime = new Date(apiItem.createTime).getTime();

    if (apiItem.dishId) {
      cartItem.dish = CartDataConverter.createDishFromApiItem(apiItem);
    } else if (apiItem.setmealId) {
      cartItem.combo = CartDataConverter.createComboFromApiItem(apiItem);
    }
    
    return cartItem;
  }

  static createDishFromApiItem(apiItem: ShoppingCartItem): Dish {
    const dish = new Dish();
    dish.dishId = apiItem.dishId!.toString();
    dish.name = apiItem.name;
    dish.image = apiItem.image;
    dish.price = apiItem.amount;
    dish.description = '';
    dish.tags = [];
    dish.rating = 0;
    dish.reviewCount = 0;
    dish.preparationTime = 0;
    dish.isAvailable = true;
    return dish;
  }

  static createComboFromApiItem(apiItem: ShoppingCartItem): Combo {
    const combo = new Combo();
    combo.comboId = apiItem.setmealId!.toString();
    combo.name = apiItem.name;
    combo.icon = apiItem.image;
    combo.price = apiItem.amount;
    combo.description = '';
    combo.tags = [];
    combo.rating = 0;
    combo.reviewCount = 0;
    combo.preparationTime = 0;
    combo.isAvailable = true;
    combo.dishes = [];
    return combo;
  }

  static convertApiItemsToCartItems(apiItems: ShoppingCartItem[]): CartItem[] {
    return apiItems.map(item => CartDataConverter.convertApiItemToCartItem(item));
  }

  static validateApiItem(apiItem: ShoppingCartItem): boolean {
    if (!apiItem.id || !apiItem.name || !apiItem.number || !apiItem.amount) {
      return false;
    }
    
    if (!apiItem.dishId && !apiItem.setmealId) {
      return false;
    }
    
    return true;
  }

  static convertValidApiItemsToCartItems(apiItems: ShoppingCartItem[]): CartItem[] {
    return apiItems
      .filter(item => CartDataConverter.validateApiItem(item))
      .map(item => CartDataConverter.convertApiItemToCartItem(item));
  }

  static getItemType(apiItem: ShoppingCartItem): 'dish' | 'combo' | 'unknown' {
    if (apiItem.dishId) {
      return 'dish';
    } else if (apiItem.setmealId) {
      return 'combo';
    }
    return 'unknown';
  }

  static calculateTotalAmount(apiItems: ShoppingCartItem[]): number {
    return apiItems.reduce((total, item) => total + (item.amount * item.number), 0);
  }

  static calculateTotalQuantity(apiItems: ShoppingCartItem[]): number {
    return apiItems.reduce((total, item) => total + item.number, 0);
  }

  // 合并相同商品
  static mergeSameItems(apiItems: ShoppingCartItem[]): ShoppingCartItem[] {
    const itemMap = new Map<string, ShoppingCartItem>();
    
    apiItems.forEach(item => {
      const key = CartDataConverter.generateItemKey(item);
      
      if (itemMap.has(key)) {
        const existingItem = itemMap.get(key)!;
        existingItem.number += item.number;
        existingItem.amount = existingItem.amount;
      } else {
        itemMap.set(key, item);
      }
    });
    
    return Array.from(itemMap.values());
  }

  // 生成商品唯一键
  static generateItemKey(item: ShoppingCartItem): string {
    const dishId = item.dishId || 0;
    const setmealId = item.setmealId || 0;

    return `${dishId}_${setmealId}`;
  }
}
