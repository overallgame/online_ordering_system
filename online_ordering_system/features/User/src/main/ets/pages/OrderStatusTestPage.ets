import { OrderViewModel } from '../viewmodel/OrderViewModel';
import { Order, OrderStatus } from 'common';
import { OrderItemComponent } from '../components/OrderItemComponent';
import { ToastComponent } from '../components/ToastComponent';
import { OrderStatusSimulator } from '../service/OrderStatusSimulator';

/**
 * 订单状态测试页面 - 用于测试订单状态实时更新功能
 */
@Component
export struct OrderStatusTestPage {
  @Link orderViewModel: OrderViewModel;
  @Consume('navStack') navStack: NavPathStack;
  @State isSimulating: boolean = false;
  @State selectedOrder: Order | null = null;

  aboutToAppear() {
    this.loadOrders();
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
        this.buildTopBar()
        
        // 控制面板
        this.buildControlPanel()
        
        // 订单列表
        this.buildOrderList()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('订单状态测试')
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
      
      Text('订单状态测试')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      Button('刷新')
        .fontSize(12)
        .fontColor('#FFFFFF')
        .backgroundColor('#4CAF50')
        .borderRadius(4)
        .height(28)
        .padding({ left: 8, right: 8 })
        .onClick(() => {
          this.refreshOrders();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildControlPanel() {
    Column() {
      // 模拟控制
      Row() {
        Button(this.isSimulating ? '停止模拟' : '开始模拟')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor(this.isSimulating ? '#FF6B35' : '#2196F3')
          .borderRadius(6)
          .height(36)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.toggleSimulation();
          })

        Button('手动测试')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF9800')
          .borderRadius(6)
          .height(36)
          .padding({ left: 16, right: 16 })
          .margin({ left: 12 })
          .onClick(() => {
            this.manualTest();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 16 })

      // 状态说明
      Text('模拟说明：每10秒随机选择一个订单，按 PENDING → CONFIRMED → PREPARING → READY → COMPLETED 的顺序变化状态')
        .fontSize(12)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .margin({ bottom: 8 })
  }

  @Builder
  buildOrderList() {
    if (this.orderViewModel.orders.length === 0) {
      this.buildEmptyView()
    } else {
      List() {
        ForEach(this.orderViewModel.orders, (order: Order) => {
          ListItem() {
            OrderItemComponent({
              order: order,
              mode: 'all',
              onCancel: () => {
                this.testStatusChange(order, OrderStatus.CANCELLED);
              },
              onDelete: () => {
                this.testStatusChange(order, OrderStatus.CANCELLED);
              },
              onPay: () => {
                this.testStatusChange(order, OrderStatus.CONFIRMED);
              },
              onRemind: () => {
                this.testStatusChange(order, OrderStatus.PREPARING);
              },
              onRepeat: () => {
                this.testStatusChange(order, OrderStatus.PENDING);
              }
            })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 8 })
    }
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
      
      Text('请先加载订单数据')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
  }

  // 事件处理方法
  async loadOrders() {
    await this.orderViewModel.loadOrders(true);
  }

  async refreshOrders() {
    await this.orderViewModel.refreshOrders();
  }

  // 切换状态模拟
  toggleSimulation() {
    if (this.isSimulating) {
      this.stopSimulation();
    } else {
      this.startSimulation();
    }
  }

  // 开始状态模拟
  startSimulation() {
    if (this.orderViewModel.orders.length === 0) {
      this.showToast('请先加载订单数据');
      return;
    }

    const orderIds = this.orderViewModel.orders.map(order => order.orderId);
    OrderStatusSimulator.getInstance().startSimulation(orderIds);
    this.isSimulating = true;
    this.showToast('开始模拟订单状态变化');
  }

  // 停止状态模拟
  stopSimulation() {
    OrderStatusSimulator.getInstance().stopSimulation();
    this.isSimulating = false;
    this.showToast('停止模拟订单状态变化');
  }

  // 手动测试状态变化
  manualTest() {
    if (this.orderViewModel.orders.length === 0) {
      this.showToast('请先加载订单数据');
      return;
    }

    // 随机选择一个订单并改变状态
    const randomIndex = Math.floor(Math.random() * this.orderViewModel.orders.length);
    const order = this.orderViewModel.orders[randomIndex];
    
    const statuses = [OrderStatus.PENDING, OrderStatus.CONFIRMED, OrderStatus.PREPARING, OrderStatus.READY, OrderStatus.COMPLETED];
    const randomStatus = statuses[Math.floor(Math.random() * statuses.length)];
    
    this.testStatusChange(order, randomStatus);
  }

  // 测试状态变化
  testStatusChange(order: Order, newStatus: OrderStatus) {
    OrderStatusSimulator.getInstance().triggerStatusChange(order.orderId, newStatus);
    this.showToast(`订单 ${order.orderId} 状态已更新为 ${newStatus}`);
  }

  showToast(message: string) {
    ToastComponent.getInstance().show(message);
  }
}
