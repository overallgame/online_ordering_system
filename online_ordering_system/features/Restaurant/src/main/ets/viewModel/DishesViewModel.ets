import { Dish } from 'common';
import { DishesRepository } from './DishesRepository';
import { DataState, idleState, loadingState, successState, errorState } from '../util/DataState';
import { Failure } from '../util/Result';

export class DishesViewModel {
  private repository: DishesRepository = new DishesRepository();

  // 列表数据状态
  state: DataState<Array<Dish>> = idleState<Array<Dish>>([]);
  isRefreshing: boolean = false;
  isLoadingMore: boolean = false;
  hasMore: boolean = false;
  page: number = 1;
  readonly pageSize: number = 10;

  async loadInitial(): Promise<void> {
    this.page = 1;
    this.state = loadingState(this.state.data);
    const result = await this.repository.fetchDishes(this.page, this.pageSize);
    if (result.ok) {
      this.state = successState(result.data.items);
      this.hasMore = result.data.hasMore;
    } else {
      const failure: Failure = result as Failure;
      this.state = errorState([], failure.error);
      this.hasMore = false;
    }
  }

  async refresh(): Promise<void> {
    this.isRefreshing = true;
    await this.loadInitial();
    this.isRefreshing = false;
  }

  async loadMore(): Promise<void> {
    if (this.isLoadingMore || !this.hasMore) return;
    this.isLoadingMore = true;
    const nextPage = this.page + 1;
    const result = await this.repository.fetchDishes(nextPage, this.pageSize);
    if (result.ok) {
      this.page = nextPage;
      this.state = successState(this.state.data.concat(result.data.items));
      this.hasMore = result.data.hasMore;
    } else {
      const failure: Failure = result as Failure;
      // 可在 UI 侧根据 isLoadingMore + failure.error 显示 Toast
      // 这里不改变 state，避免覆盖已有数据
    }
    this.isLoadingMore = false;
  }
}


