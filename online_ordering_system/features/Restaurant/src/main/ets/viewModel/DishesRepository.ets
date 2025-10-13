import { Dish, SpiceLevel } from 'common';
import { Result, ok, err } from '../util/Result';

export interface DishesPage {
  items: Array<Dish>;
  hasMore: boolean;
}

export class DishesRepository {
  // 可替换为真实接口
  async fetchDishes(page: number = 1, pageSize: number = 10): Promise<Result<DishesPage>> {
    try {
      // 这里暂用本地模拟，后续可替换为真实接口
      const all: Array<Dish> = [
        {
          dishId: '1', name: '招牌水煮鱼', price: 98, originalPrice: 138,
          image: 'common/images/dish1.png', description: '鲜嫩鱼肉，麻辣鲜香',
          category: '推荐', isAvailable: true, stock: 50, tags: ['热销', '麻辣'],
          spiceLevel: SpiceLevel.SPICY, preparationTime: 20, rating: 4.7, reviewCount: 356
        },
        {
          dishId: '2', name: '夫妻肺片', price: 58, originalPrice: 78,
          image: 'common/images/dish2.png', description: '经典川菜，麻辣爽口',
          category: '推荐', isAvailable: true, stock: 30, tags: ['经典', '麻辣'],
          spiceLevel: SpiceLevel.MEDIUM, preparationTime: 10, rating: 4.6, reviewCount: 220
        },
        {
          dishId: '3', name: '麻婆豆腐', price: 38,
          image: 'common/images/dish3.png', description: '麻辣鲜香，豆腐嫩滑',
          category: '热菜', isAvailable: true, stock: 40, tags: ['素食', '麻辣'],
          spiceLevel: SpiceLevel.MEDIUM, preparationTime: 15, rating: 4.5, reviewCount: 180
        },
        {
          dishId: '4', name: '回锅肉', price: 48,
          image: 'common/images/dish4.png', description: '肥而不腻，香辣可口',
          category: '热菜', isAvailable: true, stock: 25, tags: ['肉类', '香辣'],
          spiceLevel: SpiceLevel.MEDIUM, preparationTime: 18, rating: 4.8, reviewCount: 412
        }
      ];
      const start = (page - 1) * pageSize;
      const end = start + pageSize;
      const items: Array<Dish> = all.slice(start, end);
      const hasMore: boolean = end < all.length;
      const pageData: DishesPage = { items: items, hasMore: hasMore };
      return ok<DishesPage>(pageData);
    } catch (e) {
      return err('加载菜品失败');
    }
  }
}


