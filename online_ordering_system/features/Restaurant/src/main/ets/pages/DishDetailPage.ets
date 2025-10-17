import { Dish } from 'common';
import { DishDetailViewModel } from '../viewModel/DishDetailViewModel';
import { Review } from 'common';
import { LoadStatus } from '../util/DataState';
import { PageName } from '../util/NavigationTypes';

@Component
export struct DishDetailPage {
  @Consume('restaurantPathStack') restaurantPathStack: NavPathStack;
  private viewModel: DishDetailViewModel = new DishDetailViewModel();
  @State dish?: Dish = undefined;
  @State reviews: Review[] = [];
  @State reviewStatus: LoadStatus = LoadStatus.Idle;
  @State reviewError?: string = undefined;
  @State isLoadingMoreReviews: boolean = false;
  @State hasMoreReviews: boolean = false;
  // 收藏状态
  @State isFavorited: boolean = false;

  aboutToAppear() {
    // 从路径栈获取参数
    this.dish = this.restaurantPathStack.getParamByName(PageName.DISH_DETAIL)[0] as Dish;
    if (this.dish) {
      this.checkFavoriteStatus();
      this.loadReviews(this.dish.dishId);
    }
  }

  private async loadReviews(dishId: string) {
    this.reviewStatus = LoadStatus.Loading;
    this.reviewError = undefined;
    await this.viewModel.loadReviews(dishId);
    this.reviews = this.viewModel.reviewsState.data;
    this.reviewStatus = this.viewModel.reviewsState.status;
    this.reviewError = this.viewModel.reviewsState.error;
    this.hasMoreReviews = this.viewModel.hasMoreReviews;
  }

  private async onLoadMoreReviews() {
    if (!this.dish || this.isLoadingMoreReviews || !this.hasMoreReviews) {
      return;
    }
    this.isLoadingMoreReviews = true;
    await this.viewModel.loadMoreReviews(this.dish.dishId);
    this.reviews = this.viewModel.reviewsState.data;
    this.hasMoreReviews = this.viewModel.hasMoreReviews;
    this.isLoadingMoreReviews = false;
  }

  // 检查收藏状态
  private checkFavoriteStatus(): void {
    // TODO: 从本地存储或后端检查收藏状态
    // 这里先模拟一个状态
    this.isFavorited = false;
  }

  // 切换收藏状态
  private toggleFavorite(): void {
    this.isFavorited = !this.isFavorited;
    // TODO: 保存收藏状态到本地存储或同步到后端
    console.log(`Dish ${this.dish?.name} ${this.isFavorited ? '收藏' : '取消收藏'}`);
  }

