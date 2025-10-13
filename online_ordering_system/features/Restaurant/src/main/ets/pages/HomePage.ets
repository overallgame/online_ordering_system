import { router } from '@kit.ArkUI';
import { Dish } from 'common';
import { DishesViewModel } from '../viewModel/DishesViewModel';
import { LoadStatus } from '../util/DataState';
import { BreakpointSystem } from 'utils';
import { BreakpointTypeEnum, BreakpointType } from 'utils/src/main/ets/utils/BreakpointSystem';

// 功能项接口
interface FeatureItem {
  id: string;
  name: string;
  icon: string;
}

@Entry
@Component
struct HomePage {
  @State searchText: string = '';
  // 轮播图数据
  @State banners: string[] = [
    'common/images/banner1.png',
    'common/images/banner2.png',
    'common/images/banner3.png'
  ];
  // 功能菜单数据
  @State features: FeatureItem[] = [
    { id: '1', name: '在线预约', icon: '📅' },
    { id: '2', name: '套餐推荐', icon: '📱' },
    { id: '3', name: '外卖配送', icon: '🛵' },
    { id: '4', name: '优惠活动', icon: '🎉' }
  ];
  private viewModel: DishesViewModel = new DishesViewModel();
  @State dishes: Dish[] = [];
  @State status: LoadStatus = LoadStatus.Idle;
  @State error?: string = undefined;
  @State isRefreshing: boolean = false;
  @State isLoadingMore: boolean = false;
  @State hasMore: boolean = false;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();

  aboutToAppear() {
    this.breakpointSystem.register();
    this.loadInitial();
  }

  aboutToDisappear() {
    this.breakpointSystem.unregister();
  }

  private async loadInitial() {
    this.status = LoadStatus.Loading;
    this.error = undefined;
    await this.viewModel.loadInitial();
    this.dishes = this.viewModel.state.data;
    this.status = this.viewModel.state.status;
    this.error = this.viewModel.state.error;
    this.hasMore = this.viewModel.hasMore;
  }

  private async onRefresh() {
    this.isRefreshing = true;
    await this.viewModel.refresh();
    this.dishes = this.viewModel.state.data;
    this.status = this.viewModel.state.status;
    this.error = this.viewModel.state.error;
    this.hasMore = this.viewModel.hasMore;
    this.isRefreshing = false;
  }

  private async onLoadMore() {
    if (this.isLoadingMore || !this.hasMore) {
      return;
    }
    this.isLoadingMore = true;
    await this.viewModel.loadMore();
    this.dishes = this.viewModel.state.data;
    this.hasMore = this.viewModel.hasMore;
    this.isLoadingMore = false;
  }

