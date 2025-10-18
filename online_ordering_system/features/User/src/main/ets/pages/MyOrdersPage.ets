import { OrderViewModel } from '../viewmodel/OrderViewModel';
import { Order, OrderStatus ,PaymentMethod } from 'common';
import { OrderItemComponent } from '../components/OrderItemComponent';
import { ToastComponent } from '../components/ToastComponent';


/**
 * 我的订单页面
 */
@Component
export struct MyOrdersPage {
  @ObjectLink orderViewModel: OrderViewModel;
  @Consume('navStack') navStack: NavPathStack;
  @State showCancelDialog: boolean = false;
  @State showDeleteDialog: boolean = false;
  @State showPayDialog: boolean = false;
  @State showRemindDialog: boolean = false;
  @State showRepeatDialog: boolean = false;
  @State selectedOrder: Order | null = null;
  @State isSimulating: boolean = false;

  aboutToAppear() {
    this.loadOrders();
  }

  async loadOrders() {
    await this.orderViewModel.loadOrders(true);
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
        this.buildTopBar()
        
        // 订单列表
        this.buildOrderList()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('所有订单')
    .hideTitleBar(true)
  }

  @Builder
  buildTopBar() {
    Row() {
      Image($r('app.media.back'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.navStack.pop();
        })
      
      Text('我的订单')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)


    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
  }



  @Builder
  buildOrderList() {
    if (this.orderViewModel.isRefreshing) {
      this.buildLoadingView()
    } else if (this.orderViewModel.orders.length === 0) {
      this.buildEmptyView()
    } else {
      List() {
        ForEach(this.orderViewModel.orders, (order: Order) => {
          ListItem() {
            OrderItemComponent({
              order: order,
              mode: 'all',
              onCancel: () => {
                this.showCancelOrderDialog(order);
              },
              onDelete: () => {
                this.showDeleteOrderDialog(order);
              },
              onPay: () => {
                this.showPayOrderDialog(order);
              },
              onRemind: () => {
                this.showRemindOrderDialog(order);
              },
              onRepeat: () => {
                this.showRepeatOrderDialog(order);
              }
            })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 8 })
      .onReachEnd(() => {
        this.loadMoreOrders();
      })
    }
  }

  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#4CAF50')
      
      Text('加载中...')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 12 })
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildEmptyView() {
    Column() {
      Image($r('app.media.setting'))
        .width(120)
        .height(120)
        .opacity(0.6)
      
      Text('暂无订单')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 16 })
      
      Text('快去下单吧~')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
  }



  async loadMoreOrders() {
    await this.orderViewModel.loadMoreOrders();
  }

  async showCancelOrderDialog(order: Order) {
    this.selectedOrder = order;
    this.showCancelDialog = true;
    await this.orderViewModel.cancelOrder(order.orderId);
  }

  showDeleteOrderDialog(order: Order) {
    this.selectedOrder = order;
    this.showDeleteDialog = true;

  }

  async  showPayOrderDialog(order: Order) {
    this.selectedOrder = order;
    this.showPayDialog = true;
    await this.orderViewModel.payOrder(order.totalAmount.toString(),1,order);
  }

  async  showRemindOrderDialog(order: Order) {
    this.selectedOrder = order;
    this.showRemindDialog = true;
    const success=await this.orderViewModel.remindOrder(order.orderId);
    if (success) {
      this.showToast('催单成功，商家会尽快处理');
    } else {
      this.showToast('催单失败，请重试');
    }
  }

  showRepeatOrderDialog(order: Order) {
    this.selectedOrder = order;
    this.showRepeatDialog = true;
  }

  // async handleCancelOrder() {
  //   if (!this.selectedOrder) return;
  //
  //   const success = await this.orderViewModel.cancelOrder(this.selectedOrder.orderId);
  //   this.showCancelDialog = false;
  //
  //   if (success) {
  //     this.showToast('订单已取消');
  //   } else {
  //     this.showToast('取消订单失败，请重试');
  //   }
  // }

  // async handleDeleteOrder() {
  //   if (!this.selectedOrder) return;
  //
  //   const success = await this.orderViewModel.deleteOrder(this.selectedOrder.orderId);
  //   this.showDeleteDialog = false;
  //
  //   if (success) {
  //     this.showToast('订单已删除');
  //   } else {
  //     this.showToast('删除订单失败，请重试');
  //   }
  // }

  // async handlePayOrder() {
  //   if (!this.selectedOrder) return;
  //
  //   const result = await this.orderViewModel.payOrder(this.selectedOrder.orderId, 1); // 1表示微信支付
  //   this.showPayDialog = false;
  //
  //   if (result.success) {
  //     this.showToast('支付成功');
  //     if (result.paymentUrl) {
  //       // 这里可以打开支付页面
  //       console.log('支付URL:', result.paymentUrl);
  //     }
  //   } else {
  //     this.showToast('支付失败，请重试');
  //   }
  // }

  async handleRemindOrder() {
    if (!this.selectedOrder) return;
    
    const success = await this.orderViewModel.remindOrder(this.selectedOrder.orderId);
    this.showRemindDialog = false;
    
    if (success) {
      this.showToast('催单成功，商家会尽快处理');
    } else {
      this.showToast('催单失败，请重试');
    }
  }

  async handleRepeatOrder() {
    if (!this.selectedOrder) return;
    
    const success = await this.orderViewModel.repeatOrder(this.selectedOrder.orderId);
    this.showRepeatDialog = false;
    
    if (success) {
      this.showToast('再来一单成功，已加入购物车');
    } else {
      this.showToast('再来一单失败，请重试');
    }
  }

  showToast(message: string) {
    ToastComponent.getInstance().show(message);
  }


}