  build() {
    NavDestination() {
      Scroll() {
      Column() {
        // 第一部分：菜品图片
        this.buildDishImage()

        // 第二部分：菜品名称和购物车按钮
        this.buildDishInfo()

        // 第三部分：菜品描述
        this.buildDescription()

        // 第四部分：评论列表
        this.buildReviewList()
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .scrollBar(BarState.Auto)
    }
    .hideTitleBar(true)
  }

  // 第一部分：菜品图片
  @Builder
  buildDishImage() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.dish) {
        Image(this.dish.image)
          .width('100%')
          .height(300)
          .objectFit(ImageFit.Cover)
      }

      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
      }
      .width(40)
      .height(40)
      .backgroundColor('rgba(0, 0, 0, 0.3)')
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .margin({ top: 16, left: 16 })
      .onClick(() => {
        this.restaurantPathStack.pop();
      })
    }
    .width('100%')
    .height(300)
  }

  // 第二部分：菜品名称和收藏按钮
  @Builder
  buildDishInfo() {
    if (this.dish) {
      Column() {
        Row() {
          Column() {
            Text(this.dish.name)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 8 })

            Row() {
              Text('★')
                .fontSize(14)
                .fontColor('#FFC107')
              Text(`${this.dish.rating}`)
                .fontSize(14)
                .fontColor('#666666')
                .margin({ left: 4, right: 12 })

              ForEach(this.dish.tags, (tag: string) => {
                Text(tag)
                  .fontSize(10)
                  .fontColor('#FF6B6B')
                  .backgroundColor('#FFF0F0')
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .borderRadius(8)
                  .margin({ right: 4 })
              })
            }
            .margin({ bottom: 12 })

            Row() {
              Text(`￥${this.dish.price}`)
                .fontSize(24)
                .fontColor('#FF6B6B')
                .fontWeight(FontWeight.Bold)

              if (this.dish.originalPrice && this.dish.originalPrice > this.dish.price) {
                Text(`￥${this.dish.originalPrice}`)
                  .fontSize(14)
                  .fontColor('#999999')
                  .decoration({ type: TextDecorationType.LineThrough })
                  .margin({ left: 8 })
              }
            }
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          // 收藏按钮
          Row() {
            Text(this.isFavorited ? '❤️' : '🤍')
              .fontSize(20)
          }
          .width(40)
          .height(40)
          .backgroundColor(this.isFavorited ? '#FFF0F0' : '#F8F8F8')
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            this.toggleFavorite();
          })
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .margin({ bottom: 12 })
    }
  }

  // 第三部分：菜品描述
  @Builder
  buildDescription() {
    if (this.dish && this.dish.description) {
      Column() {
        Text('菜品介绍')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 12 })

        Text(this.dish.description)
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(22)

        Divider()
          .margin({ top: 16 })
          .color('#F0F0F0')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 12 })
    }
  }

  // 第四部分：评论列表
  @Builder
  buildReviewList() {
    Column() {
      Row() {
        Text('用户评价')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        if (this.dish) {
          Text(`${this.dish.reviewCount}条评价`)
            .fontSize(12)
            .fontColor('#999999')
        }
      }
      .width('100%')
      .margin({ bottom: 16 })

      if (this.reviewStatus === LoadStatus.Loading) {
        Row() {
          LoadingProgress()
            .width(24)
            .height(24)
          Text(' 正在加载评论...')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .height(100)
        .justifyContent(FlexAlign.Center)
      } else if (this.reviewStatus === LoadStatus.Error && this.reviewError) {
        Column() {
          Text(this.reviewError)
            .fontSize(14)
            .fontColor('#FF6B6B')
          Button('重试')
            .onClick(() => {
              if (this.dish) {
                this.loadReviews(this.dish.dishId);
              }
            })
            .margin({ top: 8 })
        }
        .width('100%')
        .height(100)
        .justifyContent(FlexAlign.Center)
      } else if (this.reviews.length === 0) {
        Column() {
          Text('暂无评价')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height(100)
        .justifyContent(FlexAlign.Center)
      } else {
        Column() {
          ForEach(this.reviews, (review: Review) => {
            this.buildReviewItem(review)
          })

          if (this.hasMoreReviews) {
            Row() {
              if (this.isLoadingMoreReviews) {
                LoadingProgress().width(20).height(20)
                Text(' 正在加载更多...').fontSize(12).fontColor('#666666')
              } else {
                Button('加载更多评论')
                  .fontSize(12)
                  .onClick(() => this.onLoadMoreReviews())
              }
            }
            .width('100%')
            .height(48)
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
  }

  // 评论项
  @Builder
  buildReviewItem(review: Review) {
    Column() {
      Row() {
        Image(review.userAvatar || 'common/images/default_avatar.png')
          .width(40)
          .height(40)
          .borderRadius(20)
          .margin({ right: 12 })

        Column() {
          Text(review.userName)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 4 })

          Row() {
            ForEach(Array.from({ length: review.rating }), () => {
              Text('★')
                .fontSize(12)
                .fontColor('#FFC107')
            })
            ForEach(Array.from({ length: 5 - review.rating }), () => {
              Text('☆')
                .fontSize(12)
                .fontColor('#E0E0E0')
            })
          }
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Text(this.formatTime(review.createTime))
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Text(review.content)
        .fontSize(14)
        .fontColor('#666666')
        .lineHeight(20)
        .margin({ top: 12, bottom: 8 })

      if (review.images && review.images.length > 0) {
        Row() {
          ForEach(review.images, (image: string) => {
            Image(image)
              .width(80)
              .height(80)
              .objectFit(ImageFit.Cover)
              .borderRadius(4)
              .margin({ right: 8 })
          })
        }
        .margin({ bottom: 8 })
      }

      Row() {
        Text(`👍 ${review.likes}`)
          .fontSize(12)
          .fontColor('#999999')
      }

      Divider()
        .margin({ top: 12, bottom: 12 })
        .color('#F0F0F0')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 格式化时间
  private formatTime(timestamp: number): string {
    const now = Date.now();
    const diff = now - timestamp;
    const days = Math.floor(diff / 86400000);
    
    if (days === 0) {
      return '今天';
    } else if (days === 1) {
      return '昨天';
    } else if (days < 7) {
      return `${days}天前`;
    } else {
      const date = new Date(timestamp);
      return `${date.getMonth() + 1}-${date.getDate()}`;
    }
  }
}