  build() {
    Column() {
      // 第一部分：餐厅名称和搜索框
      this.buildHeader()

      // 第二部分：轮播图
      this.buildBanner()

      // 第三部分：功能按钮
      this.buildFeatureButtons()

      // 第四部分：两列菜品列表
      this.buildDishGrid()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }

  // 第一部分：餐厅名称和搜索框
  @Builder
  buildHeader() {
    Row() {
      Row() {
        Text('鸿蒙智能点餐')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .alignItems(VerticalAlign.Center)

      Blank()

      Row() {
        Text('🔍')
          .fontSize(16)
          .margin({ right: 8 })

        TextInput({ placeholder: '搜索美食、商家、菜品', text: this.searchText })
          .fontSize(8)
          .backgroundColor(Color.Transparent)
          .width(this.searchWidth())
          .onChange((value: string) => {
            this.searchText = value;
          })

        if (this.searchText) {
          Text('✕')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ left: 8 })
            .onClick(() => {
              this.searchText = '';
            })
        }
      }
      .width('60%')
      .height(36)
      .backgroundColor('#F5F5F5')
      .borderRadius(18)
      .padding({ left: 12, right: 12 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: 16
    })
    .backgroundColor(Color.White)
  }

  // 第二部分：轮播图
  @Builder
  buildBanner() {
    Swiper() {
      ForEach(this.banners, (banner: string) => {
        Image(banner)
          .width('100%')
          .height(180)
          .objectFit(ImageFit.Cover)
          .borderRadius(12)
      })
    }
    .width('92%')
    .height(this.bannerHeight())
    .alignSelf(ItemAlign.Center)
    .indicator(true)
    .autoPlay(true)
    .interval(3000)
    .margin({ bottom: 10 })
  }

  // 第三部分：功能按钮
  @Builder
  buildFeatureButtons() {
    Row() {
      ForEach(this.features, (feature: FeatureItem) => {
        Column() {
          Text(feature.icon)
            .fontSize(24)
            .width(48)
            .height(48)
            .backgroundColor('#F8F8F8')
            .borderRadius(24)
            .textAlign(TextAlign.Center)

          Text(feature.name)
            .fontSize(12)
            .fontColor('#333333')
        }
        .width('25%')
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.handleFeatureClick(feature.id);
        })
      })
    }
    .width('92%')
    .height(this.featureBarHeight())
    .backgroundColor('#F8F8F8')
    .borderRadius(12)
    .padding({ top: 12, bottom: 12 })
    .alignSelf(ItemAlign.Center)
    .margin({ bottom: 20 })
    .shadow({
      radius: 2,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 1
    })
  }

  // 第四部分：菜品列表
  @Builder
  buildDishGrid() {
    Column() {
      if (this.status === LoadStatus.Loading) {
        Row() {
          LoadingProgress()
            .width(24)
            .height(24)
          Text(' 正在加载菜品...')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .height(120)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      } else if (this.status === LoadStatus.Error && this.error) {
        Column() {
          Text(this.error)
            .fontSize(14)
            .fontColor('#FF6B6B')
          Button('重试')
            .onClick(() => this.loadInitial())
            .margin({ top: 8 })
        }
        .width('100%')
        .height(160)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.dishes.length === 0) {
        Column() {
          Text('暂无菜品')
            .fontSize(14)
            .fontColor('#999999')
          Button('刷新')
            .onClick(() => this.onRefresh())
            .margin({ top: 8 })
        }
        .width('100%')
        .height(160)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Grid() {
          ForEach(this.dishes, (dish: Dish) => {
            GridItem() {
              this.buildDishCard(dish)
            }
          }, (dish: Dish) => dish.dishId)
        }
        .columnsTemplate(this.gridColumns())
        .columnsGap(12)
        .rowsGap(12)
        .width('92%')
        .scrollBar(BarState.Off)
        .padding({ top: 2, left: 16, right: 16 })

        if (this.hasMore) {
          Row() {
            if (this.isLoadingMore) {
              LoadingProgress().width(20).height(20)
              Text(' 正在加载更多...').fontSize(12).fontColor('#666666')
            } else {
              Button('加载更多').onClick(() => this.onLoadMore())
            }
          }
          .width('100%')
          .height(56)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }
      }
    }
    .width('100%')
  }

  // 菜品卡片
  @Builder
  buildDishCard(dish: Dish) {
    Column() {
      // 菜品图片
      Image(dish.image)
        .width('100%')
        .height(this.cardImageHeight())
        .objectFit(ImageFit.Cover)
        .borderRadius(8)

      // 菜品信息
      Column() {
        Text(dish.name)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 4 })

        // 评分信息
        Row() {
          this.buildRatingStars(dish.rating)
          Text(`${dish.rating} (${dish.reviewCount})`)
            .fontSize(12)
            .fontColor('#666666')
            .margin({ left: 4 })
        }
        .margin({ bottom: 6 })

        // 价格信息
        Row() {
          Text(`￥${dish.price}`)
            .fontSize(16)
            .fontColor('#FF6B6B')
            .fontWeight(FontWeight.Bold)

          if (dish.originalPrice && dish.originalPrice > dish.price) {
            Text(`￥${dish.originalPrice}`)
              .fontSize(12)
              .fontColor('#999999')
              .decoration({ type: TextDecorationType.LineThrough })
              .margin({ left: 4 })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .padding(8)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({
      radius: 2,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 1
    })
    .onClick(() => {
      if (dish.isAvailable) {
        this.showDishDetail(dish);
      }
    })
  }

  // 构建评分星星
  @Builder
  buildRatingStars(rating: number) {
    Row() {
      // 完整星星
      ForEach(Array.from({ length: Math.floor(rating) }), () => {
        Text('★')
          .fontSize(14)
          .fontColor('#FFC107')
      })

      // 半星
      if (rating % 1 >= 0.5) {
        Text('★')
          .fontSize(14)
          .fontColor('#FFC107')
          .opacity(0.7)
      }

      // 空星
      ForEach(Array.from({ length: 5 - Math.floor(rating) - (rating % 1 >= 0.5 ? 1 : 0) }), () => {
        Text('☆')
          .fontSize(14)
          .fontColor('#E0E0E0')
      })
    }
  }

  // ===== 响应式辅助方法 =====
  private gridColumns(): string {
    const cols: string | undefined = new BreakpointType<string>({
      sm: '1fr',
      md: '1fr 1fr',
      lg: '1fr 1fr',
      xl: '1fr 1fr 1fr'
    }).getValue(this.currentBreakpoint);
    return cols || '1fr 1fr';
  }

  private cardImageHeight(): number {
    const h: number | undefined = new BreakpointType<number>({
      sm: 96,
      md: 100,
      lg: 120,
      xl: 140
    }).getValue(this.currentBreakpoint);
    return h || 100;
  }

  private bannerHeight(): number {
    const h: number | undefined = new BreakpointType<number>({
      sm: 140,
      md: 180,
      lg: 200,
      xl: 220
    }).getValue(this.currentBreakpoint);
    return h || 180;
  }

  private featureBarHeight(): number {
    const h: number | undefined = new BreakpointType<number>({
      sm: 72,
      md: 80,
      lg: 84,
      xl: 90
    }).getValue(this.currentBreakpoint);
    return h || 80;
  }

  private searchWidth(): string {
    const w: number | string | undefined = new BreakpointType<number | string>({
      sm: 120,
      md: 150,
      lg: 220,
      xl: 260
    }).getValue(this.currentBreakpoint);
    return typeof w === 'number' ? `${w}` : (w || '150');
  }

  // 处理功能点击
  private handleFeatureClick(featureId: string): void {
    switch (featureId) {
      case '1': // 在线预约
        router.pushUrl({ url: 'pages/ReservationPage' });
        break;
      case '2': // 扫码点餐
        router.pushUrl({ url: 'pages/ScanQRPage' });
        break;
      case '3': // 外卖配送
        router.pushUrl({ url: 'pages/DeliveryPage' });
        break;
      case '4': // 优惠活动
        router.pushUrl({ url: 'pages/PromotionPage' });
        break;
    }
  }

  // 显示菜品详情
  private showDishDetail(dish: Dish): void {
    router.pushUrl({
      url: 'pages/DishDetailPage',
      params: { dishId: dish.dishId }
    });
  }
}