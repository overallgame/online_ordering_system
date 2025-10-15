import { Combo } from 'common';
import { Result, ok, err } from '../util/Result';

export interface CombosPage {
  items: Array<Combo>;
  hasMore: boolean;
}

export class ComboRepository {
  // 可替换为真实接口
  async fetchCombos(page: number = 1, pageSize: number = 10): Promise<Result<CombosPage>> {
    try {
      // 这里暂用本地模拟，后续可替换为真实接口
      const all: Array<Combo> = [
        {
          comboId: '1',
          name: '经典双人套餐',
          description: '精选招牌菜+汤品+主食，适合两人享用',
          icon: '🍽️',
          image: 'common/images/combo1.png',
          price: 88,
          originalPrice: 120,
          discount: 32,
          dishes: [],
          isAvailable: true,
          tags: ['热销', '双人'],
          rating: 4.8,
          reviewCount: 156,
          preparationTime: 25,
          category: '双人套餐',
          sortOrder: 1
        },
        {
          comboId: '2',
          name: '家庭四人套餐',
          description: '丰富菜品组合，满足全家口味需求',
          icon: '👨‍👩‍👧‍👦',
          image: 'common/images/combo2.png',
          price: 168,
          originalPrice: 220,
          discount: 52,
          dishes: [],
          isAvailable: true,
          tags: ['家庭', '实惠'],
          rating: 4.6,
          reviewCount: 89,
          preparationTime: 30,
          category: '家庭套餐',
          sortOrder: 2
        },
        {
          comboId: '3',
          name: '商务套餐',
          description: '精致菜品搭配，适合商务宴请',
          icon: '💼',
          image: 'common/images/combo3.png',
          price: 288,
          originalPrice: 350,
          discount: 62,
          dishes: [],
          isAvailable: true,
          tags: ['商务', '精致'],
          rating: 4.9,
          reviewCount: 45,
          preparationTime: 35,
          category: '商务套餐',
          sortOrder: 3
        },
        {
          comboId: '4',
          name: '情侣浪漫套餐',
          description: '浪漫氛围菜品，适合情侣约会',
          icon: '💕',
          image: 'common/images/combo4.png',
          price: 128,
          originalPrice: 160,
          discount: 32,
          dishes: [],
          isAvailable: true,
          tags: ['浪漫', '情侣'],
          rating: 4.7,
          reviewCount: 78,
          preparationTime: 20,
          category: '情侣套餐',
          sortOrder: 4
        },
        {
          comboId: '5',
          name: '儿童套餐',
          description: '营养均衡，适合小朋友',
          icon: '👶',
          image: 'common/images/combo5.png',
          price: 58,
          originalPrice: 78,
          discount: 20,
          dishes: [],
          isAvailable: true,
          tags: ['儿童', '营养'],
          rating: 4.5,
          reviewCount: 32,
          preparationTime: 15,
          category: '儿童套餐',
          sortOrder: 5
        },
        {
          comboId: '6',
          name: '素食套餐',
          description: '全素菜品，健康营养',
          icon: '🥗',
          image: 'common/images/combo6.png',
          price: 98,
          originalPrice: 128,
          discount: 30,
          dishes: [],
          isAvailable: true,
          tags: ['素食', '健康'],
          rating: 4.4,
          reviewCount: 67,
          preparationTime: 18,
          category: '素食套餐',
          sortOrder: 6
        }
      ];
      
      const start = (page - 1) * pageSize;
      const end = start + pageSize;
      const items: Array<Combo> = all.slice(start, end);
      const hasMore: boolean = end < all.length;
      const pageData: CombosPage = { items: items, hasMore: hasMore };
      return ok<CombosPage>(pageData);
    } catch (e) {
      return err('加载套餐失败');
    }
  }

  // 根据分类获取套餐
  async fetchCombosByCategory(category: string, page: number = 1, pageSize: number = 10): Promise<Result<CombosPage>> {
    try {
      const result = await this.fetchCombos(1, 100); // 获取所有套餐
      if (result.ok) {
        const filteredItems = result.data.items.filter(combo => combo.category === category);
        const start = (page - 1) * pageSize;
        const end = start + pageSize;
        const items = filteredItems.slice(start, end);
        const hasMore = end < filteredItems.length;
        const pageData: CombosPage = { items, hasMore };
        return ok<CombosPage>(pageData);
      }
      return result;
    } catch (e) {
      return err('按分类加载套餐失败');
    }
  }

  // 根据ID获取套餐详情
  async fetchComboById(comboId: string): Promise<Result<Combo>> {
    try {
      const result = await this.fetchCombos(1, 100); // 获取所有套餐
      if (result.ok) {
        const combo = result.data.items.find(c => c.comboId === comboId);
        if (combo) {
          return ok<Combo>(combo);
        }
        return err('套餐不存在');
      }
      return err('加载套餐详情失败');
    } catch (e) {
      return err('加载套餐详情失败');
    }
  }
}
