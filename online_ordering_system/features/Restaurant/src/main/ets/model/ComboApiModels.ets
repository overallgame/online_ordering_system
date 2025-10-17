// 套餐API响应数据模型
export interface SetmealApiResponse {
  code: number;
  data: Array<SetmealVO>;
  msg: string;
}

// 套餐菜品API响应数据模型
export interface SetmealDishApiResponse {
  code: number;
  data: Array<DishItemVO>;
  msg: string;
}

// 套餐VO数据模型（对应后端API返回的数据结构）
export class SetmealVO {
  id: number = 0;
  name: string = '';
  description: string = '';
  image: string = '';
  price: number = 0;
  categoryId: number = 0;
  status: number = 1;
  createTime: string = '';
  createUser: number = 0;
  updateTime: string = '';
  updateUser: number = 0;
}

// 套餐菜品VO数据模型
export class DishItemVO {
  name: string = '';
  description: string = '';
  image: string = '';
  copies: number = 1; // 份数
}
