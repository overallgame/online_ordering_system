import { Combo } from 'common';
import { BreakpointSystem } from 'utils';
import { BreakpointTypeEnum } from 'utils/src/main/ets/utils/BreakpointSystem';
import { ComboViewModel } from '../viewModel/ComboViewModel';
import { CartViewModel, CartItem } from '../viewModel/CartViewModel';
import { LoadStatus } from '../util/DataState';
import { PageName, ComboDetailParams, CheckoutParams } from '../util/NavigationTypes';

@Component
export struct ComboRecommendPage {
  @Consume('restaurantPathStack') restaurantPathStack: NavPathStack;
  private viewModel: ComboViewModel = new ComboViewModel();
  private cartViewModel: CartViewModel = new CartViewModel();
  @State combos: Combo[] = [];
  @State allCombos: Combo[] = [];
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
  @State comboQuantities: Map<string, number> = new Map();
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
    this.allCombos = this.viewModel.state.data;
    this.combos = this.allCombos;
    this.status = this.viewModel.state.status;
    this.error = this.viewModel.state.error;
    this.hasMore = this.viewModel.hasMore;
  }

  private async onRefresh() {
    this.isRefreshing = true;
    await this.viewModel.refresh();
    this.allCombos = this.viewModel.state.data;
    this.combos = this.allCombos;
    this.status = this.viewModel.state.status;
    this.error = this.viewModel.state.error;
    this.hasMore = this.viewModel.hasMore;
    this.isRefreshing = false;
    if (this.searchText.trim()) {
      this.filterCombos();
    }
  }

  private async onLoadMore() {
    if (this.isLoadingMore || !this.hasMore) {
      return;
    }
    this.isLoadingMore = true;
    await this.viewModel.loadMore();
    this.allCombos = this.viewModel.state.data;
    this.hasMore = this.viewModel.hasMore;
    this.isLoadingMore = false;
    if (this.searchText.trim()) {
      this.filterCombos();
    } else {
      this.combos = this.allCombos;
    }
  }

  private onSearch() {
    if (this.searchText.trim()) {
      this.filterCombos();
    } else {
      this.combos = this.allCombos;
    }
  }

  // 筛选套餐
  private filterCombos() {
    const keyword = this.searchText.trim().toLowerCase();
    this.combos = this.allCombos.filter(combo =>
    combo.name.toLowerCase().includes(keyword) ||
    combo.description.toLowerCase().includes(keyword) ||
    combo.tags.some(tag => tag.toLowerCase().includes(keyword))
    );
  }

  // 同步购物车状态
  private syncCartState(): void {
    this.cartItems = this.cartViewModel.items;
    this.cartTotalQuantity = this.cartViewModel.totalQuantity;
    this.cartTotalAmount = this.cartViewModel.totalAmount;
    
    // 同步每个套餐的数量
    const newQuantities = new Map<string, number>();
    this.cartItems.forEach(item => {
      if (item.combo && item.combo.comboId) {
        newQuantities.set(item.combo.comboId, item.quantity);
      }
    });
    this.comboQuantities = newQuantities;
  }

  // 添加套餐到购物车
  private addToCart(combo: Combo): void {
    this.cartViewModel.addToCart(combo);
    this.syncCartState();
  }

  // 更新套餐数量
  private updateCartQuantity(comboId: string, quantity: number): void {
    this.cartViewModel.updateQuantity(comboId, quantity);
    this.syncCartState();
  }

  build() {
    NavDestination() {
      Column() {
        // 第一部分：顶部标题栏
        this.buildHeader()

        // 第二部分：套餐列表
        this.buildComboList()

        // 第三部分：悬浮购物车栏
        this.buildFloatingCart()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('linear-gradient(180deg, #F3E5F5 0%, #F8F9FA 100%)')
    }.hideTitleBar(true)
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
          Text('套餐推荐')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Black)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Row().width(20)
      }
      .width('100%')
      .height(80)
      .padding({ left: 20, right: 20, bottom: 16 })
      .borderRadius({ bottomLeft: 20, bottomRight: 20 })
      .alignItems(VerticalAlign.Center)

      // 搜索框
      Row() {
        Image($r('app.media.search'))
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)
          .margin({ right: 12 })

        TextInput({ placeholder: '搜索套餐...', text: this.searchText })
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

  // 第二部分：套餐列表
  @Builder
  buildComboList() {
    Column() {
      if (this.status === LoadStatus.Loading) {
        Row() {
          LoadingProgress()
            .width(24)
            .height(24)
          Text(' 正在加载套餐...')
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
      } else if (this.combos.length === 0) {
        Column() {
          Text('暂无套餐')
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
          ForEach(this.combos, (combo: Combo) => {
            ListItem() {
              this.buildComboCard(combo)
            }
          }, (combo: Combo) => combo.comboId)
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

  // 套餐卡片
  @Builder
  buildComboCard(combo: Combo) {
    Row() {
      Column() {
        Text(combo.icon)
          .fontSize(32)
          .width(60)
          .height(60)
          .backgroundColor('#F8F8F8')
          .borderRadius(30)
          .textAlign(TextAlign.Center)
      }
      .margin({ right: 12 })
      .onClick(() => {
        this.showComboDetail(combo);
      })

      Column() {
        Text(combo.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 4 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(combo.description)
          .fontSize(13)
          .fontColor('#666666')
          .margin({ bottom: 8 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (combo.tags.length > 0) {
          Row() {
            ForEach(combo.tags, (tag: string) => {
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
          Text(`${combo.rating}`)
            .fontSize(12)
            .fontColor('#666666')
            .margin({ left: 2 })
          Text(`(${combo.reviewCount})`)
            .fontSize(10)
            .fontColor('#999999')
            .margin({ left: 2 })
        }
        .margin({ bottom: 8 })

        Row() {
          Column() {
            Row() {
              Text(`￥${combo.price}`)
                .fontSize(16)
                .fontColor('#FF6B6B')
                .fontWeight(FontWeight.Bold)

              if (combo.originalPrice && combo.originalPrice > combo.price) {
                Text(`￥${combo.originalPrice}`)
                  .fontSize(12)
                  .fontColor('#999999')
                  .decoration({ type: TextDecorationType.LineThrough })
                  .margin({ left: 4 })
              }
            }
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          if ((this.comboQuantities.get(combo.comboId) || 0) > 0) {
            Row() {
              Row() {
                Text('-')
                  .fontSize(16)
                  .fontColor(Color.White)
              }
              .width(24)
              .height(24)
              .backgroundColor('#9C27B0')
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                const currentQuantity = this.comboQuantities.get(combo.comboId) || 0;
                this.updateCartQuantity(combo.comboId, currentQuantity - 1);
              })

              Text(`${this.comboQuantities.get(combo.comboId) || 0}`)
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
              .backgroundColor('#9C27B0')
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                this.addToCart(combo);
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
            .backgroundColor('#9C27B0')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              this.addToCart(combo);
            })
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .onClick(() => {
        this.showComboDetail(combo);
      })
    }
    .width('92%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ left: 16, right: 16, bottom: 12 })
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  // 显示套餐详情
  private showComboDetail(combo: Combo): void {
    const params: ComboDetailParams = {
      comboId: combo.comboId,
      hideCart: false
    };
    this.restaurantPathStack.pushPathByName(PageName.COMBO_DETAIL, params);
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
            .backgroundColor('#9C27B0')
            .borderRadius(20)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)

            Text(`${this.cartTotalQuantity}`)
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor('#7B1FA2')
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
            .backgroundColor('#9C27B0')
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
            .fontColor('#9C27B0')
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
      source: 'combo',
      cartItems: this.cartViewModel.items
    };
    this.restaurantPathStack.pushPathByName(PageName.CHECKOUT, params);
  }
}
