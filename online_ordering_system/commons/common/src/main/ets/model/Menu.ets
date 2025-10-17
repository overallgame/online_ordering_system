export class Menu {
  menuId: string = '';
  restaurantId: string = '';
  name: string = '';
  description?: string;
  categories: Array<MenuCategory> = [];
  isActive: boolean = true;
  updateTime: number = 0;
}

// API响应的分类模型
export class Category {
  id: number = 0;
  name: string = '';
  type: number = 1; // 1 菜品分类 2 套餐分类
  sort: number = 0;
  status: number = 1;
  createTime: string = '';
  createUser: number = 0;
  updateTime: string = '';
  updateUser: number = 0;
}

export class MenuCategory {
  categoryId: string = '';
  name: string = '';
  description?: string;
  sortOrder: number = 0;
  dishes: Array<Dish> = [];
}

export class Dish {
  dishId: string = '';
  name: string = '';
  price: number = 0;
  originalPrice?: number;
  image: string = '';
  description?: string;
  category: string = '';
  isAvailable: boolean = true;
  stock: number = 0;
  tags: Array<string> = [];
  customizationOptions?: Array<CustomizationOption>;
  spiceLevel: SpiceLevel = SpiceLevel.MILD;
  preparationTime: number = 15; // 分钟
  rating: number = 0;
  reviewCount: number = 0;
}

export class CustomizationOption {
  optionId: string = '';
  name: string = '';
  type: 'radio' | 'checkbox' | 'number' = 'radio';
  required: boolean = false;
  choices: Array<CustomizationChoice> = [];
}

export class CustomizationChoice {
  choiceId: string = '';
  name: string = '';
  price: number = 0;
  isDefault: boolean = false;
}

export enum SpiceLevel {
  MILD = 'mild',
  MEDIUM = 'medium',
  SPICY = 'spicy',
  VERY_SPICY = 'very_spicy'
}