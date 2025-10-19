import { UserViewModel } from '../viewmodel/UserViewModel';

/**
 * 用户信息头部View组件
 */
@Component
export struct UserHeaderView {
  @Prop userViewModel: UserViewModel;
  @Consume('navStack') navStack: NavPathStack;


  build() {
    Stack() {
      // 背景图片
      Image($r('app.media.user_background'))
        .height(120)
        .width('100%')
      
      // 用户信息内容
      Row() {
        // 用户头像
        Stack() {
          Image(this.userViewModel.user?.avatar ? this.userViewModel.user.avatar : $r('app.media.default_avatar'))
            .width(60)
            .height(60)
            .borderRadius(30)
            .border({ width: 2, color: '#FFFFFF' })
            .shadow({ radius: 4, color: '#00000020', offsetX: 0, offsetY: 2 })
            .objectFit(ImageFit.Cover)
        }
        // 用户信息
        Column() {
          Text(this.userViewModel.user?.username?this.userViewModel.user.username:"XXX")
            .fontSize(20)
            .fontColor('#000000')
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 4 })
          
          Text('个人中心 >')
            .fontSize(14)
            .fontColor('#666666')
            .onClick(() => {
              if (this.navStack) {
                this.navStack.pushPath({ name: 'UserDetailPage' });
              } else {
                console.error("navStack is not initialized");
              }

            })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
        .layoutWeight(1)
        
        // 右上角功能按钮
        Row() {
          
          Column() {
            Image($r('app.media.setting'))
              .height(15)
              .width(15)
            Text('设置')
              .fontSize(12)
              .fontColor('#666666')
              .margin({ top: 4 })
          }
          .margin({ left: 20 })
          .onClick(() => {
            if (this.navStack) {
              this.navStack.pushPath({ name: 'SettingPage' });
            } else {
              console.error("navStack is not initialized");
            }

          })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .height(120)


  }

  /**
   * 更新头像
   */
  private updateAvatar(avatarUri: string) {
    if (this.userViewModel.user) {
      this.userViewModel.user.avatar = avatarUri;
      // 这里可以添加保存到服务器的逻辑
      console.log('头像已更新:', avatarUri);
    }
  }
}
