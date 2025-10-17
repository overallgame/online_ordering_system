import { Cart } from 'common';
import { ApiClient, ApiEndpoints, ApiResponse } from 'common';
import { ShoppingCartItem, ShoppingCartDTO} from '../model/CartApiModels';
import { CartDataConverter } from '../util/CartDataConverter';

export class CartRepository {
  private static instance: CartRepository;
  private apiClient: ApiClient = ApiClient.getInstance();
  
  private constructor() {}
  
  static getInstance(): CartRepository {
    if (!CartRepository.instance) {
      CartRepository.instance = new CartRepository();
    }
    return CartRepository.instance;
  }
  
  // ==================== 网络请求方法 ====================
  
  // 查看购物车
  async getCartList(): Promise<Cart | null> {
    try {
      const response: ApiResponse<ShoppingCartItem[]> = await this.apiClient.get(
        ApiEndpoints.CART_LIST
      );
      
      if (response.success && response.data) {
        return CartDataConverter.convertApiDataToCart(response.data);
      }
      
      console.warn('Failed to get cart list:', response.error);
      return null;
    } catch (error) {
      console.error('Failed to get cart list:', error);
      return null;
    }
  }

  // 添加商品到购物车
  async addToCart(dishId?: number, setmealId?: number, dishFlavor?: string): Promise<boolean> {
    try {
      const requestData: ShoppingCartDTO = {
        dishId,
        setmealId,
        dishFlavor
      };

      const response: ApiResponse<string> = await this.apiClient.post(
        ApiEndpoints.CART_ADD, 
        requestData
      );
      
      if (response.success) {
        console.log('Successfully added to cart');
        return true;
      } else {
        console.warn('Failed to add to cart:', response.error);
        return false;
      }
    } catch (error) {
      console.error('Failed to add to cart:', error);
      return false;
    }
  }

  // 删除购物车中一个商品
  async removeFromCart(dishId?: number, setmealId?: number, dishFlavor?: string): Promise<boolean> {
    try {
      const requestData: ShoppingCartDTO = {
        dishId,
        setmealId,
        dishFlavor
      };

      const response: ApiResponse<string> = await this.apiClient.post(
        ApiEndpoints.CART_REMOVE, 
        requestData
      );
      
      if (response.success) {
        console.log('Successfully removed from cart');
        return true;
      } else {
        console.warn('Failed to remove from cart:', response.error);
        return false;
      }
    } catch (error) {
      console.error('Failed to remove from cart:', error);
      return false;
    }
  }

  // 清空购物车
  async clearCart(): Promise<boolean> {
    try {
      const response: ApiResponse<string> = await this.apiClient.delete(
        ApiEndpoints.CART_CLEAR
      );
      
      if (response.success) {
        console.log('Successfully cleared cart');
        return true;
      } else {
        console.warn('Failed to clear cart:', response.error);
        return false;
      }
    } catch (error) {
      console.error('Failed to clear cart:', error);
      return false;
    }
  }

  // 更新商品数量（通过多次调用add/sub接口实现）
  async updateItemQuantity(targetQuantity: number, dishId?: number, setmealId?: number, dishFlavor?: string): Promise<boolean> {
    try {
      // 先获取当前购物车
      const currentCart = await this.getCartList();
      if (!currentCart) {
        console.warn('Failed to get current cart for quantity update');
        return false;
      }

      // 找到当前商品的数量
      const currentItem = currentCart.items.find(item => {
        if (dishId && item.dish) {
          return item.dish.dishId === dishId.toString();
        }
        if (setmealId && item.combo) {
          return item.combo.comboId === setmealId.toString();
        }
        return false;
      });
      
      if (!currentItem) {
        console.warn('Item not found in cart for quantity update');
        return false;
      }

      const currentQuantity = currentItem.quantity;
      const difference = targetQuantity - currentQuantity;

      if (difference > 0) {
        // 需要增加数量
        for (let i = 0; i < difference; i++) {
          const success = await this.addToCart(dishId, setmealId, dishFlavor);
          if (!success) {
            console.error(`Failed to add item on attempt ${i + 1}`);
            return false;
          }
        }
      } else if (difference < 0) {
        // 需要减少数量
        for (let i = 0; i < Math.abs(difference); i++) {
          const success = await this.removeFromCart(dishId, setmealId, dishFlavor);
          if (!success) {
            console.error(`Failed to remove item on attempt ${i + 1}`);
            return false;
          }
        }
      }

      console.log(`Successfully updated item quantity to ${targetQuantity}`);
      return true;
    } catch (error) {
      console.error('Failed to update item quantity:', error);
      return false;
    }
  }

  // 带重试机制的网络请求
  async addToCartWithRetry(dishId?: number, setmealId?: number, dishFlavor?: string, maxRetries: number = 3): Promise<boolean> {
    for (let i = 0; i < maxRetries; i++) {
      try {
        const success = await this.addToCart(dishId, setmealId, dishFlavor);
        if (success) return true;
        
        console.warn(`Add to cart attempt ${i + 1} failed, retrying...`);
      } catch (error) {
        console.error(`Add to cart attempt ${i + 1} failed:`, error);
      }
    }
    return false;
  }
}
