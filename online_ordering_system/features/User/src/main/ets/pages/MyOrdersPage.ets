import { OrderViewModel } from '../viewmodel/OrderViewModel';
import { Order, OrderStatus ,PaymentMethod } from 'common';
import { OrderItemComponent } from '../components/OrderItemComponent';
import { ToastComponent } from '../components/ToastComponent';
import {BreakpointType,BreakpointTypeEnum} from 'utils'

/**
 * 我的订单页面
 */
@Component
export struct MyOrdersPage {
  @ObjectLink orderViewModel: OrderViewModel;
  @Consume('navStack') navStack: NavPathStack;
  @State isSimulating: boolean = false;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;



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
                this.handleCancelOrder(order);
              },
              onDelete: () => {
                this.handleDeleteOrder(order);
              },
              onPay: () => {
                this.handlePayOrder(order);
              },
              onRemind: () => {
                this.handleRemindOrder(order);
              },
              onRepeat: () => {
                this.handleRepeatOrder(order);
              }
            })
          }
        })
      }
      .lanes(
        new BreakpointType<number>({ sm: 1, md: 2, lg: 2 }).getValue(this.currentBreakpoint),
        new BreakpointType<number>({ sm: 0, md: 12, lg: 16 }).getValue(this.currentBreakpoint))
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
      Image($r('app.media.no_order'))
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

  handleDeleteOrder(order: Order) {
  }

  async  handlePayOrder(order: Order) {
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

  async  handleRemindOrder(order: Order) {
    const success=await this.orderViewModel.remindOrder(order.orderId);
    if (success) {
      this.showToast('催单成功，商家会尽快处理');
    } else {
      this.showToast('催单失败，请重试');
    }
  }

  handleRepeatOrder(order: Order) {
  }

  showToast(message: string) {
    ToastComponent.getInstance().show(message);
  }


}
