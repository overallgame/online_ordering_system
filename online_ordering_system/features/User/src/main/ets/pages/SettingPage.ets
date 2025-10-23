import { AppDataManager } from 'common';
import { UserViewModel } from '../viewmodel/UserViewModel';
import promptAction from '@ohos.promptAction';
interface SettingSection {
   title : string,
   icon: Resource,
  onTap: () => void
}
@Component
export struct SettingPage {
  @Consume('navStack') navStack: NavPathStack;
  @Consume('mainPathStack') mainPathStack: NavPathStack;
  @Link userViewModel: UserViewModel;
  @State showLogoutDialog: boolean = false;

  aboutToAppear() {

  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
        this.buildTopBar()
        this.buildSettingSection('应用设置', [
          { title: '通知设置', icon: $r('app.media.inform'), onTap: (): void => this.showToast('功能开发中') },
          { title: '隐私设置', icon: $r('app.media.private'), onTap: (): void => this.showToast('功能开发中') },
          { title: '关于我们', icon: $r('app.media.about_us'), onTap: (): void => this.showToast('功能开发中') }
        ])
        this.buildLogoutSection()

      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('设置')
    .hideTitleBar(true)
  }

  @Builder
  buildTopBar() {
    Row() {
      Image($r('app.media.back'))
        .height(24)
        .width(24)
        .onClick(() => {
          this.navStack.pop();
        })
      
      Text('设置')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .margin({ left: 16 })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildSettingSection(title: string, items: Array<SettingSection>) {
    Column() {
      Text(title)
        .fontSize(14)
        .fontColor('#999999')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12, left: 4 })
      
      Column() {
        ForEach(items, (item: SettingSection, index: number) => {
          Row() {
            Image(item.icon)
              .height(20)
              .width(20)
              .margin({ right: 12 })
            
            Text(item.title)
              .fontSize(16)
              .fontColor('#000000')
              .layoutWeight(1)
            
            Text('>')
              .fontSize(16)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)
          .backgroundColor('#FFFFFF')
          .onClick(() => {
            item.onTap();
          })
          

        })
      }
      .borderRadius(12)
      .backgroundColor('#FFFFFF')
      .margin({ bottom: 24 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildLogoutSection() {
    Column() {
      Row() {
        Image($r('app.media.logout'))
          .height(20)
          .width(20)
          .margin({ right: 12 })
        
        Text('退出登录')
          .fontSize(16)
          .fontColor('#FF4444')
          .layoutWeight(1)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .onClick(() => {
        AlertDialog.show({
          title: '确认退出登录',
          message: '退出登录后需要重新登录才能使用相关功能',
          autoCancel: true,
          alignment: DialogAlignment.Center,
          primaryButton: {
            value: '确认退出',
            fontColor: Color.White,
            backgroundColor: Color.Red,
            action: () => {
              this.handleLogout();
            }
          },
          secondaryButton: {
            value: '取消',
            fontColor: Color.Black,
            action: () => {
            }
          }
        });
      })
    }
    .width('100%')
    .margin({ top: 20 })
  }

  // 导航方法
  navigateToUserDetail() {
    this.navStack.pushPath({ name: 'UserDetailPage' });
  }

  navigateToMyOrders() {
    this.navStack.pushPath({ name: 'MyOrdersPage' });
  }

  // 退出登录处理
  async handleLogout() {
    try {
      this.showLogoutDialog = false;
      this.showToast('正在退出登录...');
      
      const appDataManager = AppDataManager.getInstance();
      const success = await appDataManager.logout();
      
      if (success) {
        this.showToast('已退出登录');
        console.log('用户已成功退出登录');
        
        // 跳转到登录页面
        if (this.mainPathStack) {
          // 清除所有页面栈，然后跳转到登录页面
          this.mainPathStack.clear();
          this.navStack.clear();
          this.mainPathStack.pushPathByName('login', null);
        } else {
          console.error('mainPathStack is not available');
        }
      } else {
        this.showToast('退出登录失败，请重试');
      }
    } catch (error) {
      console.error('退出登录失败:', error);
      this.showToast('退出登录失败，请重试');
    }
  }

  // 显示提示信息
  showToast(message: string) {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }
}