import { Combo } from 'common';
import { ComboDetailViewModel } from '../viewModel/ComboDetailViewModel';
import { CartViewModel } from '../viewModel/CartViewModel';
import { DishReview } from '../repository/ReviewRepository';
import { LoadStatus } from '../util/DataState';
import { PageName, ComboDetailParams } from '../util/NavigationTypes';

@Component
export struct ComboDetailPage {
  @Consume('restaurantPathStack') restaurantPathStack: NavPathStack;
  private viewModel: ComboDetailViewModel = new ComboDetailViewModel();
  private cartViewModel: CartViewModel = new CartViewModel();
  @State combo?: Combo = undefined;
  @State reviews: DishReview[] = [];
  @State reviewStatus: LoadStatus = LoadStatus.Idle;
  @State reviewError?: string = undefined;
  @State isLoadingMoreReviews: boolean = false;
  @State hasMoreReviews: boolean = false;
  // 购物车状态
  @State comboQuantity: number = 0;
  @State cartTotalQuantity: number = 0;
  @State cartTotalAmount: number = 0;
  private comboId: string = '';

  aboutToAppear() {
    const params = this.restaurantPathStack.getParamByName(PageName.COMBO_DETAIL)[0] as ComboDetailParams;
    if (params && params.comboId) {
      this.comboId = params.comboId;
      this.loadComboInfo();
      this.loadReviews();
    }
  }

  private async loadComboInfo() {
    await this.viewModel.loadComboDetails(this.comboId);
    this.combo = this.viewModel.combo;
    if (this.combo) {
      this.comboQuantity = this.cartViewModel.getItemQuantity(this.combo.comboId);
      this.syncCartState();
    }
  }

  private async loadReviews() {
    this.reviewStatus = LoadStatus.Loading;
    this.reviewError = undefined;
    await this.viewModel.loadReviews(this.comboId);
    this.reviews = this.viewModel.reviewsState.data;
    this.reviewStatus = this.viewModel.reviewsState.status;
    this.reviewError = this.viewModel.reviewsState.error;
    this.hasMoreReviews = this.viewModel.hasMoreReviews;
  }

  private async onLoadMoreReviews() {
    if (this.isLoadingMoreReviews || !this.hasMoreReviews) {
      return;
    }
    this.isLoadingMoreReviews = true;
    await this.viewModel.loadMoreReviews(this.comboId);
    this.reviews = this.viewModel.reviewsState.data;
    this.hasMoreReviews = this.viewModel.hasMoreReviews;
    this.isLoadingMoreReviews = false;
  }

  // 同步购物车状态
  private syncCartState(): void {
    this.cartTotalQuantity = this.cartViewModel.totalQuantity;
    this.cartTotalAmount = this.cartViewModel.totalAmount;
    if (this.combo) {
      this.comboQuantity = this.cartViewModel.getItemQuantity(this.combo.comboId);
    }
  }

  // 添加到购物车
  private addToCart(): void {
    if (this.combo) {
      this.cartViewModel.addToCart(this.combo);
      this.syncCartState();
    }
  }

  // 更新数量
  private updateQuantity(quantity: number): void {
    if (this.combo) {
      this.cartViewModel.updateQuantity(this.combo.comboId, quantity);
      this.syncCartState();
    }
  }

  build() {
    NavDestination() {
      Column() {
      // 第一部分：套餐图片和返回按钮
      this.buildComboImage()

      Scroll() {
        Column() {
          // 第二部分：套餐信息
          this.buildComboInfo()

          // 第三部分：套餐描述
          this.buildDescription()

          // 第四部分：评论列表
          this.buildReviewList()
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_list_card'))
    }
    .hideTitleBar(true)
  }

  // 第一部分：套餐图片和返回按钮
  @Builder
  buildComboImage() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        if (this.combo) {
          Text(this.combo.icon)
            .fontSize(120)
            .textAlign(TextAlign.Center)
        }
      }
      .width('100%')
      .height(280)
      .backgroundColor('#F8F8F8')
      .justifyContent(FlexAlign.Center)

      Row() {
        Text('←')
          .fontSize(20)
          .fontColor('#333333')
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.White)
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .margin({ left: 16, top: 16 })
      .shadow({
        radius: 4,
        color: '#1A000000',
        offsetX: 0,
        offsetY: 2
      })
      .onClick(() => {
        this.restaurantPathStack.pop();
      })
    }
    .width('100%')
    .height(280)
  }

