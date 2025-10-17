import { promptAction } from '@kit.ArkUI';
import { CartItem } from 'common';

@Component
export struct TimePickerComponent {
  @Link showTimePicker: boolean;
  @Prop cartItems: CartItem[] = [];
  @Link scheduledTime: string;

  // 计算准备时间
  private calculatePreparationTime(): number {
    let maxPreparationTime = 0;
    this.cartItems.forEach(item => {
      const preparationTime = item.combo?.preparationTime || item.dish?.preparationTime || 0;
      maxPreparationTime = Math.max(maxPreparationTime, preparationTime);
    });
    return maxPreparationTime;
  }

  // 格式化时间
  private formatTime(date: Date): string {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  // 选择预约时间
  private selectScheduledTime(hour: number, minute: number): void {
    const now = new Date();
    const selectedTime = new Date(now.getFullYear(), now.getMonth(), now.getDate(), hour, minute);
    const preparationTime = this.calculatePreparationTime();
    const earliestDeliveryTime = new Date(now.getTime() + preparationTime * 60 * 1000);

    // 检查选择的时间是否早于最早送达时间
    if (selectedTime < earliestDeliveryTime) {
      // 显示错误提示
      promptAction.showToast({
        message: `最早送达时间为 ${this.formatTime(earliestDeliveryTime)}`,
        duration: 2000
      });
      return;
    }

    // 格式化时间字符串
    const timeString = `预约送 ${this.formatTime(selectedTime)}送达`;

    // 设置选择的时间并关闭时间选择器
    this.scheduledTime = timeString;
    this.showTimePicker = false;
  }

  // 生成时间选择槽
  private generateTimeSlots(): string[] {
    const timeSlots: string[] = [];
    const now = new Date();
    const preparationTime = this.calculatePreparationTime();
    
    // 计算最早送达时间（当前时间 + 准备时间）
    const earliestDeliveryTime = new Date(now.getTime() + preparationTime * 60 * 1000);
    const earliestHour = earliestDeliveryTime.getHours();
    const earliestMinute = earliestDeliveryTime.getMinutes();
    
    // 从最早送达时间开始生成时间槽
    let currentHour = earliestHour;
    let currentMinute = earliestMinute;
    
    // 如果分钟不是0或30，调整到下一个30分钟间隔
    if (currentMinute > 0 && currentMinute <= 30) {
      currentMinute = 30;
    } else if (currentMinute > 30) {
      currentHour += 1;
      currentMinute = 0;
    }
    
    // 生成12个时间槽
    for (let i = 0; i < 12; i++) {
      if (currentHour >= 24) {
        break; // 超过24小时就停止
      }
      
      const timeString = `${currentHour.toString().padStart(2, '0')}:${currentMinute.toString().padStart(2, '0')}`;
      timeSlots.push(timeString);
      
      // 下一个时间槽（30分钟后）
      currentMinute += 30;
      if (currentMinute >= 60) {
        currentMinute = 0;
        currentHour += 1;
      }
    }
    
    return timeSlots;
  }

  build() {
    Stack() {
      // 背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showTimePicker = false;
        })

      // 时间选择器内容
      Column() {
        // 顶部拖拽条
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

        // 标题
        Row() {
          Text('选择送达时间')
            .fontSize(18)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: 16 })

        // 时间槽网格
        Grid() {
          ForEach(this.generateTimeSlots(), (timeSlot: string) => {
            GridItem() {
              Text(timeSlot)
                .fontSize(14)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Normal)
                .textAlign(TextAlign.Center)
                .width('100%')
                .height(40)
                .backgroundColor('#333333')
                .borderRadius(8)
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
        .padding({ left: 16, right: 16, bottom: 20 })

        // 取消按钮
        Row() {
          Text('取消')
            .fontSize(16)
            .fontColor('#999999')
            .fontWeight(FontWeight.Normal)
        }
        .width('100%')
        .height(48)
        .backgroundColor('#333333')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .margin({ left: 16, right: 16, bottom: 16 })
        .onClick(() => {
          this.showTimePicker = false;
        })
      }
      .width('100%')
      .backgroundColor('#1A1A1A')
      .borderRadius({ topLeft: 16, topRight: 16 })
      .position({ x: 0, y: '100%' })
      .translate({ y: '-60%' })
      .transition(TransitionEffect.translate({ y: 0 }).animation({ duration: 300, curve: Curve.EaseOut }))
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
  }
}
