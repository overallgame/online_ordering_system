import { promptAction } from '@kit.ArkUI';
import { Dish, CartItem, Category } from 'common';
import { DishViewModel } from '../viewModel/DishViewModel';
import { CartViewModel } from '../viewModel/CartViewModel';
import { LoadStatus } from '../util/DataState';
import { PageName } from '../util/NavigationTypes';
import { CheckoutPage } from './CheckoutPage';
import { CategoryTabsComponent } from '../view/CategoryTabsComponent';

@Component
export struct OnlineOrderPage {
  @Consume('restaurantPathStack') restaurantPathStack: NavPathStack;
  private viewModel: DishViewModel = new DishViewModel();
  @State categories: Category[] = [];
  @State @Watch('onSelectedCategoryChanged') selectedCategory: Category | null = null;
  @State dishes: Dish[] = [];
  @State allDishes: Dish[] = [];
  @State status: LoadStatus = LoadStatus.Idle;
  @State error?: string = undefined;
  @State isRefreshing: boolean = false;
  @State searchText: string = '';
  // 购物车状态
  private cartViewModel: CartViewModel = new CartViewModel('', '', 'online');
  @State isCartLoading: boolean = false;
  @State cartItems: CartItem[] = [];
  @State cartTotalQuantity: number = 0;
  @State cartTotalAmount: number = 0;
  @State dishQuantities: Map<string, number> = new Map();
  // 结算页状态
  @State showCheckout: boolean = false;

  aboutToAppear() {
    this.loadCategories();
    this.initializeCart();
  }

  aboutToDisappear() {
    this.cartViewModel.destroy();
  }

  private async loadCategories() {
    this.categories = await this.viewModel.loadCategories(1);
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

    this.allDishes = this.viewModel.state.data;
    this.dishes = this.allDishes;
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

    this.allDishes = this.viewModel.state.data;
    this.dishes = this.allDishes;
    this.status = this.viewModel.state.status;
    this.error = this.viewModel.state.error;
    this.isRefreshing = false;
    if (this.searchText.trim()) {
      this.filterDishes();
    }
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
    
    this.allDishes = this.viewModel.state.data;
    this.dishes = this.allDishes;
    this.status = this.viewModel.state.status;
    this.error = this.viewModel.state.error;
    
    // 如果有搜索条件，重新筛选
    if (this.searchText.trim()) {
      this.filterDishes();
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

  private async initializeCart() {
    try {
      this.cartViewModel.addListener((cart) => {
        this.cartItems = cart.items || [];
        this.cartTotalQuantity = cart.totalQuantity || 0;
        this.cartTotalAmount = cart.totalAmount || 0;

        const newQuantities = new Map<string, number>();
        this.cartItems.forEach((item: CartItem) => {
          if (item.dish && item.dish.dishId) {
            newQuantities.set(item.dish.dishId, item.quantity);
          }
        });
        this.dishQuantities = newQuantities;
      });
      
      // 初始化本地独立购物车
      const loadSuccess = await this.cartViewModel.loadCart();
      if (!loadSuccess) {
        console.warn('Failed to initialize local cart');
      }
      
      // 启动自动保存
      this.cartViewModel.startAutoSave();
    } catch (error) {
      console.error('Failed to initialize cart:', error);
      this.cartItems = [];
      this.cartTotalQuantity = 0;
      this.cartTotalAmount = 0;
    }
  }

  // 添加菜品到购物车
  private async addToCart(dishId: string): Promise<void> {
    if (!dishId) {
      console.error('Invalid dishId provided to addToCart');
      promptAction.showToast({
        message: '商品信息错误',
        duration: 2000
      });
      return;
    }
    
    if (this.isCartLoading) {
      return;
    }
    
    this.isCartLoading = true;
    try {
      const success = await this.cartViewModel.addItemById(parseInt(dishId));
      if (success) {
        promptAction.showToast({
          message: '已添加到购物车',
          duration: 1500
        });
      } else {
        promptAction.showToast({
          message: '添加失败，请重试',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Error adding dish to cart:', error);
      promptAction.showToast({
        message: '网络错误，请检查网络连接',
        duration: 2000
      });
    } finally {
      this.isCartLoading = false;
    }
  }

  // 从购物车移除菜品
  private async removeFromCart(dishId: string): Promise<void> {
    if (!dishId) {
      console.error('Invalid dishId provided to removeFromCart');
      promptAction.showToast({
        message: '商品信息错误',
        duration: 2000
      });
      return;
    }
    
    if (this.isCartLoading) {
      return;
    }
    
    this.isCartLoading = true;
    try {
      const success = await this.cartViewModel.removeItemById(parseInt(dishId));
      if (success) {
        promptAction.showToast({
          message: '已从购物车移除',
          duration: 1500
        });
      } else {
        promptAction.showToast({
          message: '移除失败，请重试',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Error removing dish from cart:', error);
      promptAction.showToast({
        message: '网络错误，请检查网络连接',
        duration: 2000
      });
    } finally {
      this.isCartLoading = false;
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          // 第一部分：顶部标题栏
          this.buildHeader()

          // 第二部分：分类栏
          this.buildCategoryTabs()

          // 第三部分：菜品列表
          this.buildDishList()

          // 第四部分：悬浮购物车栏
          this.buildFloatingCart()
        }
        .width('100%')
        .height('100%')

        // 结算页
        if (this.showCheckout) {
          this.buildCheckoutOverlay()
        }
      }
      .width('100%')
      .height('100%')
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
          Text('在线点餐')
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
      .margin({ left: 24, right: 24, bottom: 16 })
      .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    }
    .width('100%')
    .backgroundColor(Color.White)
  }

  // 第二部分：分类栏
  @Builder
  buildCategoryTabs() {
    CategoryTabsComponent({
      categories: this.categories,
      selectedCategory: $selectedCategory
    })
  }

  // 第三部分：菜品列表
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
        .alt($r('app.media.zwt'))
        .borderRadius(8)
        .margin({ right: 12 })
        .onClick(() => {
          this.restaurantPathStack.pushPathByName(PageName.DISH_DETAIL, dish);
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
              .backgroundColor('#FF6B6B')
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                this.removeFromCart(dish.dishId);
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
              .backgroundColor('#FF6B6B')
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                this.addToCart(dish.dishId);
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
            .backgroundColor('#FF6B6B')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              this.addToCart(dish.dishId);
            })
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .onClick(() => {
        this.restaurantPathStack.pushPathByName(PageName.DISH_DETAIL, dish);
      })
    }
    .width('92%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ left: 16, right: 16, bottom: 12 })
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
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
            .backgroundColor('#FF6B6B')
            .borderRadius(20)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)

            Text(`${this.cartTotalQuantity}`)
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor('#FF4444')
              .borderRadius(8)
              .padding({ left: 4, right: 4, top: 1, bottom: 1 })
              .position({ x: 28, y: -2 })
          }

          Blank()

          Text(`￥${(this.cartTotalAmount || 0).toFixed(2)}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ right: 16 })

          Button('去结算')
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#FF6B6B')
            .borderRadius(20)
            .width(80)
            .height(36)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.showCheckout = true;
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
    .width('92%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: -2 })
  }

  // 结算页覆盖层
  @Builder
  buildCheckoutOverlay() {
    CheckoutPage({
      sourceProp: 'online',
      cartItemsProp: this.cartViewModel.getItems(),
      cartViewModel: this.cartViewModel,
      showCheckout: $showCheckout
    })
  }
}
