import { promptAction } from '@kit.ArkUI';
import { CartItem } from 'common';
import { User } from 'common';
import { AppDataManager } from 'common';
import { OrderViewModel } from '../viewModel/OrderViewModel';
import { CartViewModel } from '../viewModel/CartViewModel';
import { AddressViewModel } from '../viewModel/AddressViewModel';
import { AddressBook } from 'common/src/main/ets/model/AddressBook';
import { PageName, PaymentSuccessParams } from '../util/NavigationTypes';
import { TimePickerComponent } from '../view/TimePickerComponent';
import { TimeUtils } from '../util/TimeUtils';

@Component
export struct CheckoutPage {
  @Prop sourceProp?: string = '';
  @Prop cartItemsProp?: CartItem[] = [];
  @Prop cartViewModel: CartViewModel;
  @Link showCheckout: boolean;

  @Consume('restaurantPathStack') restaurantPathStack: NavPathStack;
  @State source: string = '';
  @State cartItems: CartItem[] = [];
  @State orderType: 'dine_in' | 'delivery' = 'dine_in';
  @State totalAmount: number = 0;
  @State discountAmount: number = 0;
  @State finalAmount: number = 0;

  @State deliveryTime: string = '';
  @State scheduledTime: string = '';
  @State isScheduled: boolean = false;
  @State showTimePicker: boolean = false;

  @State currentUser: User | null = null;

  @State isAddressLoading: boolean = false;
  @State currentAddress: AddressBook | null = null;
  private addressViewModel: AddressViewModel = new AddressViewModel();
  private orderViewModel: OrderViewModel = new OrderViewModel();

  aboutToAppear() {
    if (this.sourceProp !== undefined && this.cartItemsProp !== undefined) {
      this.source = this.sourceProp;
      this.cartItems = this.cartItemsProp;
    }

    if (this.source === 'delivery') {
      this.orderType = 'delivery';
    } else {
      this.orderType = 'dine_in';
    }
    this.loadCurrentUser();
    this.loadCartData();
    this.loadDefaultAddress();
    this.initializeDeliveryTime();
  }

  // 加载当前用户信息
  private loadCurrentUser(): void {
    const appDataManager = AppDataManager.getInstance();
    this.currentUser = appDataManager.getCurrentUser();
    appDataManager.addUserListener((user: User | null) => {
      this.currentUser = user;
    });
  }

  // 加载购物车数据
  private async loadCartData(): Promise<void> {
    try {
      if (this.cartViewModel) {
        this.cartViewModel.addListener((cart) => {
          this.cartItems = cart.items;
          this.calculateTotals();
        });

        await this.cartViewModel.loadCart();
      }
    } catch (error) {
      console.error('Failed to load cart data:', error);
    }
  }

  // 加载默认地址
  private async loadDefaultAddress(): Promise<void> {
    this.isAddressLoading = true;

    try {
      this.currentAddress = await this.addressViewModel.loadDefaultAddress();
    } catch (error) {
      console.error('Failed to load default address:', error);
    } finally {
      this.isAddressLoading = false;
    }
  }

  // 计算立即送达时间
  private initializeDeliveryTime(): void {
    this.deliveryTime = TimeUtils.calculateImmediateDeliveryTime(this.cartItems);
  }

