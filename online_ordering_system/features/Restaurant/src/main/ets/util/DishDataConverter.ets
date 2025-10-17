import { DishVO, DishFlavor } from '../model/DishApiModels';
import { Dish, SpiceLevel } from 'common';

export class DishDataConverter {

  static convertDishVOToDish(dishVO: DishVO): Dish {
    const dish = new Dish();

    // 基本属性映射
    dish.dishId = dishVO.id.toString();
    dish.name = dishVO.name;
    dish.price = dishVO.price;
    dish.image = dishVO.image || '';
    dish.description = dishVO.description || '';
    dish.category = dishVO.categoryName || '';

    // 状态映射
    dish.isAvailable = dishVO.status === 1;

    // 设置默认值
    dish.stock = 999; // 默认库存
    dish.tags = DishDataConverter.extractTagsFromFlavors(dishVO.flavors);
    dish.spiceLevel = DishDataConverter.determineSpiceLevel(dishVO.flavors);
    dish.preparationTime = 15; // 默认15分钟
    dish.rating = 4.5; // 默认评分
    dish.reviewCount = 0; // 默认评论数
    
    return dish;
  }

  /**
   * 批量转换菜品列表
   */
  static convertDishVOListToDishList(dishVOList: DishVO[]): Dish[] {
    return dishVOList.map(dishVO => DishDataConverter.convertDishVOToDish(dishVO));
  }

  /**
   * 从口味信息中提取标签
   */
  private static extractTagsFromFlavors(flavors: DishFlavor[]): string[] {
    const tags: string[] = [];
    
    flavors.forEach(flavor => {
      if (flavor.name && flavor.value) {
        tags.push(`${flavor.name}: ${flavor.value}`);
      }
    });
    
    return tags;
  }

  /**
   * 根据口味信息确定辣度等级
   */
  private static determineSpiceLevel(flavors: DishFlavor[]): SpiceLevel {
    const spiceKeywords = ['辣', 'spicy', 'hot'];
    const mildKeywords = ['不辣', 'mild', 'sweet'];
    
    for (const flavor of flavors) {
      const flavorText = `${flavor.name} ${flavor.value}`.toLowerCase();
      
      // 检查是否包含辣味关键词
      if (spiceKeywords.some(keyword => flavorText.includes(keyword))) {
        if (flavorText.includes('微辣') || flavorText.includes('mild')) {
          return SpiceLevel.MILD;
        } else if (flavorText.includes('中辣') || flavorText.includes('medium')) {
          return SpiceLevel.MEDIUM;
        } else if (flavorText.includes('特辣') || flavorText.includes('very')) {
          return SpiceLevel.VERY_SPICY;
        } else {
          return SpiceLevel.SPICY;
        }
      }
      
      // 检查是否包含不辣关键词
      if (mildKeywords.some(keyword => flavorText.includes(keyword))) {
        return SpiceLevel.MILD;
      }
    }
    
    // 默认返回微辣
    return SpiceLevel.MILD;
  }
}
