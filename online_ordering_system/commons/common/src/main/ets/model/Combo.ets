import { Dish } from "./Menu";

export class Combo {
  comboId: string = '';
  name: string = '';
  description: string = '';
  icon: string = '';
  image: string = '';
  price: number = 0;
  originalPrice?: number;
  discount?: number;
  dishes: Array<ComboDish> = [];
  isAvailable: boolean = true;
  tags: Array<string> = [];
  rating: number = 0;
  reviewCount: number = 0;
  preparationTime: number = 20; // 分钟
  category: string = '';
  sortOrder: number = 0;
}

export class ComboDish {
  dish: Dish = new Dish();
  quantity: number = 1;
  isRequired: boolean = true; // 是否必选
  canCustomize: boolean = false; // 是否可定制
}

export class ComboCategory {
  categoryId: string = '';
  name: string = '';
  description?: string;
  sortOrder: number = 0;
  combos: Array<Combo> = [];
}
