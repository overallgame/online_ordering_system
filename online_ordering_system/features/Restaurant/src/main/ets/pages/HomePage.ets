import { Category, Dish } from 'common';
import { DishViewModel } from '../viewModel/DishViewModel';
import { LoadStatus } from '../util/DataState';
import { BreakpointSystem } from 'utils';
import { BreakpointTypeEnum, BreakpointType } from 'utils/src/main/ets/utils/BreakpointSystem';
import { PageName } from '../util/NavigationTypes';
import { DishDetailPage } from './DishDetailPage';
import { ComboDetailPage } from './ComboDetailPage';
import { ComboRecommendPage } from './ComboRecommendPage';
import { DeliveryPage } from './DeliveryPage';
import { PaymentSuccessPage } from './PaymentSuccessPage';
import { OnlineOrderPage } from './OnlineOrderPage';
import { CategoryTabsComponent } from '../view/CategoryTabsComponent';

// 功能项接口
interface FeatureItem {
  id: string;
  name: string;
  icon: Resource;
}

@Component
export struct HomePage {
  @Provide('restaurantPathStack') restaurantPathStack: NavPathStack = new NavPathStack();
  // 轮播图数据
  @State banners: string[] = [
    'common/images/banner1.png',
    'common/images/banner2.png',
    'common/images/banner3.png'
  ];
  // 功能菜单数据
  @State features: FeatureItem[] = [
    { id: '1', name: '在线点餐', icon: $r('app.media.orderIcon') },
    { id: '2', name: '套餐推荐', icon: $r('app.media.ComboIcon') },
    { id: '3', name: '外卖配送', icon: $r('app.media.deliveryIcon') },
  ];
  private viewModel: DishViewModel = new DishViewModel();
  @State categories: Category[] = [];
  @State @Watch('onSelectedCategoryChanged') selectedCategory: Category | null = null;
  @State dishes: Dish[] = [];
  @State status: LoadStatus = LoadStatus.Idle;
  @State error?: string = undefined;
  @State isRefreshing: boolean = false;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();

  aboutToAppear() {
    this.breakpointSystem.register();
    this.loadCategories();
  }

  aboutToDisappear() {
    this.breakpointSystem.unregister();
  }

  private async loadCategories() {
    this.categories = await this.viewModel.loadCategories(1);
    console.log(this.categories.toString()+"wwwwww")
    if (this.categories.length > 0) {
      this.selectedCategory = this.categories[0];
      await this.loadInitial();
    }
  }

  private async loadInitial() {
    this.status = LoadStatus.Loading;
    this.error = undefined;

    if (this.selectedCategory) {
      await this.viewModel.loadDishesByCategoryId(this.selectedCategory.id);
    } else {
      await this.viewModel.loadDishesByCategoryId(101);
    }
    
    this.dishes = this.viewModel.state.data;
    this.status = this.viewModel.state.status;
    this.error = this.viewModel.state.error;
  }

  private async onRefresh() {
    this.isRefreshing = true;

    if (this.selectedCategory) {
      await this.viewModel.loadDishesByCategoryId(this.selectedCategory.id);
    } else {
      await this.viewModel.loadDishesByCategoryId(101);
    }
    
    this.dishes = this.viewModel.state.data;
    this.status = this.viewModel.state.status;
    this.error = this.viewModel.state.error;
    this.isRefreshing = false;
  }

  // 监听分类变化
  private async onSelectedCategoryChanged() {
    if (this.selectedCategory) {
      await this.loadDishesByCategory();
    }
  }

  // 根据选中分类加载菜品
  private async loadDishesByCategory() {
    if (!this.selectedCategory) return;
    
    this.status = LoadStatus.Loading;
    this.error = undefined;
    
    await this.viewModel.loadDishesByCategoryId(this.selectedCategory.id);
    
    this.dishes = this.viewModel.state.data;
    this.status = this.viewModel.state.status;
    this.error = this.viewModel.state.error;
  }

