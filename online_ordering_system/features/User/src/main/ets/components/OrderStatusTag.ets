import { OrderStatus } from 'common';

/**
 * 订单状态标签组件
 */
@Component
export struct OrderStatusTag {
  @Prop status: OrderStatus;
  @Prop text: string = '';
  @Prop color: string = '#9E9E9E';

  build() {
    Text(this.text || this.getStatusText())
      .fontSize(14)
      .fontColor(this.color)
      .fontWeight(FontWeight.Medium)
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .backgroundColor(this.getBackgroundColor())
      .borderRadius(12)
      .border({ width: 1, color: this.color })
  }

  private getStatusText(): string {
    const statusMap: Record<OrderStatus, string> = {
      [OrderStatus.PENDING]: '待付款',
      [OrderStatus.CONFIRMED]: '待接单',
      [OrderStatus.ACCEPTED]: '已接单',
      [OrderStatus.DELIVERING]: '派送中',
      [OrderStatus.COMPLETED]: '已完成',
      [OrderStatus.CANCELLED]: '已取消'
    };
    return statusMap[this.status] || '未知状态';
  }

  private getBackgroundColor(): string {
    const bgColorMap: Record<OrderStatus, string> = {
      [OrderStatus.PENDING]: '#FFF3E0',
      [OrderStatus.CONFIRMED]: '#E8F5E8',
      [OrderStatus.ACCEPTED]: '#FFF8E1',
      [OrderStatus.DELIVERING]: '#E3F2FD',
      [OrderStatus.COMPLETED]: '#F5F5F5',
      [OrderStatus.CANCELLED]: '#FFEBEE'
    };
    return bgColorMap[this.status] || '#F5F5F5';
  }
}
