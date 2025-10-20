import { OrderViewModel } from '../viewmodel/OrderViewModel';
import { Order, OrderStatus, PaymentMethod } from 'common';
import { OrderItemComponent } from '../components/OrderItemComponent';
import { ToastComponent } from '../components/ToastComponent';

/**
 * 待付款订单页面
 */
@Component
export struct PendingPaymentPage {
  @Link orderViewModel: OrderViewModel;
  @Consume('navStack') navStack: NavPathStack;
  // @State showPayDialog: boolean = false;
  // @State showCancelDialog: boolean = false;
  // @State selectedOrder: Order | null = null;

  aboutToAppear() {
    this.loadPendingPaymentOrders();
  }

  async loadPendingPaymentOrders() {
    // 设置筛选条件为待付款状态
    this.orderViewModel.setStatusFilter(1); // 1表示待付款
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
    .title('待付款')
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
      
      Text('待付款')
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
    } else if (this.getPendingPaymentOrders().length === 0) {
      this.buildEmptyView()
    } else {
      List() {
        ForEach(this.orderViewModel.orders, (order: Order) => {
          if(order.status==OrderStatus.PENDING)
          {
            ListItem() {
              OrderItemComponent({
                order: order,
                mode: 'payment',
                onPay: () => {
                  this.handlePayOrder(order);
                },
                onCancel:()=>{
                  this.handleCancelOrder(order)
                }
              })
            }
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
      
      Text('暂无待付款订单')
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

  // 事件处理方法

  async loadMoreOrders() {
    await this.orderViewModel.loadMoreOrders();
  }

  async handlePayOrder(order: Order) {
    const response= await this.orderViewModel.payOrder(1,order);
    if(response.success)
    {
      this.orderViewModel.orders=[...this.orderViewModel.orders];
      this.showToast("支付成功");
    }
    else
    {
      this.showToast("支付失败");
    }


  }

  async handleCancelOrder(order: Order) {
    const response= await this.orderViewModel.cancelOrder(order.orderId);
    if(response)
    {
      this.orderViewModel.orders=[...this.orderViewModel.orders];
      this.showToast("取消成功");
    }
    else
    {
      this.showToast("取消失败");
    }
  }

  getPendingPaymentOrders(): Order[] {
    return this.orderViewModel.orders.filter(order =>
    order.status === OrderStatus.PENDING
    );
  }


  showToast(message: string) {
    ToastComponent.getInstance().show(message);
  }
}
