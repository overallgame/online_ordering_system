// API响应的菜品数据模型
export class DishVO {
  id: number = 0;
  name: string = '';
  price: number = 0;
  image: string = '';
  description?: string = '';
  categoryId: number = 0;
  categoryName: string = '';
  status: number = 1;
  updateTime: string = '';
  flavors: Array<DishFlavor> = [];
}

// 菜品口味模型
export class DishFlavor {
  id: number = 0;
  dishId: number = 0;
  name: string = '';
  value: string = '';
}

// API响应包装类
export class DishListResponse {
  code: number = 0;
  data: Array<DishVO> = [];
  msg: string = '';
}
