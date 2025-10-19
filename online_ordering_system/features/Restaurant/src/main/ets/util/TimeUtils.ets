import { CartItem } from 'common';

export class TimeUtils {

  static calculatePreparationTime(cartItems: CartItem[]): number {
    let maxPreparationTime = 0;
    cartItems.forEach(item => {
      const preparationTime = item.combo?.preparationTime || item.dish?.preparationTime || 0;
      maxPreparationTime = Math.max(maxPreparationTime, preparationTime);
    });
    return maxPreparationTime;
  }

  static formatTime(date: Date): string {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  static formatTimeDisplay(hour: number, minute: number): string {
    const time = new Date();
    time.setHours(hour, minute, 0, 0);
    return TimeUtils.formatTime(time);
  }

  static calculateImmediateDeliveryTime(cartItems: CartItem[]): string {
    const now = new Date();
    const preparationTime = TimeUtils.calculatePreparationTime(cartItems);
    
    const deliveryTime = new Date(now.getTime() + (preparationTime + 15) * 60 * 1000);
    const startTime = new Date(now.getTime() + preparationTime * 60 * 1000);
    const endTime = deliveryTime;

    return `立即送达(${TimeUtils.formatTime(startTime)}-${TimeUtils.formatTime(endTime)})`;
  }

  static generateTimeSlots(cartItems: CartItem[], maxSlots: number = 12): string[] {
    const timeSlots: string[] = [];
    const now = new Date();
    const preparationTime = TimeUtils.calculatePreparationTime(cartItems);
    
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

    // 生成时间槽
    for (let i = 0; i < maxSlots; i++) {
      if (currentHour >= 24) {
        break;
      }
      
      const timeString = `${currentHour.toString().padStart(2, '0')}:${currentMinute.toString().padStart(2, '0')}`;
      timeSlots.push(timeString);

      currentMinute += 30;
      if (currentMinute >= 60) {
        currentMinute = 0;
        currentHour += 1;
      }
    }
    
    return timeSlots;
  }

  static validateSelectedTime(hour: number, minute: number, cartItems: CartItem[]): boolean {
    const now = new Date();
    const selectedTime = new Date(now.getFullYear(), now.getMonth(), now.getDate(), hour, minute);
    const preparationTime = TimeUtils.calculatePreparationTime(cartItems);
    const earliestDeliveryTime = new Date(now.getTime() + preparationTime * 60 * 1000);
    
    return selectedTime >= earliestDeliveryTime;
  }

  static calculateScheduledDeliveryTimestamp(scheduledTimeString: string): number {
    if (!scheduledTimeString) return 0;
    
    const now = new Date();
    const timeMatch = scheduledTimeString.match(/(\d{2}):(\d{2})/);
    if (timeMatch) {
      const hour = parseInt(timeMatch[1]);
      const minute = parseInt(timeMatch[2]);
      const scheduledTime = new Date(now.getFullYear(), now.getMonth(), now.getDate(), hour, minute);
      return scheduledTime.getTime();
    }
    return 0;
  }

  static formatTimeDisplayString(timeString: string): string {
    if (!timeString) return '';
    
    // 如果是预约时间格式，直接返回
    if (timeString.includes('预约送')) {
      return timeString;
    }
    
    // 如果是时间格式，转换为预约格式
    const timeMatch = timeString.match(/(\d{2}):(\d{2})/);
    if (timeMatch) {
      return `预约送 ${timeMatch[0]}送达`;
    }
    
    return timeString;
  }
}