  build() {
    Navigation(this.restaurantPathStack) {
      Column() {
        this.buildHeader()
        this.buildBanner()
        this.buildFeatureButtons()
        this.buildCategoryTabs()
        this.buildDishGrid()
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.comp_background_list_card'))
    }
    .navDestination(this.restaurantRouter)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }

  // 餐厅路由构建器
  @Builder
  restaurantRouter(name: string, _param?: Object) {
    if (name === PageName.DISH_DETAIL) {
      DishDetailPage()
    } else if (name === PageName.COMBO_DETAIL) {
      ComboDetailPage()
    } else if (name === PageName.COMBO_RECOMMEND) {
      ComboRecommendPage()
    } else if (name === PageName.ONLINE_ORDER) {
      OnlineOrderPage()
    } else if (name === PageName.DELIVERY) {
      DeliveryPage()
    } else if (name === PageName.PAYMENT_SUCCESS) {
      PaymentSuccessPage()
    }
  }

  // 第一部分：餐厅标题
  @Builder
  buildHeader() {
    Row() {
      Column() {
        Text('鸿蒙智能点餐')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 6 })
        
        Text('欢迎光临，享受美食时光')
          .fontSize(15)
          .fontColor('#666666')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 24 })
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
          Image(feature.icon)
            .width(24)
            .height(24)
            .backgroundColor('#F8F8F8')
            .borderRadius(30)
            .objectFit(ImageFit.Contain)
            .margin({ bottom: 10 })

          Text(feature.name)
            .fontSize(10)
            .fontColor('#333333')
        }
        .width('33%')
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
    .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 })
  }

  // 第四部分：分类栏
  @Builder
  buildCategoryTabs() {
    CategoryTabsComponent({
      categories: this.categories,
      selectedCategory: $selectedCategory
    })
  }

  // 第五部分：菜品列表
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
      }
    }
    .width('100%')
  }

  // 菜品卡片
  @Builder
  buildDishCard(dish: Dish) {
    Column() {
      Image(dish.image)
        .width('100%')
        .height(this.cardImageHeight())
        .objectFit(ImageFit.Cover)
        .borderRadius(8)

      Column() {
        Text(dish.name)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 4 })

        Row() {
          this.buildRatingStars(dish.rating)
          Text(`${dish.rating} (${dish.reviewCount})`)
            .fontSize(12)
            .fontColor('#666666')
            .margin({ left: 4 })
        }
        .margin({ bottom: 6 })

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
    .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 })
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
      ForEach(Array.from({ length: Math.floor(rating) }), () => {
        Text('★')
          .fontSize(14)
          .fontColor('#FFC107')
      })

      if (rating % 1 >= 0.5) {
        Text('★')
          .fontSize(14)
          .fontColor('#FFC107')
          .opacity(0.7)
      }

      ForEach(Array.from({ length: 5 - Math.floor(rating) - (rating % 1 >= 0.5 ? 1 : 0) }), () => {
        Text('☆')
          .fontSize(14)
          .fontColor('#E0E0E0')
      })
    }
  }

  private gridColumns(): string {
    const cols: string | undefined = new BreakpointType<string>({
      sm: '1fr 1fr',
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

  // 处理功能点击
  private handleFeatureClick(featureId: string): void {
    switch (featureId) {
      case '1':
        this.restaurantPathStack.pushPathByName(PageName.ONLINE_ORDER, null);
        break;
      case '2':
        this.restaurantPathStack.pushPathByName(PageName.COMBO_RECOMMEND, null);
        break;
      case '3':
        this.restaurantPathStack.pushPathByName(PageName.DELIVERY, null);
        break;
    }
  }

  // 显示菜品详情
  private showDishDetail(dish: Dish): void {
    this.restaurantPathStack.pushPathByName(PageName.DISH_DETAIL, dish);
  }
}