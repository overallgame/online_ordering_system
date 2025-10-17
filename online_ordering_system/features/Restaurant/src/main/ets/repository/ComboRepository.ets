import { Combo, ComboDish, Dish } from 'common';
import { Result, ok, err } from '../util/Result';
import { ApiClient, ApiEndpoints } from 'common';
import { SetmealApiResponse, SetmealDishApiResponse } from '../model/ComboApiModels';
import { ComboDataConverter } from '../util/ComboDataConverter';

export interface CombosPage {
  items: Array<Combo>;
  hasMore: boolean;
}

export class ComboRepository {
  private apiClient: ApiClient = ApiClient.getInstance();

  // 根据分类ID获取套餐列表
  async fetchCombosByCategoryId(categoryId: number): Promise<Result<Array<Combo>>> {
    try {
      const response = await this.apiClient.get<SetmealApiResponse>(`${ApiEndpoints.SETMEAL_LIST}?categoryId=${categoryId}`);

      if (response.success && response.data && response.data.data) {
        const combos: Array<Combo> = ComboDataConverter.convertSetmealVOListToComboList(response.data.data);
        return ok<Array<Combo>>(combos);
      } else {
        console.warn('套餐API调用失败，使用模拟数据:', response.error);
        return ok<Array<Combo>>(this.getMockCombosByCategory(categoryId));
      }
    } catch (e) {
      console.error('获取套餐列表失败:', e);
      return ok<Array<Combo>>(this.getMockCombosByCategory(categoryId));
    }
  }

  // 根据套餐ID获取套餐菜品列表
  async fetchComboDishesByComboId(comboId: string): Promise<Result<Array<ComboDish>>> {
    try {
      const response = await this.apiClient.get<SetmealDishApiResponse>(`${ApiEndpoints.SETMEAL_DISH_LIST}/${comboId}`);

      if (response.success && response.data && response.data.data) {
        const comboDishes: Array<ComboDish> = ComboDataConverter.convertDishItemVOListToComboDishList(response.data.data);
        return ok<Array<ComboDish>>(comboDishes);
      } else {
        console.warn('套餐菜品API调用失败，使用模拟数据:', response.error);
        return ok<Array<ComboDish>>(this.getMockComboDishes(comboId));
      }
    } catch (e) {
      console.error('获取套餐菜品列表失败:', e);
      return ok<Array<ComboDish>>(this.getMockComboDishes(comboId));
    }
  }

  // 根据分类ID获取模拟套餐数据（降级方案）
  private getMockCombosByCategory(categoryId: number): Array<Combo> {
    const mockCombos: Array<Combo> = [
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
        category: '经典套餐',
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
        category: '特色套餐',
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
        category: '营养套餐',
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
        category: '优惠套餐',
        sortOrder: 4
      }
    ];

    // 根据分类ID返回不同的套餐
    switch (categoryId) {
      case 201: // 经典套餐
        return mockCombos.filter(combo => combo.category === '经典套餐');
      case 202: // 特色套餐
        return mockCombos.filter(combo => combo.category === '特色套餐');
      case 203: // 营养套餐
        return mockCombos.filter(combo => combo.category === '营养套餐');
      case 204: // 优惠套餐
        return mockCombos.filter(combo => combo.category === '优惠套餐');
      default:
        return mockCombos;
    }
  }

  // 获取模拟套餐菜品数据（降级方案）
  private getMockComboDishes(comboId: string): Array<ComboDish> {
    // 根据套餐ID返回不同的模拟菜品
    const mockDishes: Array<ComboDish> = [];
    
    switch (comboId) {
      case '1': // 经典双人套餐
        mockDishes.push(this.createMockComboDish('宫保鸡丁', '经典川菜，鸡肉嫩滑，花生香脆', 'common/images/dish1.png', 1));
        mockDishes.push(this.createMockComboDish('麻婆豆腐', '四川传统名菜，豆腐嫩滑，麻辣鲜香', 'common/images/dish2.png', 1));
        mockDishes.push(this.createMockComboDish('西红柿鸡蛋汤', '营养丰富，味道鲜美', 'common/images/dish3.png', 1));
        break;
      case '2': // 家庭四人套餐
        mockDishes.push(this.createMockComboDish('回锅肉', '肥而不腻，香辣可口，经典川菜', 'common/images/dish4.png', 1));
        mockDishes.push(this.createMockComboDish('糖醋里脊', '外酥内嫩，酸甜可口，老少皆宜', 'common/images/dish5.png', 1));
        mockDishes.push(this.createMockComboDish('酸辣土豆丝', '爽脆可口，酸辣开胃，家常美味', 'common/images/dish6.png', 1));
        mockDishes.push(this.createMockComboDish('蛋炒饭', '粒粒分明，香味浓郁', 'common/images/dish7.png', 1));
        break;
      case '3': // 商务套餐
        mockDishes.push(this.createMockComboDish('招牌水煮鱼', '鲜嫩鱼肉，麻辣鲜香，配菜丰富', 'common/images/dish8.png', 1));
        mockDishes.push(this.createMockComboDish('夫妻肺片', '经典川菜，麻辣爽口，口感丰富', 'common/images/dish9.png', 1));
        mockDishes.push(this.createMockComboDish('蒜蓉西兰花', '清爽健康，蒜香浓郁，营养丰富', 'common/images/dish10.png', 1));
        break;
      case '4': // 情侣浪漫套餐
        mockDishes.push(this.createMockComboDish('糖醋里脊', '外酥内嫩，酸甜可口，老少皆宜', 'common/images/dish11.png', 1));
        mockDishes.push(this.createMockComboDish('蒜蓉西兰花', '清爽健康，蒜香浓郁，营养丰富', 'common/images/dish12.png', 1));
        mockDishes.push(this.createMockComboDish('西红柿鸡蛋汤', '营养丰富，味道鲜美', 'common/images/dish13.png', 1));
        break;
      default:
        // 默认套餐菜品
        mockDishes.push(this.createMockComboDish('宫保鸡丁', '经典川菜，鸡肉嫩滑，花生香脆', 'common/images/dish1.png', 1));
        mockDishes.push(this.createMockComboDish('麻婆豆腐', '四川传统名菜，豆腐嫩滑，麻辣鲜香', 'common/images/dish2.png', 1));
    }
    
    return mockDishes;
  }

  // 创建模拟套餐菜品
  private createMockComboDish(name: string, description: string, image: string, copies: number): ComboDish {
    const comboDish = new ComboDish();
    const dish = new Dish();
    
    dish.dishId = `mock_dish_${name}_${Date.now()}`;
    dish.name = name;
    dish.description = description;
    dish.image = image;
    dish.price = 0; // 套餐菜品不单独定价
    dish.isAvailable = true;
    dish.stock = 999;
    dish.tags = ['套餐菜品'];
    dish.category = '套餐菜品';
    dish.preparationTime = 15;
    dish.rating = 4.0;
    dish.reviewCount = 0;
    
    comboDish.dish = dish;
    comboDish.quantity = copies;
    comboDish.isRequired = true;
    comboDish.canCustomize = false;
    
    return comboDish;
  }
}