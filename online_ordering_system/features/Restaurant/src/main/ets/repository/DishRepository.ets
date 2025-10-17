import { Dish, SpiceLevel, Category } from 'common';
import { Result, ok, err } from '../util/Result';
import { ApiClient, ApiEndpoints } from 'common';
import { DishListResponse } from '../model/DishApiModels';
import { DishDataConverter } from '../util/DishDataConverter';


export class DishRepository {
  private apiClient: ApiClient = ApiClient.getInstance();

  // 根据分类ID获取菜品列表
  async fetchDishesByCategoryId(categoryId: number): Promise<Result<Array<Dish>>> {
    try {
      const response = await this.apiClient.get<DishListResponse>(`${ApiEndpoints.DISH_LIST_BY_CATEGORY}?categoryId=${categoryId}`);

      if (response.success && response.data && response.data.data) {
        const dishes: Array<Dish> = DishDataConverter.convertDishVOListToDishList(response.data.data);
        return ok<Array<Dish>>(dishes);
      } else {
        console.warn('菜品API调用失败，使用模拟数据:', response.error);
        return ok<Array<Dish>>(this.getMockDishesByCategory(categoryId));
      }
    } catch (e) {
      console.error('获取菜品列表失败:', e);
      return ok<Array<Dish>>(this.getMockDishesByCategory(categoryId));
    }
  }

  // 根据分类ID获取模拟菜品数据（降级方案）
  private getMockDishesByCategory(categoryId: number): Array<Dish> {
    const mockDishes: Array<Dish> = [
      {
        dishId: '1',
        name: '宫保鸡丁',
        price: 28.0,
        originalPrice: 32.0,
        image: 'common/images/dish1.png',
        description: '经典川菜，鸡肉嫩滑，花生香脆',
        category: '热菜',
        isAvailable: true,
        stock: 50,
        tags: ['川菜', '辣味', '经典'],
        spiceLevel: SpiceLevel.MEDIUM,
        preparationTime: 15,
        rating: 4.5,
        reviewCount: 128
      },
      {
        dishId: '2',
        name: '麻婆豆腐',
        price: 18.0,
        image: 'common/images/dish2.png',
        description: '四川传统名菜，豆腐嫩滑，麻辣鲜香',
        category: '热菜',
        isAvailable: true,
        stock: 30,
        tags: ['川菜', '麻辣', '素食'],
        spiceLevel: SpiceLevel.SPICY,
        preparationTime: 12,
        rating: 4.3,
        reviewCount: 95
      },
      {
        dishId: '3',
        name: '糖醋里脊',
        price: 32.0,
        image: 'common/images/dish3.png',
        description: '酸甜可口，外酥内嫩',
        category: '热菜',
        isAvailable: true,
        stock: 25,
        tags: ['酸甜', '经典', '下饭'],
        spiceLevel: SpiceLevel.MILD,
        preparationTime: 18,
        rating: 4.6,
        reviewCount: 156
      }
    ];

    // 根据分类ID返回不同的菜品
    switch (categoryId) {
      case 101: // 热菜
        return mockDishes.filter(dish => dish.category === '热菜');
      case 102: // 凉菜
        return [
          {
            dishId: '4',
            name: '凉拌黄瓜',
            price: 12.0,
            image: 'common/images/dish4.png',
            description: '清爽开胃，夏日必备',
            category: '凉菜',
            isAvailable: true,
            stock: 40,
            tags: ['清爽', '开胃', '素食'],
            spiceLevel: SpiceLevel.MILD,
            preparationTime: 5,
            rating: 4.2,
            reviewCount: 78
          }
        ];
      case 103: // 汤品
        return [
          {
            dishId: '5',
            name: '西红柿鸡蛋汤',
            price: 15.0,
            image: 'common/images/dish5.png',
            description: '营养丰富，味道鲜美',
            category: '汤品',
            isAvailable: true,
            stock: 35,
            tags: ['营养', '清淡', '家常'],
            spiceLevel: SpiceLevel.MILD,
            preparationTime: 10,
            rating: 4.4,
            reviewCount: 89
          }
        ];
      case 104: // 主食
        return [
          {
            dishId: '6',
            name: '蛋炒饭',
            price: 16.0,
            image: 'common/images/dish6.png',
            description: '粒粒分明，香味浓郁',
            category: '主食',
            isAvailable: true,
            stock: 60,
            tags: ['经典', '饱腹', '家常'],
            spiceLevel: SpiceLevel.MILD,
            preparationTime: 8,
            rating: 4.1,
            reviewCount: 112
          }
        ];
      default:
        return mockDishes;
    }
  }

  // 获取所有分类列表
  async fetchCategories(categoryType: number = 1): Promise<Result<Array<Category>>> {
    try {
      interface CategoryApiResponse {
        code: number;
        data: Array<Category>;
        msg: string;
      }

      const response =
        await this.apiClient.get<CategoryApiResponse>(`${ApiEndpoints.CATEGORY_LIST}?type=${categoryType}`);

      if (response.success && response.data && response.data.data) {
        const categoryData: Array<Category> = response.data.data;
        return ok<Array<Category>>(categoryData);
      } else {
        console.warn('分类API调用失败，使用默认分类:', response.error);
        const defaultCategories: Array<string> = categoryType === 1 ?
          ['热菜', '凉菜', '汤品', '主食'] :
          ['经典套餐', '特色套餐', '营养套餐', '优惠套餐'];
        
        // 创建默认分类数据
        const defaultCategoryData: Array<Category> = defaultCategories.map((name: string, index: number) => {
          const category = new Category();
          category.id = categoryType === 1 ? (101 + index) : (201 + index);
          category.name = name;
          category.type = categoryType;
          category.sort = index;
          category.status = 1;
          return category;
        });
        
        return ok<Array<Category>>(defaultCategoryData);
      }
    } catch (e) {
      console.error('获取分类列表失败:', e);
      const defaultCategories: Array<string> = categoryType === 1 ?
        ['热菜', '凉菜', '汤品', '主食'] :
        ['经典套餐', '特色套餐', '营养套餐', '优惠套餐'];
      
      // 创建默认分类数据
      const defaultCategoryData: Array<Category> = defaultCategories.map((name: string, index: number) => {
        const category = new Category();
        category.id = categoryType === 1 ? (101 + index) : (201 + index);
        category.name = name;
        category.type = categoryType;
        category.sort = index;
        category.status = 1;
        return category;
      });
      
      return ok<Array<Category>>(defaultCategoryData);
    }
  }
}