  // 计算总金额
  private calculateTotals(): void {
    this.totalAmount = this.cartItems.reduce((total: number, item: CartItem) => {
      const price = item.combo?.price || item.dish?.price || 0;
      const finalPrice = (item.combo?.originalPrice && item.combo.originalPrice > price)
        ? price : (item.dish?.originalPrice && item.dish.originalPrice > price) ? price : price;
      return total + (finalPrice * item.quantity);
    }, 0);

    this.discountAmount = this.totalAmount * 0.25;
    this.finalAmount = this.totalAmount * 0.75;
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showCheckout = false;
        })

      Column() {
        this.buildDragHandle()

        Scroll() {
          Column() {
            if (this.source === 'combo') {
              this.buildOrderTypeCard()
            }
            this.buildDeliveryCard()
            this.buildCartItemsCard()
            Column().height(20)
          }
          .padding({ left: 16, right: 16 })
        }
        .layoutWeight(1)

        this.buildPaymentCard()
      }
      .width('100%')
      .height('80%')
      .backgroundColor('#1A1A1A')
      .borderRadius({ topLeft: 16, topRight: 16 })
      .position({ x: 0, y: '100%' })
      .translate({ y: '-100%' })
      .transition(TransitionEffect.translate({ y: 0 }).animation({ duration: 300, curve: Curve.EaseOut }))

      if (this.showTimePicker) {
        TimePickerComponent({
          showTimePicker: $showTimePicker,
          scheduledTime: $scheduledTime,
          isScheduled: $isScheduled,
          cartItems: this.cartItems,
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
  }

  // 顶部拖拽条
  @Builder
  buildDragHandle() {
    Column() {
      Row() {
        Column()
          .width(40)
          .height(4)
          .backgroundColor('#666666')
          .borderRadius(2)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 8, bottom: 8 })

      Text('确认订单')
        .fontSize(18)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 16 })
    }
    .width('100%')
    .backgroundColor('#1A1A1A')
  }

  // 订单类型选择卡片
  @Builder
  buildOrderTypeCard() {
    Column() {
      Row() {
        Row() {
          Text('堂食')
            .fontSize(16)
            .fontColor(this.orderType === 'dine_in' ? Color.White : '#999999')
            .fontWeight(this.orderType === 'dine_in' ? FontWeight.Medium : FontWeight.Normal)
        }
        .width('50%')
        .height(48)
        .backgroundColor(this.orderType === 'dine_in' ? '#FF6B6B' : '#333333')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.orderType = 'dine_in';
        })

        Row() {
          Text('外卖')
            .fontSize(16)
            .fontColor(this.orderType === 'delivery' ? Color.White : '#999999')
            .fontWeight(this.orderType === 'delivery' ? FontWeight.Medium : FontWeight.Normal)
        }
        .width('50%')
        .height(48)
        .backgroundColor(this.orderType === 'delivery' ? '#FF6B6B' : '#333333')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.orderType = 'delivery';
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#2A2A2A')
    .borderRadius(12)
    .margin({ top: 16 })
  }

  // 配送信息卡片
  @Builder
  buildDeliveryCard() {
    Column() {
      if (this.orderType === 'delivery') {
        Row() {
          Column() {
            if (this.isAddressLoading) {
              Row() {
                LoadingProgress()
                  .width(16)
                  .height(16)
                Text(' 正在加载地址...')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ left: 8 })
              }
              .alignSelf(ItemAlign.Start)
            } else {
              Text(this.currentAddress?.getFullAddress() || '请设置收货地址')
                .fontSize(16)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(this.currentAddress?.getContactInfo() ||
                `${this.currentUser?.username || '用户'} ${this.currentUser?.phone || ''}`)
                .fontSize(14)
                .fontColor('#999999')
                .margin({ top: 4 })
                .alignSelf(ItemAlign.Start)
            }
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Image($r('sys.media.ohos_ic_public_arrow_right'))
            .width(16)
            .height(16)
            .fillColor('#999999')
        }
        .width('100%')
        .padding({ top: 16, bottom: 16 })
        .onClick(() => {
          promptAction.showToast({ message: '跳转到地址管理页面', duration: 1500 });
        })
      }

      Column() {
        Row() {
          Row() {
            Text(this.deliveryTime)
              .fontSize(16)
              .fontColor(this.isScheduled ? '#999999' : '#FF6B6B')
              .fontWeight(this.isScheduled ? FontWeight.Normal : FontWeight.Medium)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Start)

          Row() {
            if (!this.isScheduled) {
              Stack() {
                Circle()
                  .width(16)
                  .height(16)
                  .fill('#FF6B6B')

                Image($r('sys.media.ohos_ic_public_ok'))
                  .width(12)
                  .height(12)
                  .fillColor(Color.White)
              }
              .width(16)
              .height(16)
            } else {
              Circle()
                .width(16)
                .height(16)
                .stroke('#999999')
                .strokeWidth(1)
            }
          }
          .width(20)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .padding({ top: 16, bottom: 16 })
        .onClick(() => {
          this.isScheduled = false;
        })

        Divider()
          .color('#333333')
          .strokeWidth(1)

        Row() {
          Row() {
            Text(this.isScheduled ? TimeUtils.formatTimeDisplayString(this.scheduledTime) : '预约送 选择时间 >')
              .fontSize(16)
              .fontColor(this.isScheduled ? '#FF6B6B' : '#999999')
              .fontWeight(this.isScheduled ? FontWeight.Medium : FontWeight.Normal)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Start)

          Row() {
            if (this.isScheduled) {
              Stack() {
                Circle()
                  .width(16)
                  .height(16)
                  .fill('#FF6B6B')

                Image($r('sys.media.ohos_ic_public_ok'))
                  .width(12)
                  .height(12)
                  .fillColor(Color.White)
              }
              .width(16)
              .height(16)
            } else {
              Circle()
                .width(16)
                .height(16)
                .stroke('#999999')
                .strokeWidth(1)
            }
          }
          .width(20)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .padding({ top: 16, bottom: 16 })
        .onClick(() => {
          this.showTimePicker = true;
        })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#2A2A2A')
    .borderRadius(12)
    .margin({ top: 16 })
  }

  // 购物车商品列表卡片
  @Builder
  buildCartItemsCard() {
    Column() {
      ForEach(this.cartItems, (item: CartItem, index: number) => {
        this.buildCartItem(item, index)
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#2A2A2A')
    .borderRadius(12)
    .margin({ top: 16 })
  }

  @Builder
  buildCartItem(item: CartItem, _index: number) {
    Row() {
      Image(item.combo?.icon || item.dish?.image || '')
        .width(60)
        .height(60)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)

      Column() {
        Text(item.combo?.name || item.dish?.name || '')
          .fontSize(14)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .alignSelf(ItemAlign.Start)

        Text(item.combo?.description || item.dish?.description || '')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .alignSelf(ItemAlign.Start)

        Row() {
          Text(`x${item.quantity}`)
            .fontSize(12)
            .fontColor('#999999')
        }
        .margin({ top: 4 })
        .alignSelf(ItemAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      Column() {
        Text(`¥${(item.combo?.price || item.dish?.price || 0).toFixed(1)}`)
          .fontSize(14)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)

        if ((item.combo?.originalPrice && item.combo.originalPrice > item.combo.price) ||
          (item.dish?.originalPrice && item.dish.originalPrice > item.dish.price)) {
          Text(`优惠后 ¥${((item.combo?.price || item.dish?.price || 0) * 0.75).toFixed(1)}`)
            .fontSize(12)
            .fontColor('#FF6B6B')
            .margin({ top: 2 })
        }
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .alignItems(VerticalAlign.Top)
  }

  // 支付卡片
  @Builder
  buildPaymentCard() {
    Column() {
      Row() {
        Text(`应付总额 ¥${this.finalAmount.toFixed(1)} 共减¥${this.discountAmount.toFixed(1)}`)
          .fontSize(16)
          .fontColor('#FF6B6B')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 16 })

      Row() {
        Row() {
          Text('生成订单')
            .fontSize(16)
            .fontColor('#FF6B6B')
            .fontWeight(FontWeight.Medium)
        }
        .width('48%')
        .height(48)
        .backgroundColor('#2A2A2A')
        .borderRadius(8)
        .border({ width: 1, color: '#FF6B6B' })
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.handleCreateOrder(false);
        })

        Row() {
          Text('立即结算')
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
        .width('48%')
        .height(48)
        .backgroundColor('#FF6B6B')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.handleCreateOrder(true);
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#2A2A2A')
    .borderRadius(12)
    .margin({ left: 16, right: 16, bottom: 16 })
  }

  // 处理订单创建
  private async handleCreateOrder(isPaid: boolean): Promise<void> {
    if (!this.currentUser) {
      promptAction.showToast({ message: '请先登录', duration: 2000 });
      return;
    }
    if (this.cartItems.length === 0) {
      promptAction.showToast({ message: '购物车为空', duration: 2000 });
      return;
    }
    try {
      const estimatedDeliveryTime =
        this.isScheduled ? TimeUtils.calculateScheduledDeliveryTimestamp(this.scheduledTime) :
        TimeUtils.calculateScheduledDeliveryTimestamp(this.deliveryTime);
      const orderResult = await this.orderViewModel.createOrder(
        this.cartItems,
        this.orderType,
        this.currentAddress!!.id,
        estimatedDeliveryTime,
      );
      if (!orderResult.success || !orderResult.order) {
        promptAction.showToast({ message: orderResult.error || '创建订单失败', duration: 2000 });
        return;
      }

      if (isPaid) {
        const paymentResult = await this.orderViewModel.payOrder(orderResult.order.orderNumber, 0);
        if (paymentResult.success) {
          promptAction.showToast({ message: '订单创建成功并已支付！', duration: 2000 });
          await this.cartViewModel.clearCart();
          const paymentParams: PaymentSuccessParams = {
            orderId: orderResult.order.orderId,
            totalAmount: orderResult.order.finalAmount
          };
          this.showCheckout = false;
          setTimeout(() => {
            this.restaurantPathStack.pushPathByName(PageName.PAYMENT_SUCCESS, paymentParams);
          }, 300);
        } else {
          promptAction.showToast({ message: paymentResult.error || '支付失败', duration: 2000 });
          this.showCheckout = false;
        }
      } else {
        promptAction.showToast({ message: '订单创建成功，请稍后支付！', duration: 2000 });
        await this.cartViewModel.clearCart();
        setTimeout(() => {
          this.showCheckout = false
        }, 300);
      }
    } catch (error) {
      console.error('Order processing error:', error);
      promptAction.showToast({ message: '订单处理出错', duration: 2000 });
    }
  }
}