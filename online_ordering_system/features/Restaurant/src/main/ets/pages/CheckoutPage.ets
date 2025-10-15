import { promptAction } from '@kit.ArkUI';
import { CartItem } from '../viewModel/CartViewModel';
import { User } from 'common';
import { AppDataManager } from 'common';
import { OrderViewModel } from '../viewModel/OrderViewModel';
import { PageName, CheckoutParams, PaymentSuccessParams } from '../util/NavigationTypes';

@Component
export struct CheckoutPage {
  @Consume('restaurantPathStack') restaurantPathStack: NavPathStack;
  @State source: string = '';
  @State cartItems: CartItem[] = [];
  @State orderType: 'dine_in' | 'delivery' = 'dine_in';
  @State currentUser: User | null = null;
  @State deliveryTime: string = '';
  @State scheduledTime: string = '';
  @State isScheduled: boolean = false;
  @State showTimePicker: boolean = false;
  @State totalAmount: number = 0;
  @State discountAmount: number = 0;
  @State finalAmount: number = 0;
  private userListener?: (user: User | null) => void;
  private orderViewModel: OrderViewModel = new OrderViewModel();

  aboutToAppear() {
    // 从路径栈获取参数
    const params = this.restaurantPathStack.getParamByName(PageName.CHECKOUT)[0] as CheckoutParams;
    this.source = params?.source || '';
    this.cartItems = params?.cartItems || [];

    // 根据来源设置默认订单类型
    if (this.source === 'delivery') {
      this.orderType = 'delivery';
    } else {
      this.orderType = 'dine_in';
    }

    // 获取当前用户信息
    this.loadCurrentUser();

    // 初始化配送时间
    this.initializeDeliveryTime();

    this.calculateTotals();
  }

  // 加载当前用户信息
  private loadCurrentUser(): void {
    const appDataManager = AppDataManager.getInstance();
    this.currentUser = appDataManager.getCurrentUser();

    // 创建并保存监听器引用
    this.userListener = (user: User | null) => {
      this.currentUser = user;
    };

    // 添加用户状态监听
    appDataManager.addUserListener(this.userListener);
  }

  // 计算准备时间
  private calculatePreparationTime(): number {
    let maxPreparationTime = 0;
    this.cartItems.forEach(item => {
      const preparationTime = item.combo?.preparationTime || item.dish?.preparationTime || 0;
      maxPreparationTime = Math.max(maxPreparationTime, preparationTime);
    });
    return maxPreparationTime;
  }

  // 计算立即送达时间
  private calculateImmediateDeliveryTime(): string {
    const now = new Date();
    const preparationTime = this.calculatePreparationTime();

    // 计算送达时间（当前时间 + 准备时间 + 配送时间）
    const deliveryTime = new Date(now.getTime() + (preparationTime + 15) * 60 * 1000); // 15分钟配送时间

    const startTime = new Date(now.getTime() + preparationTime * 60 * 1000);
    const endTime = deliveryTime;

    const formatTime = (date: Date) => {
      const hours = date.getHours().toString().padStart(2, '0');
      const minutes = date.getMinutes().toString().padStart(2, '0');
      return `${hours}:${minutes}`;
    };

    return `立即送 立即送达(${formatTime(startTime)}-${formatTime(endTime)})`;
  }

  // 初始化配送时间
  private initializeDeliveryTime(): void {
    this.deliveryTime = this.calculateImmediateDeliveryTime();
  }

  // 显示时间选择器
  private showTimePickerDialog(): void {
    this.showTimePicker = true;
  }

  // 选择预约时间
  private selectScheduledTime(hour: number, minute: number): void {
    const now = new Date();
    const selectedTime = new Date(now.getFullYear(), now.getMonth(), now.getDate(), hour, minute);
    const preparationTime = this.calculatePreparationTime();
    const earliestDeliveryTime = new Date(now.getTime() + preparationTime * 60 * 1000);

    // 检查选择的时间是否早于最早送达时间
    if (selectedTime < earliestDeliveryTime) {
      // 显示错误提示
      promptAction.showToast({
        message: `最早送达时间为 ${earliestDeliveryTime.getHours()
          .toString()
          .padStart(2, '0')}:${earliestDeliveryTime.getMinutes().toString().padStart(2, '0')}`,
        duration: 2000
      });
      return;
    }

    const formatTime = (date: Date) => {
      const hours = date.getHours().toString().padStart(2, '0');
      const minutes = date.getMinutes().toString().padStart(2, '0');
      return `${hours}:${minutes}`;
    };

    this.scheduledTime = `预约送 ${formatTime(selectedTime)}送达`;
    this.isScheduled = true;
    this.showTimePicker = false;
  }

