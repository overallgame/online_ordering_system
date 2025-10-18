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

  // 查看购物车
  async getCartList(): Promise<Cart | null> {
    try {
      interface CartListApiResponse {
        code: number;
        data: ShoppingCartItem[];
        msg: string;
      }

      const response: ApiResponse<CartListApiResponse> = await this.apiClient.get(
        ApiEndpoints.CART_LIST
      );
      
      if (response.success && response.data && response.data.data) {
        return CartDataConverter.convertApiDataToCart(response.data.data);
      }
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

      interface CartAddApiResponse {
        code: number;
        data: string;
        msg: string;
      }

      const response: ApiResponse<CartAddApiResponse> = await this.apiClient.post(
        ApiEndpoints.CART_ADD, 
        requestData
      );
      
      if (response.success && response.data) {
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

      interface CartRemoveApiResponse {
        code: number;
        data: string;
        msg: string;
      }

      const response: ApiResponse<CartRemoveApiResponse> = await this.apiClient.post(
        ApiEndpoints.CART_REMOVE, 
        requestData
      );
      
      if (response.success && response.data) {
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
      interface CartClearApiResponse {
        code: number;
        data: string;
        msg: string;
      }

      const response: ApiResponse<CartClearApiResponse> = await this.apiClient.delete(
        ApiEndpoints.CART_CLEAR
      );
      
      if (response.success && response.data) {
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
}
