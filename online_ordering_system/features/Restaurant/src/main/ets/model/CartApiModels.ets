// API响应数据结构
export interface ShoppingCartApiResponse<T> {
  code: number;
  data: T;
  msg: string;
}

// 购物车商品项（API返回格式）
export interface ShoppingCartItem {
  id: number;
  userId: number;
  dishId?: number;
  setmealId?: number;
  dishFlavor?: string;
  image: string;
  name: string;
  number: number;
  amount: number;
  createTime: string;
}

// 添加/删除购物车请求参数
export interface ShoppingCartDTO {
  dishId?: number;
  setmealId?: number;
  dishFlavor?: string;
}

// 购物车列表响应
export type ShoppingCartListResponse = ShoppingCartApiResponse<ShoppingCartItem[]>;

// 购物车操作响应（添加、删除、清空）
export type ShoppingCartOperationResponse = ShoppingCartApiResponse<string>;
