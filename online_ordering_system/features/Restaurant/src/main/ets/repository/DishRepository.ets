import { Dish, SpiceLevel } from 'common';
import { Result, ok, err } from '../util/Result';

export interface DishesPage {
  items: Array<Dish>;
  hasMore: boolean;
}

export class DishRepository {
  // 可替换为真实接口
  async fetchDishes(page: number = 1, pageSize: number = 10): Promise<Result<DishesPage>> {
    try {
      // 这里暂用本地模拟，后续可替换为真实接口
      const all: Array<Dish> = [
        {
          dishId: '1',
          name: '招牌水煮鱼',
          price: 98,
          originalPrice: 138,
          image: 'common/images/dish1.png',
          description: '鲜嫩鱼肉，麻辣鲜香，配菜丰富',
          category: '热菜',
          isAvailable: true,
          stock: 50,
          tags: ['热销', '麻辣', '招牌'],
          spiceLevel: SpiceLevel.SPICY,
          preparationTime: 20,
          rating: 4.7,
          reviewCount: 356
        },
        {
          dishId: '2',
          name: '夫妻肺片',
          price: 58,
          originalPrice: 78,
          image: 'common/images/dish2.png',
          description: '经典川菜，麻辣爽口，口感丰富',
          category: '凉菜',
          isAvailable: true,
          stock: 30,
          tags: ['经典', '麻辣', '凉菜'],
          spiceLevel: SpiceLevel.MEDIUM,
          preparationTime: 10,
          rating: 4.6,
          reviewCount: 220
        },
        {
          dishId: '3',
          name: '麻婆豆腐',
          price: 38,
          image: 'common/images/dish3.png',
          description: '麻辣鲜香，豆腐嫩滑，下饭神器',
          category: '热菜',
          isAvailable: true,
          stock: 40,
          tags: ['素食', '麻辣', '下饭'],
          spiceLevel: SpiceLevel.MEDIUM,
          preparationTime: 15,
          rating: 4.5,
          reviewCount: 180
        },
        {
          dishId: '4',
          name: '回锅肉',
          price: 48,
          image: 'common/images/dish4.png',
          description: '肥而不腻，香辣可口，经典川菜',
          category: '热菜',
          isAvailable: true,
          stock: 25,
          tags: ['肉类', '香辣', '经典'],
          spiceLevel: SpiceLevel.MEDIUM,
          preparationTime: 18,
          rating: 4.8,
          reviewCount: 412
        },
        {
          dishId: '5',
          name: '宫保鸡丁',
          price: 42,
          image: 'common/images/dish5.png',
          description: '鸡肉嫩滑，花生香脆，酸甜微辣',
          category: '热菜',
          isAvailable: true,
          stock: 35,
          tags: ['鸡肉', '酸甜', '经典'],
          spiceLevel: SpiceLevel.MILD,
          preparationTime: 16,
          rating: 4.4,
          reviewCount: 298
        },
        {
          dishId: '6',
          name: '酸辣土豆丝',
          price: 18,
          image: 'common/images/dish6.png',
          description: '爽脆可口，酸辣开胃，家常美味',
          category: '热菜',
          isAvailable: true,
          stock: 60,
          tags: ['素食', '酸辣', '家常'],
          spiceLevel: SpiceLevel.MILD,
          preparationTime: 8,
          rating: 4.3,
          reviewCount: 156
        },
        {
          dishId: '7',
          name: '蒜蓉西兰花',
          price: 22,
          image: 'common/images/dish7.png',
          description: '清爽健康，蒜香浓郁，营养丰富',
          category: '热菜',
          isAvailable: true,
          stock: 45,
          tags: ['素食', '健康', '清爽'],
          spiceLevel: SpiceLevel.MILD,
          preparationTime: 6,
          rating: 4.2,
          reviewCount: 89
        },
        {
          dishId: '8',
          name: '糖醋里脊',
          price: 52,
          image: 'common/images/dish8.png',
          description: '外酥内嫩，酸甜可口，老少皆宜',
          category: '热菜',
          isAvailable: true,
          stock: 28,
          tags: ['肉类', '酸甜', '经典'],
          spiceLevel: SpiceLevel.MILD,
          preparationTime: 22,
          rating: 4.6,
          reviewCount: 234
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

  // 根据分类获取菜品
  async fetchDishesByCategory(category: string, page: number = 1, pageSize: number = 10): Promise<Result<DishesPage>> {
    try {
      const result = await this.fetchDishes(1, 100); // 获取所有菜品
      if (result.ok) {
        const filteredItems = result.data.items.filter(dish => dish.category === category);
        const start = (page - 1) * pageSize;
        const end = start + pageSize;
        const items = filteredItems.slice(start, end);
        const hasMore = end < filteredItems.length;
        const pageData: DishesPage = { items, hasMore };
        return ok<DishesPage>(pageData);
      }
      return result;
    } catch (e) {
      return err('按分类加载菜品失败');
    }
  }

  // 搜索菜品
  async searchDishes(keyword: string, page: number = 1, pageSize: number = 10): Promise<Result<DishesPage>> {
    try {
      const result = await this.fetchDishes(1, 100); // 获取所有菜品
      if (result.ok) {
        const filteredItems = result.data.items.filter(dish => 
          dish.name.toLowerCase().includes(keyword.toLowerCase()) ||
          dish.description?.toLowerCase().includes(keyword.toLowerCase()) ||
          dish.tags.some(tag => tag.toLowerCase().includes(keyword.toLowerCase()))
        );
        const start = (page - 1) * pageSize;
        const end = start + pageSize;
        const items = filteredItems.slice(start, end);
        const hasMore = end < filteredItems.length;
        const pageData: DishesPage = { items, hasMore };
        return ok<DishesPage>(pageData);
      }
      return result;
    } catch (e) {
      return err('搜索菜品失败');
    }
  }

  // 根据ID获取单个菜品详情
  async fetchDishById(dishId: string): Promise<Result<Dish>> {
    try {
      const result = await this.fetchDishes(1, 100); // 获取所有菜品
      if (result.ok) {
        const dish = result.data.items.find(d => d.dishId === dishId);
        if (dish) {
          return ok<Dish>(dish);
        } else {
          return err('菜品不存在');
        }
      }
      return result as Result<Dish>;
    } catch (e) {
      return err('获取菜品详情失败');
    }
  }
}
