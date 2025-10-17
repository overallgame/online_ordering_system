import { Order, OrderType } from 'common';
import { OrderStatusTag } from './OrderStatusTag';
import { OrderActionButtons } from './OrderActionButtons';

/**
 * 订单项组件
 */
@Component
export struct OrderItemComponent {
  @Prop order: Order;
  @Prop mode?: 'all' | 'payment' | 'delivery'; // 按钮显示模式
  onCancel?: () => void;
  onDelete?: () => void;
  onPay?: () => void;
  onRemind?: () => void;
  onRepeat?: () => void;

  build() {
    Column() {
      // 订单头部信息
      Row() {
        Text(`订单号: ${this.order.orderId}`)
          .fontSize(14)
          .fontColor('#666666')
          .layoutWeight(1)
        
        OrderStatusTag({ 
          status: this.order.status,
          color: this.getStatusColor()
        })
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 订单内容
      Row() {
        // 商品图片
        Image($r('app.media.setting'))
          .width(80)
          .height(80)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
          .margin({ right: 12 })

        // 商品信息
        Column() {
          Text(this.getMainDishName())
            .fontSize(16)
            .fontColor('#000000')
            .fontWeight(FontWeight.Medium)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })

          Text(`就餐方式: ${this.getOrderTypeText()}`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 4 })

          Text(`订单时间: ${this.formatTime()}`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          Text(`总计 ¥${this.order.finalAmount.toFixed(2)}`)
            .fontSize(16)
            .fontColor('#FF6B35')
            .fontWeight(FontWeight.Bold)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      // 操作按钮
      OrderActionButtons({
        order: this.order,
        mode: this.mode,
        onCancel: this.onCancel,
        onDelete: this.onDelete,
        onPay: this.onPay,
        onRemind: this.onRemind,
        onRepeat: this.onRepeat
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 12 })
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
  }

  private getMainDishName(): string {
    if (this.order.items.length === 0) {
      return '商品已下架';
    }
    
    const mainItem = this.order.items[0];
    if (mainItem.dish) {
      return mainItem.dish.name;
    } else if (mainItem.combo) {
      return mainItem.combo.name;
    }
    
    return '未知商品';
  }

  private getOrderTypeText(): string {
    const typeMap: Record<OrderType, string> = {
      [OrderType.DINE_IN]: '进店用餐',
      [OrderType.TAKEAWAY]: '自取',
      [OrderType.DELIVERY]: '外卖配送'
    };
    return typeMap[this.order.orderType] || '未知类型';
  }

  private getStatusColor(): string {
    const colorMap: Record<string, string> = {
      'pending': '#FF6B35',
      'confirmed': '#4CAF50',
      'preparing': '#FF9800',
      'ready': '#2196F3',
      'completed': '#9E9E9E',
      'cancelled': '#F44336'
    };
    return colorMap[this.order.status] || '#9E9E9E';
  }

  private formatTime(): string {
    if (this.order.createTime === 0) {
      return '未知时间';
    }
    const date = new Date(this.order.createTime);
    return date.toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    });
  }
}
