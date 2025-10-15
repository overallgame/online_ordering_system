import { Dish } from 'common';
import { BreakpointSystem } from 'utils';
import { BreakpointTypeEnum } from 'utils/src/main/ets/utils/BreakpointSystem';
import { DishViewModel } from '../viewModel/DishViewModel';
import { CartViewModel, CartItem } from '../viewModel/CartViewModel';
import { LoadStatus } from '../util/DataState';
import { PageName, DishDetailParams, CheckoutParams } from '../util/NavigationTypes';

@Component
export struct DeliveryPage {
  @Consume('restaurantPathStack') restaurantPathStack: NavPathStack;
  private viewModel: DishViewModel = new DishViewModel();
  private cartViewModel: CartViewModel = new CartViewModel();
  @State dishes: Dish[] = [];
  @State allDishes: Dish[] = [];
  @State status: LoadStatus = LoadStatus.Idle;
  @State error?: string = undefined;
  @State isRefreshing: boolean = false;
  @State isLoadingMore: boolean = false;
  @State hasMore: boolean = false;
  @State searchText: string = '';
  // 购物车状态
  @State cartItems: CartItem[] = [];
  @State cartTotalQuantity: number = 0;
  @State cartTotalAmount: number = 0;
  @State dishQuantities: Map<string, number> = new Map();
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
    this.allDishes = this.viewModel.state.data;
    this.dishes = this.allDishes;
    this.status = this.viewModel.state.status;
    this.error = this.viewModel.state.error;
    this.hasMore = this.viewModel.hasMore;
  }

  private async onRefresh() {
    this.isRefreshing = true;
    await this.viewModel.refresh();
    this.allDishes = this.viewModel.state.data;
    this.dishes = this.allDishes;
    this.status = this.viewModel.state.status;
    this.error = this.viewModel.state.error;
    this.hasMore = this.viewModel.hasMore;
    this.isRefreshing = false;
    if (this.searchText.trim()) {
      this.filterDishes();
    }
  }

  private async onLoadMore() {
    if (this.isLoadingMore || !this.hasMore) {
      return;
    }
    this.isLoadingMore = true;
    await this.viewModel.loadMore();
    this.allDishes = this.viewModel.state.data;
    this.hasMore = this.viewModel.hasMore;
    this.isLoadingMore = false;
    if (this.searchText.trim()) {
      this.filterDishes();
    } else {
      this.dishes = this.allDishes;
    }
  }

  private onSearch() {
    if (this.searchText.trim()) {
      this.filterDishes();
    } else {
      this.dishes = this.allDishes;
    }
  }

  // 筛选菜品
  private filterDishes() {
    const keyword = this.searchText.trim().toLowerCase();
    this.dishes = this.allDishes.filter(dish =>
    dish.name.toLowerCase().includes(keyword) ||
    dish.description?.toLowerCase().includes(keyword) ||
    dish.tags.some(tag => tag.toLowerCase().includes(keyword))
    );
  }

  // 同步购物车状态
  private syncCartState(): void {
    this.cartItems = this.cartViewModel.items;
    this.cartTotalQuantity = this.cartViewModel.totalQuantity;
    this.cartTotalAmount = this.cartViewModel.totalAmount;
    
    // 同步每个菜品的数量
    const newQuantities = new Map<string, number>();
    this.cartItems.forEach(item => {
      if (item.dish && item.dish.dishId) {
        newQuantities.set(item.dish.dishId, item.quantity);
      }
    });
    this.dishQuantities = newQuantities;
  }

  // 添加菜品到购物车
  private addToCart(dish: Dish): void {
    this.cartViewModel.addDishToCart(dish);
    this.syncCartState();
  }

  // 更新菜品数量
  private updateCartQuantity(dishId: string, quantity: number): void {
    this.cartViewModel.updateDishQuantity(dishId, quantity);
    this.syncCartState();
  }

  build() {
    NavDestination() {
      Column() {
      // 第一部分：顶部标题栏
      this.buildHeader()

      // 第二部分：菜品列表
      this.buildDishList()

      // 第三部分：悬浮购物车栏
      this.buildFloatingCart()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('linear-gradient(180deg, #E8F5E8 0%, #F8F9FA 100%)')
    }
    .hideTitleBar(true)
  }

  // 第一部分：顶部标题栏
  @Builder
  buildHeader() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            this.restaurantPathStack.pop()
          })

        Column() {
          Text('外卖配送')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Black)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Row().width(20)
      }
      .width('100%')
      .height(50)
      .padding({ left: 20, right: 20, bottom: 16 })
      .borderRadius({ bottomLeft: 20, bottomRight: 20 })
      .alignItems(VerticalAlign.Center)

      Row() {
        Image($r('app.media.search'))
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)
          .margin({ right: 12 })

        TextInput({ placeholder: '搜索菜品...', text: this.searchText })
          .fontSize(15)
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .placeholderColor('#999999')
          .onChange((value: string) => {
            this.searchText = value;
          })
          .onSubmit(() => {
            this.onSearch();
          })

        if (this.searchText) {
          Text('✕')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ left: 8 })
            .onClick(() => {
              this.searchText = '';
              this.onSearch();
            })
        }
      }
      .width('92%')
      .height(44)
      .backgroundColor('#F8F9FA')
      .borderRadius(22)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .margin({ left: 20, right: 20, bottom: 16 })
      .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    }
    .width('100%')
    .backgroundColor(Color.White)
  }

  // 第二部分：菜品列表
  @Builder
  buildDishList() {
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
        List() {
          ForEach(this.dishes, (dish: Dish) => {
            ListItem() {
              this.buildDishCard(dish)
            }
          }, (dish: Dish) => dish.dishId)
        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        .padding({ top: 16 })

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
    .layoutWeight(1)
  }

  // 菜品卡片
  @Builder
  buildDishCard(dish: Dish) {
    Row() {
      Image(dish.image)
        .width(80)
        .height(80)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
        .margin({ right: 12 })
        .onClick(() => {
          this.showDishDetail(dish);
        })

      Column() {
        Text(dish.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 4 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(dish.description || '')
          .fontSize(13)
          .fontColor('#666666')
          .margin({ bottom: 8 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (dish.tags.length > 0) {
          Row() {
            ForEach(dish.tags, (tag: string) => {
              Text(tag)
                .fontSize(10)
                .fontColor('#FF6B6B')
                .backgroundColor('#FFF0F0')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(8)
                .margin({ right: 4 })
            })
          }
          .margin({ bottom: 8 })
        }

        Row() {
          Text('★')
            .fontSize(12)
            .fontColor('#FFC107')
          Text(`${dish.rating}`)
            .fontSize(12)
            .fontColor('#666666')
            .margin({ left: 2 })
          Text(`(${dish.reviewCount})`)
            .fontSize(10)
            .fontColor('#999999')
            .margin({ left: 2 })
        }
        .margin({ bottom: 8 })

        Row() {
          Column() {
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
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          if ((this.dishQuantities.get(dish.dishId) || 0) > 0) {
            Row() {
              Row() {
                Text('-')
                  .fontSize(16)
                  .fontColor(Color.White)
              }
              .width(24)
              .height(24)
              .backgroundColor('#4CAF50')
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                const currentQuantity = this.dishQuantities.get(dish.dishId) || 0;
                this.updateCartQuantity(dish.dishId, currentQuantity - 1);
              })

              Text(`${this.dishQuantities.get(dish.dishId) || 0}`)
                .fontSize(14)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
                .margin({ left: 8, right: 8 })

              Row() {
                Text('+')
                  .fontSize(16)
                  .fontColor(Color.White)
              }
              .width(24)
              .height(24)
              .backgroundColor('#4CAF50')
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                this.addToCart(dish);
              })
            }
            .alignItems(VerticalAlign.Center)
          } else {
            Row() {
              Text('+')
                .fontSize(16)
                .fontColor(Color.White)
            }
            .width(24)
            .height(24)
            .backgroundColor('#4CAF50')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              this.addToCart(dish);
            })
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .onClick(() => {
        this.showDishDetail(dish);
      })
    }
    .width('92%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ left: 16, right: 16, bottom: 12 })
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  // 显示菜品详情
  private showDishDetail(dish: Dish): void {
    const params: DishDetailParams = {
      dishId: dish.dishId,
      hideCart: false
    };
    this.restaurantPathStack.pushPathByName(PageName.DISH_DETAIL, params);
  }

  // 第三部分：悬浮购物车栏
  @Builder
  buildFloatingCart() {
    Row() {
      if (this.cartTotalQuantity > 0) {
        Row() {
          Stack() {
            Row() {
              Image($r('app.media.car'))
                .width(24)
                .height(24)
            }
            .width(40)
            .height(40)
            .backgroundColor('#4CAF50')
            .borderRadius(20)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)

            Text(`${this.cartTotalQuantity}`)
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor('#388E3C')
              .borderRadius(8)
              .padding({ left: 4, right: 4, top: 1, bottom: 1 })
              .position({ x: 28, y: -2 })
          }

          Blank()

          Text(`￥${this.cartTotalAmount.toFixed(2)}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ right: 16 })

          Button('去结算')
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#4CAF50')
            .borderRadius(20)
            .width(80)
            .height(36)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.goToCheckout();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      } else {
        Row() {
          Row() {
            Image($r('app.media.car'))
              .width(24)
              .height(24)
          }
          .width(40)
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)

          Text('免运费')
            .fontSize(14)
            .fontColor('#4CAF50')
            .margin({ left: 16 })

          Blank()

          Button('0元起送')
            .fontSize(12)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(16)
            .width(70)
            .height(32)
            .onClick(() => {
              // 可以添加一些提示逻辑
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 20, topRight: 20 })
    .position({ x: 0, y: '100%' })
    .translate({ y: -56 })
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: -2 })
  }

  // 去结算
  private goToCheckout(): void {
    const params: CheckoutParams = {
      orderId: undefined,
      source: 'delivery',
      cartItems: this.cartViewModel.items
    };
    this.restaurantPathStack.pushPathByName(PageName.CHECKOUT, params);
  }
}
