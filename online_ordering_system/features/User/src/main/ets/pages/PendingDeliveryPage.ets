import { OrderViewModel } from '../viewmodel/OrderViewModel';
import { Order, OrderStatus } from 'common';
import { OrderItemComponent } from '../components/OrderItemComponent';
import { ToastComponent } from '../components/ToastComponent';
import {BreakpointType,BreakpointTypeEnum} from 'utils'
/**
 * 待收货订单页面
 */
@Component
export struct PendingDeliveryPage {
  @ObjectLink orderViewModel: OrderViewModel;
  @Consume('navStack') navStack: NavPathStack;
  //@State showRemindDialog: boolean = false;
  @State selectedOrder: Order | null = null;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;

  aboutToAppear() {
    this.loadPendingDeliveryOrders();
  }

  async loadPendingDeliveryOrders() {
    // 设置筛选条件为待收货状态（已付款、制作中、待取餐）
    // 这里我们需要加载多个状态的订单，所以不设置筛选条件，在显示时过滤
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
    .title('待收货')
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
      
      Text('待收货')
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
    } else if (this.getPendingDeliveryOrders().length === 0) {
      this.buildEmptyView()
    } else {
      List() {
        ForEach(this.orderViewModel.orders, (order: Order) => {
          if(order.status === OrderStatus.CONFIRMED || order.status === OrderStatus.ACCEPTED || order.status === OrderStatus.DELIVERING)
          {
            ListItem() {
              OrderItemComponent({
                order: order,
                mode: 'delivery',
                onRemind: () => {
                  this.handleRemindOrder(order);
                }
              })
            }
          }


        })
      }
      .lanes( new BreakpointType<number>({ sm: 1, md: 2, lg: 2 }).getValue(this.currentBreakpoint),
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
      
      Text('暂无待收货订单')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 16 })
      
      Text('订单正在制作中...')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
  }

  // 获取待收货订单（已付款、制作中、待取餐状态）
  getPendingDeliveryOrders(): Order[] {
    return this.orderViewModel.orders.filter(order => 
      order.status === OrderStatus.CONFIRMED || 
      order.status === OrderStatus.ACCEPTED ||
      order.status === OrderStatus.DELIVERING
    );
  }

  // 事件处理方法
  async loadMoreOrders() {
    await this.orderViewModel.loadMoreOrders();
  }

  async  handleRemindOrder(order: Order) {
    const success=await this.orderViewModel.remindOrder(order.orderId);
    if (success) {
      this.showToast('催单成功，商家会尽快处理');
    } else {
      this.showToast('催单失败，请重试');
    }
  }


  showToast(message: string) {
    ToastComponent.getInstance().show(message);
  }
}
