import { UserViewModel } from '../viewmodel/UserViewModel';
import { UserHeaderView } from '../view/UserHeaderView';
import { OrderStatusView } from '../view/OrderStatusView';
import { MainContentView } from '../view/MainContentView';

@Entry
@Component
export  struct UserPage {
  @State userViewModel: UserViewModel = new UserViewModel();

  build() {
    Column() {

      // 主要内容区域
      this.buildMainContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * 构建主要内容区域
   */
  @Builder
  buildMainContent() {
    Column() {
      // 用户信息头部
      UserHeaderView({ userViewModel: this.userViewModel })

      // 订单状态区域
      OrderStatusView({ userViewModel: this.userViewModel })

      // 主内容区域
      MainContentView({ userViewModel: this.userViewModel })
    }
    .layoutWeight(1)
  }

}
