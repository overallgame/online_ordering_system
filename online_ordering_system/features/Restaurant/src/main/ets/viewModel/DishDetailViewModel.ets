import { Dish } from 'common';
import { DishRepository } from '../repository/DishRepository';
import { ReviewRepository, DishReview } from '../repository/ReviewRepository';
import { DataState, idleState, loadingState, successState, errorState } from '../util/DataState';
import { Failure } from '../util/Result';

export class DishDetailViewModel {
  private dishRepository: DishRepository = new DishRepository();
  private reviewRepository: ReviewRepository = new ReviewRepository();

  // 菜品信息
  dish?: Dish;
  
  // 评论列表数据状态
  reviewsState: DataState<Array<DishReview>> = idleState<Array<DishReview>>([]);
  isLoadingReviews: boolean = false;
  isLoadingMoreReviews: boolean = false;
  hasMoreReviews: boolean = false;
  reviewPage: number = 1;
  readonly reviewPageSize: number = 10;

  setDish(dish: Dish): void {
    this.dish = dish;
  }

  async loadReviews(dishId: string): Promise<void> {
    this.reviewPage = 1;
    this.reviewsState = loadingState(this.reviewsState.data);
    const result = await this.reviewRepository.fetchDishReviews(dishId, this.reviewPage, this.reviewPageSize);
    if (result.ok) {
      this.reviewsState = successState(result.data.items);
      this.hasMoreReviews = result.data.hasMore;
    } else {
      const failure: Failure = result as Failure;
      this.reviewsState = errorState([], failure.error);
      this.hasMoreReviews = false;
    }
  }

  async loadMoreReviews(dishId: string): Promise<void> {
    if (this.isLoadingMoreReviews || !this.hasMoreReviews) return;
    this.isLoadingMoreReviews = true;
    const nextPage = this.reviewPage + 1;
    const result = await this.reviewRepository.fetchDishReviews(dishId, nextPage, this.reviewPageSize);
    if (result.ok) {
      this.reviewPage = nextPage;
      this.reviewsState = successState(this.reviewsState.data.concat(result.data.items));
      this.hasMoreReviews = result.data.hasMore;
    } else {
      const failure: Failure = result as Failure;
      // 可在 UI 侧根据 isLoadingMoreReviews + failure.error 显示 Toast
    }
    this.isLoadingMoreReviews = false;
  }

  async refreshReviews(dishId: string): Promise<void> {
    this.isLoadingReviews = true;
    await this.loadReviews(dishId);
    this.isLoadingReviews = false;
  }

  async loadDishDetails(dishId: string): Promise<void> {
    const result = await this.dishRepository.fetchDishById(dishId);
    if (result.ok) {
      this.dish = result.data;
    }
  }
}
