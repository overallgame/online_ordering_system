import { Combo } from 'common';
import { ComboRepository } from '../repository/ComboRepository';
import { DataState, idleState, loadingState, successState, errorState } from '../util/DataState';
import { Failure } from '../util/Result';

export class ComboViewModel {
  private repository: ComboRepository = new ComboRepository();

  // 列表数据状态
  state: DataState<Array<Combo>> = idleState<Array<Combo>>([]);
  isRefreshing: boolean = false;
  isLoadingMore: boolean = false;
  hasMore: boolean = false;
  page: number = 1;
  readonly pageSize: number = 6;
  currentCategory: string = '';

  async loadInitial(): Promise<void> {
    this.page = 1;
    this.state = loadingState(this.state.data);
    const result = await this.repository.fetchCombos(this.page, this.pageSize);
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
    const result = await this.repository.fetchCombos(nextPage, this.pageSize);
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

  async loadByCategory(category: string): Promise<void> {
    this.currentCategory = category;
    this.page = 1;
    this.state = loadingState(this.state.data);
    const result = await this.repository.fetchCombosByCategory(category, this.page, this.pageSize);
    if (result.ok) {
      this.state = successState(result.data.items);
      this.hasMore = result.data.hasMore;
    } else {
      const failure: Failure = result as Failure;
      this.state = errorState([], failure.error);
      this.hasMore = false;
    }
  }

  // 搜索套餐
  async searchCombos(keyword: string): Promise<void> {
    this.page = 1;
    this.state = loadingState(this.state.data);
    
    // 模拟搜索逻辑
    try {
      const result = await this.repository.fetchCombos(1, 100); // 获取所有套餐
      if (result.ok) {
        const filteredItems = result.data.items.filter(combo => 
          combo.name.toLowerCase().includes(keyword.toLowerCase()) ||
          combo.description.toLowerCase().includes(keyword.toLowerCase()) ||
          combo.tags.some(tag => tag.toLowerCase().includes(keyword.toLowerCase()))
        );
        this.state = successState(filteredItems);
        this.hasMore = false; // 搜索结果不分页
      } else {
        const failure: Failure = result as Failure;
        this.state = errorState([], failure.error);
      }
    } catch (e) {
      this.state = errorState([], '搜索失败');
    }
  }
}