  // 第二部分：套餐信息
  @Builder
  buildComboInfo() {
    Column() {
      Row() {
        Text(this.combo?.name)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)

        if (this.comboQuantity > 0) {
          Row() {
            Row() {
              Text('-')
                .fontSize(16)
                .fontColor(Color.White)
            }
            .width(28)
            .height(28)
            .backgroundColor('#FF6B6B')
            .borderRadius(14)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              this.updateQuantity(this.comboQuantity - 1);
            })

            Text(`${this.comboQuantity}`)
              .fontSize(14)
              .fontColor('#333333')
              .fontWeight(FontWeight.Medium)
              .margin({ left: 10, right: 10 })

            Row() {
              Text('+')
                .fontSize(16)
                .fontColor(Color.White)
            }
            .width(28)
            .height(28)
            .backgroundColor('#FF6B6B')
            .borderRadius(14)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              this.addToCart();
            })
          }
          .alignItems(VerticalAlign.Center)
        } else {
          Row() {
            Text('+')
              .fontSize(18)
              .fontColor(Color.White)
          }
          .width(32)
          .height(32)
          .backgroundColor('#FF6B6B')
          .borderRadius(16)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            this.addToCart();
          })
        }
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Text('★')
          .fontSize(16)
          .fontColor('#FFC107')
        Text(`${this.combo?.rating}`)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 4 })
        Text(`(${this.combo?.reviewCount}条评论)`)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ left: 4 })
      }
      .margin({ bottom: 12 })

      if (this.combo!!.tags.length > 0) {
        Row() {
          ForEach(this.combo?.tags, (tag: string) => {
            Text(tag)
              .fontSize(12)
              .fontColor('#FF6B6B')
              .backgroundColor('#FFF0F0')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(12)
              .margin({ right: 8 })
          })
        }
        .margin({ bottom: 12 })
      }

      Row() {
        Text(`￥${this.combo?.price}`)
          .fontSize(24)
          .fontColor('#FF6B6B')
          .fontWeight(FontWeight.Bold)

        if (this.combo?.originalPrice && this.combo.originalPrice > this.combo.price) {
          Text(`￥${this.combo.originalPrice}`)
            .fontSize(14)
            .fontColor('#999999')
            .decoration({ type: TextDecorationType.LineThrough })
            .margin({ left: 8 })

          Text(`省￥${this.combo.discount}`)
            .fontSize(12)
            .fontColor('#FF6B6B')
            .backgroundColor('#FFF0F0')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(8)
            .margin({ left: 8 })
        }
      }
      .margin({ bottom: 12 })

      Row() {
        Text('⏱')
          .fontSize(14)
          .margin({ right: 4 })
        Text(`预计${this.combo?.preparationTime}分钟`)
          .fontSize(13)
          .fontColor('#666666')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
  }

  // 第三部分：套餐描述
  @Builder
  buildDescription() {
    Column() {
      Text('套餐介绍')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 12 })

      Text(this.combo?.description)
        .fontSize(14)
        .fontColor('#666666')
        .lineHeight(22)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 12 })
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

        if (this.combo) {
          Text(`(${this.combo.reviewCount})`)
            .fontSize(14)
            .fontColor('#999999')
            .margin({ left: 4 })
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
        .height(80)
        .justifyContent(FlexAlign.Center)
      } else if (this.reviewStatus === LoadStatus.Error && this.reviewError) {
        Column() {
          Text(this.reviewError)
            .fontSize(14)
            .fontColor('#FF6B6B')
          Button('重试')
            .onClick(() => this.loadReviews())
            .margin({ top: 8 })
        }
        .width('100%')
        .height(100)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.reviews.length === 0) {
        Column() {
          Text('暂无评论')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height(80)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Column() {
          ForEach(this.reviews, (review: DishReview) => {
            this.buildReviewItem(review);
          }, (review: DishReview) => review.reviewId)

          if (this.hasMoreReviews) {
            Row() {
              if (this.isLoadingMoreReviews) {
                LoadingProgress().width(20).height(20)
                Text(' 正在加载更多...').fontSize(12).fontColor('#666666')
              } else {
                Button('加载更多评论').onClick(() => this.onLoadMoreReviews())
              }
            }
            .width('100%')
            .height(48)
            .justifyContent(FlexAlign.Center)
            .margin({ top: 8 })
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
  buildReviewItem(review: DishReview) {
    Column() {
      Row() {
        if (review.userAvatar) {
          Image(review.userAvatar)
            .width(36)
            .height(36)
            .borderRadius(18)
            .margin({ right: 8 })
        } else {
          Text(review.userName.substring(0, 1))
            .fontSize(16)
            .fontColor(Color.White)
            .width(36)
            .height(36)
            .borderRadius(18)
            .backgroundColor('#FF6B6B')
            .textAlign(TextAlign.Center)
            .margin({ right: 8 })
        }

        Column() {
          Text(review.userName)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text(this.formatTime(review.createTime))
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Row() {
          Text('★')
            .fontSize(14)
            .fontColor('#FFC107')
          Text(`${review.rating}`)
            .fontSize(13)
            .fontColor('#666666')
            .margin({ left: 2 })
        }
      }
      .width('100%')
      .margin({ bottom: 8 })

      Text(review.content)
        .fontSize(14)
        .fontColor('#333333')
        .lineHeight(20)
        .margin({ bottom: 8 })

      if (review.images.length > 0) {
        Row() {
          ForEach(review.images.slice(0, 3), (image: string) => {
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
        Text('👍')
          .fontSize(12)
        Text(`${review.likes}`)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ left: 4 })
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F8F8F8')
    .borderRadius(8)
    .margin({ bottom: 12 })
    .alignItems(HorizontalAlign.Start)
  }

  // 格式化时间
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 60) {
      return `${minutes}分钟前`;
    } else if (hours < 24) {
      return `${hours}小时前`;
    } else if (days < 7) {
      return `${days}天前`;
    } else {
      const year = date.getFullYear();
      const month = date.getMonth() + 1;
      const day = date.getDate();
      return `${year}-${month}-${day}`;
    }
  }
}

