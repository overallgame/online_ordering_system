export class DishItem {
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
  spiceLevel?: string;
  preparationTime?: number;
  // 展示需要的额外字段
  rating: number = 0;
  reviewCount: number = 0;
}


