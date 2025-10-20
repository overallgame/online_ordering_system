import { promptAction } from '@kit.ArkUI';
import { CartItem } from 'common';
import { TimeUtils } from '../util/TimeUtils';

@Component
export struct TimePickerComponent {
  @Link showTimePicker: boolean;
  @Link scheduledTime: string;
  @Link isScheduled: boolean;
  @Prop cartItems: CartItem[] = [];
  @State selectedTimeSlot: string = '';
  @State isTimeSlotSelected: boolean = false;

  // 选择预约时间
  private selectScheduledTime(hour: number, minute: number): void {
    if (!TimeUtils.validateSelectedTime(hour, minute, this.cartItems)) {
      const preparationTime = TimeUtils.calculatePreparationTime(this.cartItems);
      const now = new Date();
      const earliestDeliveryTime = new Date(now.getTime() + preparationTime * 60 * 1000);
      
      promptAction.showToast({
        message: `最早送达时间为 ${TimeUtils.formatTime(earliestDeliveryTime)}`,
        duration: 2000
      });
      return;
    }

    // 设置选中的时间槽
    this.selectedTimeSlot = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
    this.isTimeSlotSelected = true;
  }

  // 确认选择的时间
  private confirmTimeSelection(): void {
    if (!this.isTimeSlotSelected) {
      promptAction.showToast({ message: '请选择送达时间', duration: 1500 });
      return;
    }

    const timeParts = this.selectedTimeSlot.split(':');
    const hour = parseInt(timeParts[0]);
    const minute = parseInt(timeParts[1]);
    
    // 格式化时间字符串
    const timeString = `预约${TimeUtils.formatTimeDisplay(hour, minute)}送达`;

    // 设置选择的时间并关闭时间选择器
    this.scheduledTime = timeString;
    this.showTimePicker = false;
  }

  // 生成时间选择槽
  private generateTimeSlots(): string[] {
    return TimeUtils.generateTimeSlots(this.cartItems);
  }

  // 检查时间槽是否被选中
  private checkTimeSlotSelected(timeSlot: string): boolean {
    return this.selectedTimeSlot === timeSlot;
  }

  // 获取时间槽的背景色
  private getTimeSlotBackgroundColor(timeSlot: string): string {
    return this.checkTimeSlotSelected(timeSlot) ? '#FF6B6B' : '#333333';
  }

  // 获取时间槽的文字颜色
  private getTimeSlotTextColor(timeSlot: string): string {
    return this.checkTimeSlotSelected(timeSlot) ? '#FFFFFF' : '#CCCCCC';
  }

  // 重置选择状态
  private resetSelection(): void {
    this.selectedTimeSlot = '';
    this.isTimeSlotSelected = false;
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.resetSelection();
          this.scheduledTime = '预约送 选择时间 >';
          this.isScheduled = false;
          this.showTimePicker = false;
        })

      Column() {
        Row() {
          Column()
            .width(40)
            .height(4)
            .backgroundColor('#666666')
            .borderRadius(2)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 8, bottom: 8 })

        Row() {
          Text('选择送达时间')
            .fontSize(18)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: 8 })

        Row() {
          Text('请选择您希望的送达时间')
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: 8 })

        Grid() {
          ForEach(this.generateTimeSlots(), (timeSlot: string) => {
            GridItem() {
              Text(timeSlot)
                .fontSize(14)
                .fontColor(this.getTimeSlotTextColor(timeSlot))
                .fontWeight(this.checkTimeSlotSelected(timeSlot) ? FontWeight.Medium : FontWeight.Normal)
                .textAlign(TextAlign.Center)
                .width('100%')
                .height(44)
                .backgroundColor(this.getTimeSlotBackgroundColor(timeSlot))
                .borderRadius(8)
                .border({
                  width: this.checkTimeSlotSelected(timeSlot) ? 2 : 1,
                  color: this.checkTimeSlotSelected(timeSlot) ? '#FF6B6B' : '#444444'
                })
                .onClick(() => {
                  const timeParts = timeSlot.split(':');
                  const hour = parseInt(timeParts[0]);
                  const minute = parseInt(timeParts[1]);
                  this.selectScheduledTime(hour, minute);
                })
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsGap(12)
        .columnsGap(12)
        .padding({ left: 16, right: 16 })
        .layoutWeight(1)

        Row() {
          Row() {
            Text('取消')
              .fontSize(16)
              .fontColor('#999999')
              .fontWeight(FontWeight.Normal)
          }
          .width('48%')
          .height(48)
          .backgroundColor('#333333')
          .borderRadius(8)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.resetSelection();
            this.showTimePicker = false;
          })

          Row() {
            Text('确认')
              .fontSize(16)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
          }
          .width('48%')
          .height(48)
          .backgroundColor(this.isTimeSlotSelected ? '#FF6B6B' : '#666666')
          .borderRadius(8)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.confirmTimeSelection();
            this.isScheduled = true;
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .width('100%')
      .height('60%')
      .backgroundColor('#1A1A1A')
      .borderRadius({ topLeft: 16, topRight: 16 })
      .position({ x: 0, y: '100%' })
      .translate({ y: '-100%' })
      .transition(TransitionEffect.translate({ y: 0 }).animation({ duration: 300, curve: Curve.EaseOut }))
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
  }
}