  build() {
    NavDestination() {
      Stack() {
      // 背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.restaurantPathStack.pop();
        })

      Column() {
        // 顶部拖拽条
        this.buildDragHandle()

        Scroll() {
          Column() {
            // 第1部分：订单类型选择卡片
            if (this.source === 'combo') {
              this.buildOrderTypeCard()
            }

            // 第2部分：配送信息卡片
            this.buildDeliveryCard()

            // 第3部分：购物车商品列表卡片
            this.buildCartItemsCard()

            Column().height(20)
          }
          .padding({ left: 16, right: 16 })
        }
        .layoutWeight(1)

        // 第4部分：支付卡片
        this.buildPaymentCard()
      }
      .width('100%')
      .height('80%')
      .backgroundColor('#1A1A1A')
      .borderRadius({ topLeft: 16, topRight: 16 })
      .position({ x: 0, y: '100%' })
      .translate({ y: '-80%' })
      .transition(TransitionEffect.translate({ y: 0 }).animation({ duration: 300, curve: Curve.EaseOut }))

      // 时间选择器
      if (this.showTimePicker) {
        this.buildTimePicker()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
    }
    .hideTitleBar(true)
  }

  // 顶部拖拽条
  @Builder
  buildDragHandle() {
    Column() {
      // 拖拽条
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

      // 标题
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
        // 堂食按钮
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

        // 外卖按钮
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
        // 配送地址
        Row() {
          Column() {
            Text(this.currentUser?.address || '请设置收货地址')
              .fontSize(16)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
              .alignSelf(ItemAlign.Start)

            Text(`${this.currentUser?.username || '用户'} ${this.currentUser?.phone || ''}`)
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 4 })
              .alignSelf(ItemAlign.Start)
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
          // 跳转到地址选择页面
        })
      }

      // 配送时间选择
      Column() {
        Row() {
          // 立即送
          Row() {
            Text(this.isScheduled ? this.deliveryTime : this.deliveryTime)
              .fontSize(16)
              .fontColor(this.isScheduled ? '#999999' : '#FF6B6B')
              .fontWeight(this.isScheduled ? FontWeight.Normal : FontWeight.Medium)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Start)

          // 选择状态图标
          Row() {
            if (!this.isScheduled) {
              Image($r('sys.media.ohos_ic_public_ok'))
                .width(16)
                .height(16)
                .fillColor('#FF6B6B')
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
          // 预约送
          Row() {
            Text(this.isScheduled ? this.scheduledTime : '预约送 选择时间 >')
              .fontSize(16)
              .fontColor(this.isScheduled ? '#FF6B6B' : '#999999')
              .fontWeight(this.isScheduled ? FontWeight.Medium : FontWeight.Normal)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Start)

          // 选择状态图标
          Row() {
            if (this.isScheduled) {
              Image($r('sys.media.ohos_ic_public_ok'))
                .width(16)
                .height(16)
                .fillColor('#FF6B6B')
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
          this.showTimePickerDialog();
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
      // 商品列表
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

  // 单个购物车商品
  @Builder
  buildCartItem(item: CartItem, _index: number) {
    Row() {
      // 商品图片
      Image(item.combo?.icon || item.dish?.image || '')
        .width(60)
        .height(60)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)

      Column() {
        // 商品名称和描述
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

        // 数量
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

      // 价格信息
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
      // 应付总额
      Row() {
        Text(`应付总额 ¥${this.finalAmount.toFixed(1)} 共减¥${this.discountAmount.toFixed(1)}`)
          .fontSize(16)
          .fontColor('#FF6B6B')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 16 })

      // 立即支付按钮
      Row() {
        Text('立即支付')
          .fontSize(18)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(48)
      .backgroundColor('#FF6B6B')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.handlePayment();
      })
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: 16
    })
    .backgroundColor('#2A2A2A')
    .borderRadius(12)
    .margin({ left: 16, right: 16, bottom: 16 })
  }

  // 计算总金额
  private calculateTotals(): void {
    this.totalAmount = this.cartItems.reduce((total, item) => {
      const price = item.combo?.price || item.dish?.price || 0;
      return total + (price * item.quantity);
    }, 0);

    // 计算折扣（假设75折）
    this.discountAmount = this.totalAmount * 0.25;
    this.finalAmount = this.totalAmount * 0.75;
  }

  // 处理支付
  private async handlePayment(): Promise<void> {
    if (!this.currentUser) {
      promptAction.showToast({
        message: '请先登录',
        duration: 2000
      });
      return;
    }

    if (this.cartItems.length === 0) {
      promptAction.showToast({
        message: '购物车为空',
        duration: 2000
      });
      return;
    }

    try {
      // 创建订单
      const deliveryAddress = this.orderType === 'delivery' ? this.currentUser.address : undefined;
      const estimatedDeliveryTime = this.isScheduled ? this.calculateScheduledDeliveryTime() : undefined;

      const orderResult = await this.orderViewModel.createOrder(
        this.currentUser.userId,
        this.cartItems,
        this.orderType,
        deliveryAddress,
        estimatedDeliveryTime
      );

      if (!orderResult.success || !orderResult.order) {
        promptAction.showToast({
          message: orderResult.error || '创建订单失败',
          duration: 2000
        });
        return;
      }

      // 支付订单
      const paymentSuccess = await this.orderViewModel.payOrder(orderResult.order.orderId);
      
      if (paymentSuccess) {
        promptAction.showToast({
          message: '支付成功！',
          duration: 2000
        });

        // 跳转到支付成功页面
        const paymentParams: PaymentSuccessParams = {
          orderId: orderResult.order.orderId,
          totalAmount: orderResult.order.finalAmount
        };
        this.restaurantPathStack.pushPathByName(PageName.PAYMENT_SUCCESS, paymentParams);
      } else {
        promptAction.showToast({
          message: '支付失败，请重试',
          duration: 2000
        });
      }
    } catch (error) {
      promptAction.showToast({
        message: '支付处理出错',
        duration: 2000
      });
    }
  }

  // 计算预约送达时间
  private calculateScheduledDeliveryTime(): number {
    if (!this.scheduledTime) return 0;
    
    const now = new Date();
    const timeMatch = this.scheduledTime.match(/(\d{2}):(\d{2})/);
    if (timeMatch) {
      const hour = parseInt(timeMatch[1]);
      const minute = parseInt(timeMatch[2]);
      const scheduledTime = new Date(now.getFullYear(), now.getMonth(), now.getDate(), hour, minute);
      return scheduledTime.getTime();
    }
    return 0;
  }

  // 时间选择器
  @Builder
  buildTimePicker() {
    Column() {
      // 背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showTimePicker = false;
        })

      // 时间选择器内容
      Column() {
        // 标题
        Row() {
          Text('选择送达时间')
            .fontSize(18)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 16, bottom: 16 })

        // 时间选择网格
        Grid() {
          ForEach(this.generateTimeSlots(), (timeSlot: string) => {
            GridItem() {
              Text(timeSlot)
                .fontSize(14)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Normal)
                .padding({
                  top: 8,
                  bottom: 8,
                  left: 12,
                  right: 12
                })
                .backgroundColor('#333333')
                .borderRadius(6)
                .onClick(() => {
                  const timeParts = timeSlot.split(':');
                  const hour = parseInt(timeParts[0]);
                  const minute = parseInt(timeParts[1]);
                  this.selectScheduledTime(hour, minute);
                })
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .width('100%')
      .backgroundColor('#2A2A2A')
      .borderRadius({ topLeft: 16, topRight: 16 })
      .position({ x: 0, y: '100%' })
      .translate({ y: '-50%' })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }

  // 生成时间选择槽
  private generateTimeSlots(): string[] {
    const timeSlots: string[] = [];
    const now = new Date();
    const preparationTime = this.calculatePreparationTime();
    const earliestHour = Math.ceil((now.getTime() + preparationTime * 60 * 1000) / (60 * 60 * 1000));

    // 生成当天剩余时间的时间槽（每30分钟一个）
    for (let hour = earliestHour; hour < 24; hour++) {
      for (let minute = 0; minute < 60; minute += 30) {
        const timeString = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
        timeSlots.push(timeString);
      }
    }

    return timeSlots.slice(0, 12);
  }

  // 页面销毁时清理监听器
  aboutToDisappear() {
    if (this.userListener) {
      const appDataManager = AppDataManager.getInstance();
      appDataManager.removeUserListener(this.userListener);
    }
  }
}
