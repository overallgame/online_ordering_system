import { UserViewModel } from '../viewmodel/UserViewModel';

/**
 * 订单状态View组件
 */
@Component
export struct OrderStatusView {
  @ObjectLink userViewModel: UserViewModel;
  @Consume('navStack') navStack: NavPathStack;

  build() {
    Row() {
      // 待付款
      Column() {
        Image($r('app.media.pending_payment'))
          .width(40)
          .height(40)
        Text('待付款')
          .fontSize(14)
          .fontColor('#000000')
          .margin({ top: 8 })
      }
      .layoutWeight(1)
      .onClick(() => {
        if (this.navStack) {
          this.navStack.pushPath({ name: 'PendingPaymentPage' });
        } else {
          console.error("navStack is not initialized");
        }


      })
      
      // 我的订单
      Column() {
        Image($r('app.media.my_order'))
          .width(40)
          .height(40)
        Text('我的订单')
          .fontSize(14)
          .fontColor('#000000')
          .margin({ top: 8 })
      }
      .layoutWeight(1)
      .onClick(() => {
        if (this.navStack) {
          this.navStack.pushPath({ name: 'MyOrdersPage' });
        } else {
          console.error("navStack is not initialized");
        }
      })
      
      // 待收货
      Column() {
        Image($r('app.media.pending_delivery'))
          .width(40)
          .height(40)
        Text('待收货')
          .fontSize(14)
          .fontColor('#000000')
          .margin({ top: 8 })
      }
      .layoutWeight(1)
      .onClick(() => {
        if (this.navStack) {
          this.navStack.pushPath({ name: 'PendingDeliveryPage' });
        } else {
          console.error("navStack is not initialized");
        }

      })
      
      // 待评价
      Column() {
        Image($r('app.media.pending_review'))
          .width(40)
          .height(40)
        Text('待评价')
          .fontSize(14)
          .fontColor('#000000')
          .margin({ top: 8 })
      }
      .layoutWeight(1)
      .onClick(() => {

      })
    }
    .width('100%')
    .height(80)
    .backgroundColor('#FFFFFF')
    .padding({ top: 16, bottom: 16 })
    .justifyContent(FlexAlign.SpaceEvenly)
  }
}
