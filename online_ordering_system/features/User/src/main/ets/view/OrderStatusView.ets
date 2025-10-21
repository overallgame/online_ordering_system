import { UserViewModel } from '../viewmodel/UserViewModel';

/**
 * 订单状态View组件
 */
@Component
export struct OrderStatusView {
  @ObjectLink userViewModel: UserViewModel;
  @Consume('navStack') navStack: NavPathStack;

  build() {
    Column() {
      Row() {
        // 待付款
        Column() {
          Stack() {
            Circle()
              .width(50)
              .height(50)
              .fill('#FF6B6B')
              .opacity(0.1)
            
            Image($r('app.media.pending_payment'))
              .width(30)
              .height(30)
              .fillColor('#FF6B6B')
          }
          .alignContent(Alignment.Center)
          .margin({ bottom: 8 })
          
          Text('待付款')
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 16, bottom: 16 })
        .onClick(() => {
          if (this.navStack) {
            this.navStack.pop();
            this.navStack.pushPath({ name: 'PendingPaymentPage' });
          } else {
            console.error("navStack is not initialized");
          }
        })
        
        // 分隔线
        Divider()
          .vertical(true)
          .height(40)
          .color('#E5E5E5')
          .strokeWidth(1)
        
        // 我的订单
        Column() {
          Stack() {
            Circle()
              .width(50)
              .height(50)
              .fill('#4ECDC4')
              .opacity(0.1)
            
            Image($r('app.media.my_order'))
              .width(30)
              .height(30)
              .fillColor('#4ECDC4')
          }
          .alignContent(Alignment.Center)
          .margin({ bottom: 8 })
          
          Text('我的订单')
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 16, bottom: 16 })
        .onClick(() => {
          if (this.navStack) {
            this.navStack.pop();
            this.navStack.pushPath({ name: 'MyOrdersPage' });
          } else {
            console.error("navStack is not initialized");
          }
        })
        
        // 分隔线
        Divider()
          .vertical(true)
          .height(40)
          .color('#E5E5E5')
          .strokeWidth(1)
        
        // 待收货
        Column() {
          Stack() {
            Circle()
              .width(50)
              .height(50)
              .fill('#45B7D1')
              .opacity(0.1)
            
            Image($r('app.media.pending_delivery'))
              .width(30)
              .height(30)
              .fillColor('#45B7D1')
          }
          .alignContent(Alignment.Center)
          .margin({ bottom: 8 })
          
          Text('待收货')
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 16, bottom: 16 })
        .onClick(() => {
          if (this.navStack) {
            this.navStack.pop();
            this.navStack.pushPath({ name: 'PendingDeliveryPage' });
          } else {
            console.error("navStack is not initialized");
          }
        })
        
        // 分隔线
        Divider()
          .vertical(true)
          .height(40)
          .color('#E5E5E5')
          .strokeWidth(1)
        
        // 待评价
        Column() {
          Stack() {
            Circle()
              .width(50)
              .height(50)
              .fill('#96CEB4')
              .opacity(0.1)
            
            Image($r('app.media.pending_review'))
              .width(30)
              .height(30)
              .fillColor('#96CEB4')
          }
          .alignContent(Alignment.Center)
          .margin({ bottom: 8 })
          
          Text('待评价')
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 16, bottom: 16 })
        .onClick(() => {
          // 待评价功能暂未实现
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
    .shadow({ radius: 8, color: '#00000010', offsetX: 0, offsetY: 2 })
    .padding({ left: 8, right: 8 })
  }
}
