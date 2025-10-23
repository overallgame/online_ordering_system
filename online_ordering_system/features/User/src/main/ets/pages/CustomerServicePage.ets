import { CustomerServiceViewModel } from '../viewmodel/CustomerServiceViewModel';

/**
 * 客服中心页面
 */
@Component
export struct CustomerServicePage {
  @State customerServiceViewModel: CustomerServiceViewModel = new CustomerServiceViewModel();
  @Consume('navStack') navStack: NavPathStack;

  aboutToAppear() {
    this.customerServiceViewModel.loadCustomerServiceInfo();
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
        this.buildTopBar()
        
        // 客服中心内容
        this.buildCustomerServiceContent()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8F9FA')
    }
    .title('客服中心')
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
      
      Text('客服中心')
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
  buildCustomerServiceContent() {
    Column() {
      // 客服信息卡片
      this.buildServiceInfoCard()
      
      // 联系方式卡片
      this.buildContactCard()
      
      // 预约回电卡片
      this.buildCallbackCard()
      
      // 常见问题卡片
      this.buildFAQCard()
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16 })
    .layoutWeight(1)
  }

  @Builder
  buildServiceInfoCard() {
    Column() {
      // 客服头像和基本信息
      Row() {
        Stack() {
          Circle()
            .width(60)
            .height(60)
            .fill('#4CAF50')
            .opacity(0.1)
          
          Text('客服')
            .fontSize(16)
            .fontColor('#4CAF50')
            .fontWeight(FontWeight.Bold)
        }
        .margin({ right: 16 })
        
        Column() {
          Text('在线客服')
            .fontSize(18)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 4 })
          
          Text('服务时间：9:00-21:00')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 2 })
          
          Text('专业团队为您服务')
            .fontSize(12)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 20 })
      
      // 服务状态
      Row() {
        Stack() {
          Circle()
            .width(8)
            .height(8)
            .fill('#4CAF50')
          
          Circle()
            .width(4)
            .height(4)
            .fill('#FFFFFF')
        }
        .margin({ right: 8 })
        
        Text('当前在线，响应时间 < 30秒')
          .fontSize(14)
          .fontColor('#4CAF50')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ bottom: 16 })
    .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildContactCard() {
    Column() {
      Text('联系方式')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })
        .alignSelf(ItemAlign.Start)
      
      // 拨打热线
      Row() {
        Stack() {
          Circle()
            .width(40)
            .height(40)
            .fill('#FF6B35')
            .opacity(0.1)
          
          Image($r('app.media.pending_payment')) // 使用现有图标
            .width(20)
            .height(20)
            .fillColor('#FF6B35')
        }
        .margin({ right: 16 })
        
        Column() {
          Text('拨打热线')
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 2 })
          
          Text('400-123-4567')
            .fontSize(14)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        Image($r('app.media.open'))
          .width(16)
          .height(16)
          .fillColor('#999999')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFF8F5')
      .borderRadius(12)
      .margin({ bottom: 12 })
      .onClick(() => {
        this.customerServiceViewModel.makePhoneCall();
      })
      

    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ bottom: 16 })
    .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildCallbackCard() {
    Column() {
      Text('预约回电')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })
        .alignSelf(ItemAlign.Start)
      
      // 预约时间选择
      Row() {
        Text('预约时间')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ right: 16 })
        
        Text(this.customerServiceViewModel.selectedTime || '请选择时间')
          .fontSize(14)
          .fontColor(this.customerServiceViewModel.selectedTime ? '#333333' : '#999999')
          .layoutWeight(1)
        
        Image($r('app.media.open'))
          .width(16)
          .height(16)
          .fillColor('#999999')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F8F9FA')
      .borderRadius(12)
      .margin({ bottom: 12 })
      .onClick(() => {
        this.customerServiceViewModel.showTimePicker();
      })
      
      // 联系电话
      Row() {
        Text('联系电话')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ right: 16 })
        
        TextInput({ placeholder: '请输入您的手机号' })
          .fontSize(14)
          .fontColor('#333333')
          .layoutWeight(1)
          .onChange((value: string) => {
            this.customerServiceViewModel.setCallbackPhone(value);
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F8F9FA')
      .borderRadius(12)
      .margin({ bottom: 16 })
      
      // 预约按钮
      Stack() {
        Rect({ width: '100%', height: 44 })
          .fill('#4CAF50')
          .radius(12)
          .shadow({ radius: 8, color: '#4CAF5030', offsetX: 0, offsetY: 4 })
        
        Text('预约回电')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
          .align(Alignment.Center)
      }
      .width('100%')
      .height(44)
      .onClick(() => {
        this.customerServiceViewModel.scheduleCallback();
      })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ bottom: 16 })
    .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildFAQCard() {
    Column() {
      Text('常见问题')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })
        .alignSelf(ItemAlign.Start)
      
      // 常见问题列表
      Column() {
        this.buildFAQItem('如何取消订单？', '在订单详情页面点击"取消订单"按钮')
        this.buildFAQItem('订单什么时候发货？', '一般情况下24小时内发货')
        this.buildFAQItem('如何申请退款？', '联系客服或在我的订单中申请退款')
        this.buildFAQItem('配送范围包括哪些地区？', '目前支持全国大部分城市配送')
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildFAQItem(question: string, answer: string) {
    Column() {
      Row() {
        Text(question)
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        
        Image($r('app.media.open'))
          .width(16)
          .height(16)
          .fillColor('#999999')
          .rotate({ angle: this.customerServiceViewModel.expandedFAQ === question ? 180 : 0 })
      }
      .width('100%')
      .padding(12)
      .onClick(() => {
        this.customerServiceViewModel.toggleFAQ(question);
      })
      
      if (this.customerServiceViewModel.expandedFAQ === question) {
        Text(answer)
          .fontSize(12)
          .fontColor('#666666')
          .padding({ left: 12, right: 12, bottom: 12 })
          .width('100%')
          .textAlign(TextAlign.Start)
      }
    }
    .width('100%')
    .margin({ bottom: 8 })
  }
}
