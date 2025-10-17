import { Combo, ComboDish, Dish } from 'common';
import { SetmealVO, DishItemVO } from '../model/ComboApiModels';

export class ComboDataConverter {
  static convertSetmealVOToCombo(setmealVO: SetmealVO): Combo {
    const combo = new Combo();
    combo.comboId = setmealVO.id.toString();
    combo.name = setmealVO.name;
    combo.description = setmealVO.description;
    combo.image = setmealVO.image;
    combo.price = setmealVO.price;
    combo.isAvailable = setmealVO.status === 1;
    combo.category = ComboDataConverter.getCategoryNameById(setmealVO.categoryId);
    combo.dishes = []; // 套餐菜品列表需要单独获取
    combo.tags = ComboDataConverter.generateTags(setmealVO);
    combo.rating = 4.5; // 默认评分
    combo.reviewCount = 0; // 默认评论数
    combo.preparationTime = 25; // 默认制作时间
    combo.sortOrder = setmealVO.id;

    return combo;
  }

  // 将SetmealVO数组转换为Combo数组
  static convertSetmealVOListToComboList(setmealVOList: Array<SetmealVO>): Array<Combo> {
    return setmealVOList.map(setmealVO => ComboDataConverter.convertSetmealVOToCombo(setmealVO));
  }

  // 根据分类ID获取分类名称
  private static getCategoryNameById(categoryId: number): string {
    const categoryMap: Map<number, string> = new Map([
      [201, '经典套餐'],
      [202, '特色套餐'],
      [203, '营养套餐'],
      [204, '优惠套餐']
    ]);
    return categoryMap.get(categoryId) || '其他套餐';
  }

  // 根据套餐信息生成标签
  private static generateTags(setmealVO: SetmealVO): Array<string> {
    const tags: Array<string> = [];

    // 根据价格生成标签
    if (setmealVO.price < 50) {
      tags.push('实惠');
    } else if (setmealVO.price < 100) {
      tags.push('性价比');
    } else {
      tags.push('精品');
    }

    // 根据分类生成标签
    const categoryName = ComboDataConverter.getCategoryNameById(setmealVO.categoryId);
    if (categoryName.includes('经典')) {
      tags.push('经典');
    } else if (categoryName.includes('特色')) {
      tags.push('特色');
    } else if (categoryName.includes('营养')) {
      tags.push('营养');
    } else if (categoryName.includes('优惠')) {
      tags.push('优惠');
    }

    // 根据描述生成标签
    if (setmealVO.description.includes('双人') || setmealVO.description.includes('两人')) {
      tags.push('双人');
    } else if (setmealVO.description.includes('家庭') || setmealVO.description.includes('四人')) {
      tags.push('家庭');
    } else if (setmealVO.description.includes('商务')) {
      tags.push('商务');
    } else if (setmealVO.description.includes('情侣') || setmealVO.description.includes('浪漫')) {
      tags.push('浪漫');
    } else if (setmealVO.description.includes('儿童') || setmealVO.description.includes('小朋友')) {
      tags.push('儿童');
    } else if (setmealVO.description.includes('素食') || setmealVO.description.includes('全素')) {
      tags.push('素食');
    }

    return tags.length > 0 ? tags : ['推荐'];
  }

  // 将DishItemVO转换为ComboDish
  static convertDishItemVOToComboDish(dishItemVO: DishItemVO): ComboDish {
    const comboDish = new ComboDish();

    // 创建Dish对象
    const dish = new Dish();
    dish.dishId = ComboDataConverter.generateDishId(dishItemVO.name); // 生成唯一ID
    dish.name = dishItemVO.name;
    dish.description = dishItemVO.description;
    dish.image = dishItemVO.image;
    dish.price = 0; // 套餐菜品不单独定价
    dish.isAvailable = true;
    dish.stock = 999; // 套餐菜品默认有库存
    dish.tags = ['套餐菜品'];
    dish.category = '套餐菜品';
    dish.preparationTime = 15; // 默认制作时间
    dish.rating = 4.0; // 默认评分
    dish.reviewCount = 0;

    comboDish.dish = dish;
    comboDish.quantity = dishItemVO.copies;
    comboDish.isRequired = true; // 套餐菜品默认必选
    comboDish.canCustomize = false; // 套餐菜品默认不可定制

    return comboDish;
  }

  // 将DishItemVO数组转换为ComboDish数组
  static convertDishItemVOListToComboDishList(dishItemVOList: Array<DishItemVO>): Array<ComboDish> {
    return dishItemVOList.map(dishItemVO => ComboDataConverter.convertDishItemVOToComboDish(dishItemVO));
  }

  // 生成菜品ID（基于菜品名称）
  private static generateDishId(dishName: string): string {
    // 简单的ID生成策略，实际项目中可能需要更复杂的逻辑
    const timestamp = Date.now();
    const hash = ComboDataConverter.simpleHash(dishName);
    return `combo_dish_${hash}_${timestamp}`;
  }

  // 简单哈希函数
  private static simpleHash(str: string): number {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // 转换为32位整数
    }
    return Math.abs(hash);
  }
}