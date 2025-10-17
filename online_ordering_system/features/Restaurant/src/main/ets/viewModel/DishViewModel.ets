import { Dish, Category } from 'common';
import { DishRepository } from '../repository/DishRepository';
import { DataState, idleState, loadingState, successState, errorState } from '../util/DataState';
import { Failure } from '../util/Result';

export class DishViewModel {
  private repository: DishRepository = new DishRepository();

  state: DataState<Array<Dish>> = idleState<Array<Dish>>([]);
  isRefreshing: boolean = false;
  categories: Array<Category> = [];

  // 根据分类ID加载菜品
  async loadDishesByCategoryId(categoryId: number): Promise<void> {
    this.state = loadingState(this.state.data);
    const result = await this.repository.fetchDishesByCategoryId(categoryId);
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
      const result = await this.repository.fetchCategories(categoryType);
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
}
