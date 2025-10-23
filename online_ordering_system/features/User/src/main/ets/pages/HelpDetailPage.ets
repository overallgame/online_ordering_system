import { HelpItem,HelpPageParams } from './HelpCenterPage';
import { ToastComponent } from '../components/ToastComponent';

/**
 * 帮助详情页面
 */
@Component
export struct HelpDetailPage {
  @Consume('navStack') navStack: NavPathStack;
  @State helpItem: HelpItem | null = null;

  aboutToAppear() {
    // 从路由参数获取帮助项目
    const params = (this.navStack.getParamByName('HelpDetailPage'))[0] as HelpPageParams ;
    if (params && params.helpItem) {
      this.helpItem = params.helpItem as HelpItem;
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
        this.buildTopBar()
        
        // 帮助内容
        this.buildHelpContent()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('帮助详情')
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
      
      Text('帮助详情')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildHelpContent() {
    if (!this.helpItem) {
      this.buildErrorView()
    } else {
      Scroll() {
        Column() {
          // 标题区域
          this.buildTitleSection()
          
          // 内容区域
          this.buildContentSection()
          
          // 操作按钮区域
          this.buildActionSection()
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 20 })
      }
      .layoutWeight(1)
    }
  }

  @Builder
  buildTitleSection() {
    Column() {
      Text(this.helpItem?.title || '')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })
      
      if (this.helpItem?.description) {
        Text(this.helpItem.description)
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)
          .lineHeight(20)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ top: 20, bottom: 20 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 16 })
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildContentSection() {
    Column() {
      Text('详细说明')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })
      
      Text(this.helpItem?.content || '暂无详细内容')
        .fontSize(15)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)
        .lineHeight(24)
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ top: 20, bottom: 20, left: 20, right: 20 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 12 })
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildActionSection() {
    Column() {
      // 是否对您有帮助
      Row() {
        Text('这个回答对您有帮助吗？')
          .fontSize(15)
          .fontColor('#333333')
          .layoutWeight(1)
        
        Row() {
          Button('有帮助')
            .fontSize(14)
            .fontColor('#4CAF50')
            .backgroundColor('#E8F5E8')
            .borderRadius(20)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(() => {
              this.handleFeedback(true);
            })
          
          Button('没帮助')
            .fontSize(14)
            .fontColor('#F44336')
            .backgroundColor('#FFEBEE')
            .borderRadius(20)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .margin({ left: 12 })
            .onClick(() => {
              this.handleFeedback(false);
            })
        }
      }
      .width('100%')
      .padding({ top: 20, bottom: 20 })
      
      // 联系客服按钮
      if (this.helpItem?.type === 'contact') {
        Button('联系客服')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#4CAF50')
          .borderRadius(24)
          .onClick(() => {
            this.contactCustomerService();
          })
      }
      
      // 相关帮助
      this.buildRelatedHelp()
    }
    .width('100%')
    .padding({ top: 20, bottom: 20, left: 20, right: 20 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 12 })
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildRelatedHelp() {
    Column() {
      Text('相关帮助')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })
      
      // 这里可以添加相关帮助项目的列表
      Text('• 如何修改个人信息？')
        .fontSize(14)
        .fontColor('#4CAF50')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })
        .onClick(() => {
          this.showToast('跳转到相关帮助');
        })
      
      Text('• 如何联系客服？')
        .fontSize(14)
        .fontColor('#4CAF50')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })
        .onClick(() => {
          this.showToast('跳转到相关帮助');
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 20 })
  }

  @Builder
  buildErrorView() {
    Column() {
      Image($r('app.media.more'))
        .width(120)
        .height(120)
        .opacity(0.6)
      
      Text('加载失败')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 16 })
      
      Text('请检查网络连接后重试')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
      
      Button('重新加载')
        .fontSize(14)
        .fontColor('#4CAF50')
        .backgroundColor('#E8F5E8')
        .borderRadius(20)
        .padding({ left: 24, right: 24, top: 8, bottom: 8 })
        .margin({ top: 16 })
        .onClick(() => {
          this.navStack.pop();
        })
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
    .layoutWeight(1)
  }

  handleFeedback(isHelpful: boolean) {
    if (isHelpful) {
      this.showToast('感谢您的反馈！');
    } else {
      this.showToast('我们会继续改进，感谢您的反馈！');
    }
  }

  contactCustomerService() {
    this.showToast('正在为您转接客服...');
  }

  showToast(message: string) {
    ToastComponent.getInstance().show(message);
  }
}
