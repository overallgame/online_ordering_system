import { OrderItem } from 'common';

/**
 * 订单详情项组件 - 显示单个订单项
 */
@Component
export struct OrderDetailItem {
  @Prop orderItem: OrderItem;

  build() {
    Row() {
      // 商品图片
      Image($r('app.media.setting'))
        .width(60)
        .height(60)
        .borderRadius(6)
        .objectFit(ImageFit.Cover)
        .margin({ right: 12 })

      // 商品信息
      Column() {
        Text(this.getDishName())
          .fontSize(14)
          .fontColor('#000000')
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 4 })

        // 规格信息
        if (this.orderItem.note && this.orderItem.note.length > 0) {
          Text(`规格: ${this.orderItem.note}`)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ bottom: 4 })
        }

        // 价格和数量
        Row() {
          Text(`¥${this.orderItem.unitPrice.toFixed(2)}`)
            .fontSize(14)
            .fontColor('#FF6B35')
            .fontWeight(FontWeight.Medium)

          Text(`x${this.orderItem.quantity}`)
            .fontSize(12)
            .fontColor('#666666')
            .margin({ left: 8 })

          Text(`¥${this.orderItem.totalPrice.toFixed(2)}`)
            .fontSize(14)
            .fontColor('#000000')
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.End)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF')
  }

  private getDishName(): string {
    if (this.orderItem.dish) {
      return this.orderItem.dish.name;
    } else if (this.orderItem.combo) {
      return this.orderItem.combo.name;
    }
    return '未知商品';
  }
}
