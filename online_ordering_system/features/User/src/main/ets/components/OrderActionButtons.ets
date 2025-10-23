import { Order, OrderStatus, PaymentStatus } from 'common';

/**
 * 订单操作按钮组件
 */
@Component
export struct OrderActionButtons {
  @Prop order: Order;
  @Prop mode?: 'all' | 'payment' | 'delivery'; // 按钮显示模式
  onCancel?: () => void;
  onDelete?: () => void;
  onPay?: () => void;
  onRemind?: () => void;
  onRepeat?: () => void;

  build() {
    Row() {
      // 根据模式显示不同的按钮
      if (this.canCancelOrder()) {
        Button('取消订单')
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: '#E0E0E0' })
          .borderRadius(6)
          .height(36)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            if (this.onCancel) {
              this.onCancel();
            }
          })
      }

      if (this.canDeleteOrder()) {
        Button('删除订单')
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: '#E0E0E0' })
          .borderRadius(6)
          .height(36)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            if (this.onDelete) {
              this.onDelete();
            }
          })
      }

      if (this.canPayOrder()) {
        Button('立即支付')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#4CAF50')
          .border({ width: 1, color: '#4CAF50' })
          .borderRadius(6)
          .height(36)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            if (this.onPay) {
              this.onPay();
            }
          })
      }

      if (this.canRemindOrder()) {
        Button('催单')
          .fontSize(14)
          .fontColor('#FF9800')
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: '#FF9800' })
          .borderRadius(6)
          .height(36)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            if (this.onRemind) {
              this.onRemind();
            }
          })
      }

      if (this.canRepeatOrder()) {
        Button('再来一单')
          .fontSize(14)
          .fontColor('#2196F3')
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: '#2196F3' })
          .borderRadius(6)
          .height(36)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            if (this.onRepeat) {
              this.onRepeat();
            }
          })
      }
    }
    .justifyContent(FlexAlign.End)
    .width('100%')
    .margin({ top: 12 })
  }

  private canCancelOrder(): boolean {
    return this.order.status === OrderStatus.PENDING && this.order.paymentStatus === PaymentStatus.PENDING;
  }

  private canDeleteOrder(): boolean {
    return this.order.status === OrderStatus.COMPLETED || this.order.status === OrderStatus.CANCELLED;
  }

  private canPayOrder(): boolean {
    return this.order.status === OrderStatus.PENDING && this.order.paymentStatus === PaymentStatus.PENDING;
  }

  private canRemindOrder(): boolean {
    // 已付款、制作中、待取餐状态可以催单
    return this.order.status === OrderStatus.CONFIRMED ||
      this.order.status === OrderStatus.ACCEPTED ||
      this.order.status === OrderStatus.DELIVERING;
  }

  private canRepeatOrder(): boolean {
    // 已完成或已取消的订单可以再来一单
    return this.order.status === OrderStatus.COMPLETED ||
      this.order.status === OrderStatus.CANCELLED;
  }

  // 根据模式判断是否显示按钮
  private shouldShowCancelButton(): boolean {
    if (this.mode === 'payment') return false; // 待付款页面不显示取消按钮
    if (this.mode === 'delivery') return false; // 待收货页面不显示取消按钮
    return this.canCancelOrder();
  }

  private shouldShowDeleteButton(): boolean {
    if (this.mode === 'payment') return false; // 待付款页面不显示删除按钮
    if (this.mode === 'delivery') return false; // 待收货页面不显示删除按钮
    return this.canDeleteOrder();
  }

  private shouldShowPayButton(): boolean {
    if (this.mode === 'delivery') return false; // 待收货页面不显示支付按钮
    return this.canPayOrder();
  }

  private shouldShowRemindButton(): boolean {
    if (this.mode === 'payment') return false; // 待付款页面不显示催单按钮
    return this.canRemindOrder();
  }

  private shouldShowRepeatButton(): boolean {
    if (this.mode === 'payment') return false; // 待付款页面不显示再来一单按钮
    if (this.mode === 'delivery') return false; // 待收货页面不显示再来一单按钮
    return this.canRepeatOrder();
  }
}