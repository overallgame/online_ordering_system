import { UserViewModel } from '../viewmodel/UserViewModel';

/**
 * 主内容View组件
 */
@Component
export struct MainContentView {
  @ObjectLink userViewModel: UserViewModel;
  @Consume('navStack') navStack: NavPathStack;

  build() {
    Column() {
      // 功能卡片区域
      Column() {
        // 常用功能标题
        Row() {
          Text('常用功能')
            .fontSize(18)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16, top: 20, bottom: 16 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        
        // 功能卡片网格
        Column() {
          // 第一行功能
          Row() {
            // 收藏夹
            Column() {
              Stack() {
                Circle()
                  .width(50)
                  .height(50)
                  .fill('#FF9F43')
                  .opacity(0.1)
                
                Image($r('app.media.like')) // 临时使用现有图标
                  .width(30)
                  .height(30)
                  .fillColor('#FF9F43')
              }
              .margin({ bottom: 8 })
              
              Text('收藏夹')
                .fontSize(14)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .padding({ top: 20, bottom: 20 })
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ right: 8 })
            .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })
            .onClick(() => {
              // 收藏夹功能
            })
            
            // 优惠券
            Column() {
              Stack() {
                Circle()
                  .width(50)
                  .height(50)
                  .fill('#6C5CE7')
                  .opacity(0.1)
                
                Image($r('app.media.preference')) // 临时使用现有图标
                  .width(30)
                  .height(30)
                  .fillColor('#6C5CE7')
              }
              .margin({ bottom: 8 })
              
              Text('优惠券')
                .fontSize(14)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .padding({ top: 20, bottom: 20 })
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ left: 8 })
            .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })
            .onClick(() => {
              // 优惠券功能
            })
          }
          .width('100%')
          .margin({ bottom: 12 })
          
          // 第二行功能
          Row() {
            // 地址管理
            Column() {
              Stack() {
                Circle()
                  .width(50)
                  .height(50)
                  .fill('#00B894')
                  .opacity(0.1)
                
                Image($r('app.media.pending_delivery')) // 临时使用现有图标
                  .width(30)
                  .height(30)
                  .fillColor('#00B894')
              }
              .margin({ bottom: 8 })
              
              Text('地址管理')
                .fontSize(14)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .padding({ top: 20, bottom: 20 })
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ right: 8 })
            .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })
            .onClick(() => {
              // 地址管理功能
            })
            
            // 客服中心
            Column() {
              Stack() {
                Circle()
                  .width(50)
                  .height(50)
                  .fill('#E17055')
                  .opacity(0.1)
                
                Image($r('app.media.serving')) // 临时使用现有图标
                  .width(30)
                  .height(30)
                  .fillColor('#E17055')
              }
              .margin({ bottom: 8 })
              
              Text('客服中心')
                .fontSize(14)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .padding({ top: 20, bottom: 20 })
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ left: 8 })
            .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })
            .onClick(() => {
              // 客服中心功能
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      
      // 空状态提示区域
      Column() {
        Stack() {
          Circle()
            .width(80)
            .height(80)
            .fill('#F8F9FA')
          
          Image($r('app.media.pending_review'))
            .width(32)
            .height(32)
            .fillColor('#ADB5BD')
        }
        .margin({ bottom: 16 })
        
        Text('更多功能即将上线')
          .fontSize(16)
          .fontColor('#6C757D')
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })
        
        Text('敬请期待更多精彩功能')
          .fontSize(14)
          .fontColor('#ADB5BD')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ top: 40, bottom: 40 })
      .layoutWeight(1)
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#F8F9FA')
  }
}
