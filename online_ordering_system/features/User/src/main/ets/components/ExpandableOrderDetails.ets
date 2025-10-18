import { Order, OrderItem } from 'common';
import { OrderDetailItem } from './OrderDetailItem';

/**
 * 可展开的订单详情组件
 */
@Component
export struct ExpandableOrderDetails {
  @Prop order: Order;
  @State isExpanded: boolean = false;

  build() {
    Column() {
      // 订单概览
      Row() {
        Text(this.getOrderSummary())
          .fontSize(14)
          .fontColor('#000000')
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        // 展开/收起按钮
        Row() {
          Text(this.isExpanded ? '收起' : '展开')
            .fontSize(12)
            .fontColor('#4CAF50')

          Image($r('app.media.setting'))
            .width(16)
            .height(16)
            .margin({ left: 4 })
            .rotate({ angle: this.isExpanded ? 180 : 0 })
            .animation({ duration: 200 })
        }
        .onClick(() => {
          this.isExpanded = !this.isExpanded;
        })
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FAFAFA')
      .borderRadius(8)
      .onClick(() => {
        this.isExpanded = !this.isExpanded;
      })

      // 展开的详情列表
      if (this.isExpanded) {
        Column() {
          ForEach(this.order.items, (item: OrderItem, index: number) => {
            OrderDetailItem({ orderItem: item })
            
            // 添加分隔线（除了最后一项）
            if (index < this.order.items.length - 1) {
              Divider()
                .color('#E0E0E0')
                .margin({ top: 8, bottom: 8 })
            }
          })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .padding(12)
        .margin({ top: 8 })
        .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
      }
    }
    .width('100%')
  }

  private getOrderSummary(): string {
    if (this.order.items.length === 0) {
      return '商品已下架';
    }
    
    if (this.order.items.length === 1) {
      const item = this.order.items[0];
      const name = item.dish?.name || item.combo?.name || '未知商品';
      return `${name} x${item.quantity}`;
    } else {
      const totalQuantity = this.order.items.reduce((sum: number, item) => sum + item.quantity, 0);
      return `共${this.order.items.length}件商品，${totalQuantity}件`;
    }
  }
}
