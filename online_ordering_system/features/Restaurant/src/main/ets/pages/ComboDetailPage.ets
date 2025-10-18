import { Combo, ComboDish } from 'common';
import { ComboDetailViewModel } from '../viewModel/ComboDetailViewModel';
import { ComboViewModel } from '../viewModel/ComboViewModel';
import { Review } from 'common';
import { LoadStatus } from '../util/DataState';
import { PageName } from '../util/NavigationTypes';

@Component
export struct ComboDetailPage {
  @Consume('restaurantPathStack') restaurantPathStack: NavPathStack;
  private viewModel: ComboDetailViewModel = new ComboDetailViewModel();
  private comboViewModel: ComboViewModel = new ComboViewModel();
  @State combo?: Combo = undefined;
  @State comboDishes: ComboDish[] = [];
  @State dishesLoading: boolean = false;
  @State dishesError?: string = undefined;
  @State reviews: Review[] = [];
  @State reviewStatus: LoadStatus = LoadStatus.Idle;
  @State reviewError?: string = undefined;
  @State isLoadingMoreReviews: boolean = false;
  @State hasMoreReviews: boolean = false;
  // 收藏状态
  @State isFavorited: boolean = false;
  private comboId: string = '';

  aboutToAppear() {
    this.combo = this.restaurantPathStack.getParamByName(PageName.COMBO_DETAIL)[0] as Combo;
    if (this.combo) {
      this.comboId = this.combo.comboId;
      this.checkFavoriteStatus();
      this.loadComboDishes();
      this.loadReviews();
    }
  }

  // 加载套餐菜品信息
  private async loadComboDishes() {
    if (!this.comboId) return;
    
    this.dishesLoading = true;
    this.dishesError = undefined;
    
    try {
      this.comboDishes = await this.comboViewModel.loadComboDishesByComboId(this.comboId);
      console.log('ComboDetailPage: 加载套餐菜品成功，菜品数量:', this.comboDishes.length);
    } catch (error) {
      console.error('ComboDetailPage: 加载套餐菜品失败:', error);
      this.dishesError = '加载菜品信息失败';
    } finally {
      this.dishesLoading = false;
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
    console.log(`Combo ${this.combo?.name} ${this.isFavorited ? '收藏' : '取消收藏'}`);
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          // 第一部分：套餐图片和返回按钮
          this.buildComboImage()

          // 第二部分：套餐信息
          this.buildComboInfo()

          // 第三部分：套餐描述
          this.buildDescription()

          // 第四部分：评论列表
          this.buildReviewList()
        }
        .width('100%')
      }
      .scrollBar(BarState.Auto)
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
      if (this.combo) {
        Image(this.combo.image)
          .width('100%')
          .height(300)
          .objectFit(ImageFit.Cover)
          .alt($r('app.media.zwt'))
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

  // 第二部分：套餐信息
  @Builder
  buildComboInfo() {
    if (this.combo) {
      Column() {
        Row() {
          Column() {
            Text(this.combo.name)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 8 })

            Row() {
              Text('★')
                .fontSize(14)
                .fontColor('#FFC107')
              Text(`${this.combo.rating}`)
                .fontSize(14)
                .fontColor('#666666')
                .margin({ left: 4, right: 12 })

              ForEach(this.combo.tags, (tag: string) => {
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
              Text(`￥${this.combo.price}`)
                .fontSize(24)
                .fontColor('#FF6B6B')
                .fontWeight(FontWeight.Bold)

              if (this.combo.originalPrice && this.combo.originalPrice > this.combo.price) {
                Text(`￥${this.combo.originalPrice}`)
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

  // 第三部分：套餐描述和菜品列表
  @Builder
  buildDescription() {
    Column() {
      // 套餐介绍
      if (this.combo && this.combo.description) {
        Column() {
          Text('套餐介绍')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 12 })

          Text(this.combo.description)
            .fontSize(14)
            .fontColor('#666666')
            .lineHeight(22)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 16 })
      }

      // 套餐菜品列表
      Column() {
        Text('套餐菜品')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 12 })

        if (this.dishesLoading) {
          Row() {
            LoadingProgress()
              .width(20)
              .height(20)
            Text(' 正在加载菜品信息...')
              .fontSize(14)
              .fontColor('#666666')
          }
          .width('100%')
          .height(60)
          .justifyContent(FlexAlign.Center)
        } else if (this.dishesError) {
          Column() {
            Text(this.dishesError)
              .fontSize(14)
              .fontColor('#FF6B6B')
            Button('重试')
              .fontSize(12)
              .onClick(() => {
                this.loadComboDishes();
              })
              .margin({ top: 8 })
          }
          .width('100%')
          .height(60)
          .justifyContent(FlexAlign.Center)
        } else if (this.comboDishes.length === 0) {
          Text('暂无菜品信息')
            .fontSize(14)
            .fontColor('#999999')
            .width('100%')
            .height(60)
            .textAlign(TextAlign.Center)
        } else {
          Column() {
            ForEach(this.comboDishes, (comboDish: ComboDish, index: number) => {
              this.buildDishItem(comboDish, index)
            })
          }
          .width('100%')
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

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

  // 菜品项
  @Builder
  buildDishItem(comboDish: ComboDish, index: number) {
    Row() {
      // 菜品图片
      Image(comboDish.dish.image || 'common/images/default_dish.png')
        .width(60)
        .height(60)
        .objectFit(ImageFit.Cover)
        .alt($r('app.media.zwt'))
        .borderRadius(8)
        .margin({ right: 12 })

      // 菜品信息
      Column() {
        Text(comboDish.dish.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ bottom: 4 })

        Row() {
          Text(`x${comboDish.quantity}`)
            .fontSize(12)
            .fontColor('#FF6B6B')
            .fontWeight(FontWeight.Medium)

          if (comboDish.isRequired) {
            Text('必选')
              .fontSize(10)
              .fontColor('#FF6B6B')
              .backgroundColor('#FFF0F0')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)
              .margin({ left: 8 })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .padding({ top: 8, bottom: 8 })
    .backgroundColor(index % 2 === 0 ? '#FAFAFA' : Color.Transparent)
    .borderRadius(8)
    .margin({ bottom: 4 })
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

        if (this.combo) {
          Text(`${this.combo.reviewCount}条评价`)
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
              if (this.combo) {
                this.loadReviews();
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

