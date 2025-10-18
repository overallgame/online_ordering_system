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

      
      // 其他功能区域
      Column() {
        Text('更多功能即将上线...')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ top: 50 })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#F5F5F5')
    .margin({ top: 8 })
  }
}
