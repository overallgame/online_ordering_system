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
      // 渐变背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#667eea', 0.0], ['#764ba2', 1.0]]
        })
      
      // 装饰性圆形背景
      Circle()
        .width(120)
        .height(120)
        .fill('#FFFFFF')
        .opacity(0.1)
        .position({ x: '80%', y: '-20%' })
      
      Circle()
        .width(80)
        .height(80)
        .fill('#FFFFFF')
        .opacity(0.08)
        .position({ x: '-10%', y: '60%' })
      
      // 用户信息内容
      Row() {
        // 用户头像
        Stack() {
          Image(this.userViewModel.user?.avatar ? this.userViewModel.user.avatar : $r('app.media.default_avatar'))
            .width(70)
            .height(70)
            .borderRadius(35)
            .border({ width: 3, color: '#FFFFFF' })
            .shadow({ radius: 8, color: '#00000030', offsetX: 0, offsetY: 4 })
            .objectFit(ImageFit.Cover)
            .transition(TransitionEffect.OPACITY)
          
          // 头像装饰环
          Circle()
            .width(76)
            .height(76)
            .stroke('#FFFFFF')
            .strokeWidth(1)
            .opacity(0.3)
        }
        
        // 用户信息
        Column() {
          Text(this.userViewModel.user?.username ? this.userViewModel.user.username : "XXX")
            .fontSize(22)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 6 })
          
          Row() {
            Text('查看个人资料')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .opacity(0.9)
            
            Image($r('app.media.open'))
              .width(12)
              .height(12)
              .margin({ left: 4 })
              .opacity(0.8)
          }
          .onClick(() => {
            if (this.navStack) {
              this.navStack.pop();
              this.navStack.pushPath({ name: 'UserDetailPage' });
            } else {
              console.error("navStack is not initialized");
            }
          })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 20 })
        .layoutWeight(1)
        
        // 右上角功能按钮
        Column() {
          Stack() {
            Circle()
              .width(36)
              .height(36)
              .fill('#FFFFFF')
              .opacity(0.2)
            
            Image($r('app.media.setting'))
              .width(18)
              .height(18)
              .fillColor('#FFFFFF')
          }
          .onClick(() => {
            if (this.navStack) {
              this.navStack.pushPath({ name: 'SettingPage' });
            } else {
              console.error("navStack is not initialized");
            }
          })
          
          Text('设置')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .opacity(0.9)
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 30, bottom: 30 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(160)
    .borderRadius({ bottomLeft: 20, bottomRight: 20 })
    .shadow({ radius: 12, color: '#00000020', offsetX: 0, offsetY: 4 })
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
