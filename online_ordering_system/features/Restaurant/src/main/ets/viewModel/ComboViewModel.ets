import { Combo, ComboDish, Category } from 'common';
import { ComboRepository } from '../repository/ComboRepository';
import { DishRepository } from '../repository/DishRepository';
import { DataState, idleState, loadingState, successState, errorState } from '../util/DataState';
import { Failure } from '../util/Result';

export class ComboViewModel {
  private repository: ComboRepository = new ComboRepository();
  private repository_2: DishRepository = new DishRepository()

  state: DataState<Array<Combo>> = idleState<Array<Combo>>([]);
  isRefreshing: boolean = false;
  categories: Array<Category> = [];

  // 根据分类ID加载套餐
  async loadCombosByCategoryId(categoryId: number): Promise<void> {
    this.state = loadingState(this.state.data);
    const result = await this.repository.fetchCombosByCategoryId(categoryId);
    if (result.ok) {
      this.state = successState(result.data);
    } else {
      const failure: Failure = result as Failure;
      this.state = errorState([], failure.error);
    }
  }

  // 加载分类列表
  async loadCategories(categoryType: number = 1): Promise<Array<Category>> {
    try {
      const result = await this.repository_2.fetchCategories(categoryType);
      if (result.ok) {
        this.categories = result.data;
        console.log('DishViewModel: 加载分类成功，分类数据:', this.categories);
        return result.data;
      } else {
        console.error('DishViewModel: 加载分类失败');
        return [];
      }
    } catch (error) {
      console.error('DishViewModel: 加载分类失败:', error);
      return [];
    }
  }

  // 根据套餐ID获取套餐菜品列表
  async loadComboDishesByComboId(comboId: string): Promise<Array<ComboDish>> {
    try {
      const result = await this.repository.fetchComboDishesByComboId(comboId);
      if (result.ok) {
        return result.data;
      } else {
        return [];
      }
    } catch (error) {
      console.error('ComboViewModel: 获取套餐菜品失败:', error);
      return [];
    }
  }
}