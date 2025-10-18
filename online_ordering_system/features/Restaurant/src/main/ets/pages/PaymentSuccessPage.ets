import { OrderViewModel } from '../viewModel/OrderViewModel';
import { Order, OrderItem } from 'common';
import { PageName, PaymentSuccessParams } from '../util/NavigationTypes';

@Component
export struct PaymentSuccessPage {
  @Consume('restaurantPathStack') restaurantPathStack: NavPathStack;
  @State orderId: string = '';
  @State orderAmount: number = 0;
  @State order: Order | null = null;
  private orderViewModel: OrderViewModel = new OrderViewModel();

  aboutToAppear() {
    // 从路径栈获取参数
    const params = this.restaurantPathStack.getParamByName(PageName.PAYMENT_SUCCESS)[0] as PaymentSuccessParams;
    this.orderId = params?.orderId || '';
    this.orderAmount = params?.totalAmount || 0;

    // 获取当前订单详情
    this.order = this.orderViewModel.getCurrentOrder();
  }

  build() {
    NavDestination() {
      Column() {
      // 顶部标题栏
      this.buildHeader()

      // 主要内容
      Column() {
        // 成功图标
        Image($r('sys.media.ohos_ic_public_ok'))
          .width(80)
          .height(80)
          .fillColor('#4CAF50')
          .margin({ top: 40, bottom: 20 })

        // 成功标题
        Text('支付成功！')
          .fontSize(24)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 8 })

        // 订单信息
        Text(`订单号：${this.orderId}`)
          .fontSize(16)
          .fontColor('#999999')
          .margin({ bottom: 4 })

        Text(`支付金额：¥${this.orderAmount.toFixed(1)}`)
          .fontSize(16)
          .fontColor('#999999')
          .margin({ bottom: 40 })

        // 订单详情卡片
        if (this.order) {
          this.buildOrderDetailsCard()
        }

        // 按钮区域
        Column() {
          // 查看订单按钮
          Button('查看订单')
            .width('100%')
            .height(48)
            .backgroundColor('#FF6B6B')
            .borderRadius(8)
            .fontColor(Color.White)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              // 暂时没有订单详情页面，可以后续添加
              console.log('查看订单功能待开发');
            })

          // 返回首页按钮
          Button('返回首页')
            .width('100%')
            .height(48)
            .backgroundColor('#333333')
            .borderRadius(8)
            .fontColor(Color.White)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 12 })
            .onClick(() => {
              // 返回首页 - 清空路径栈
              this.restaurantPathStack.clear();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .margin({ top: 40 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1A1A1A')
    }
    .hideTitleBar(true)
  }

  // 顶部标题栏
  @Builder
  buildHeader() {
    Row() {
      Image($r('sys.media.ohos_ic_public_arrow_left'))
        .width(24)
        .height(24)
        .fillColor(Color.White)
        .onClick(() => {
          this.restaurantPathStack.pop();
        })

      Text('支付成功')
        .fontSize(18)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 占位
      Column().width(24).height(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#1A1A1A')
  }

  // 订单详情卡片
  @Builder
  buildOrderDetailsCard() {
    Column() {
      Text('订单详情')
        .fontSize(16)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })

      // 订单商品列表
      ForEach(this.order!!.items, (item: OrderItem, index: number) => {
        Row() {
          // 商品图片
          Image(item.combo?.icon || item.dish?.image || '')
            .width(50)
            .height(50)
            .borderRadius(6)
            .objectFit(ImageFit.Cover)

          Column() {
            // 商品名称
            Text(item.combo?.name || item.dish?.name || '')
              .fontSize(14)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .alignSelf(ItemAlign.Start)

            // 数量
            Text(`x${item.quantity}`)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 4 })
              .alignSelf(ItemAlign.Start)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 12 })

          // 价格
          Text(`¥${item.totalPrice.toFixed(1)}`)
            .fontSize(14)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .padding({ top: 8, bottom: 8 })
        .alignItems(VerticalAlign.Top)

        if (index < this.order!!.items.length - 1) {
          Divider()
            .color('#333333')
            .strokeWidth(1)
            .margin({ top: 8, bottom: 8 })
        }
      })

      // 订单状态
      Row() {
        Text('订单状态：')
          .fontSize(14)
          .fontColor('#999999')

        Text('已确认')
          .fontSize(14)
          .fontColor('#4CAF50')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#2A2A2A')
    .borderRadius(12)
    .margin({ top: 20, left: 16, right: 16 })
  }
}
