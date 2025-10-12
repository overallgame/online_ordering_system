import { UserViewModel } from '../viewmodel/UserViewModel';

/**
 * 主内容View组件
 */
@Component
export struct MainContentView {
  @ObjectLink userViewModel: UserViewModel;

  build() {
    Column() {
      // 这里可以添加更多内容，比如优惠券、推荐等
      Text('更多功能即将上线...')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 50 })
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#FFFFFF')
    .margin({ top: 8 })
  }
}
