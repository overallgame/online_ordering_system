import call from '@ohos.telephony.call';
import systemDateTime from '@ohos.systemDateTime';
/**
 * FAQ 接口定义
 */
export interface FAQItem {
  question: string;
  answer: string;
}

interface AtManagerAPI {
  checkAccessToken(permission: string): Promise<number>;
}
/**
 * 客服中心ViewModel - 处理客服相关的业务逻辑
 */
@Observed
export class CustomerServiceViewModel {
  // 客服信息
  servicePhone: string = '666666';
  serviceHours: string = '9:00-21:00';
  isOnline: boolean = true;
  
  // 预约回电相关
  selectedTime: string = '';
  callbackPhone: string = '';
  
  // FAQ相关
  expandedFAQ: string = '';
  
  // 常见问题数据
  faqList: Array<FAQItem> = [
    {
      question: '如何取消订单？',
      answer: '在订单详情页面点击"取消订单"按钮，订单取消后会自动退款到原支付方式。'
    },
    {
      question: '订单什么时候发货？',
      answer: '一般情况下24小时内发货，节假日可能会延迟1-2天。'
    },
    {
      question: '如何申请退款？',
      answer: '联系客服或在我的订单中申请退款，我们会在1-3个工作日内处理。'
    },
    {
      question: '配送范围包括哪些地区？',
      answer: '目前支持全国大部分城市配送，偏远地区可能需要额外配送费。'
    },
    {
      question: '如何修改收货地址？',
      answer: '在订单详情页面可以修改收货地址，但需要在发货前修改。'
    },
    {
      question: '支持哪些支付方式？',
      answer: '支持微信支付、支付宝、银行卡等多种支付方式。'
    }
  ];

  /**
   * 加载客服信息
   */
  loadCustomerServiceInfo(): void {

  }

  /**
   * 拨打热线电话
   */
  async makePhoneCall(): Promise<void> {
    try {
        await call.makeCall(this.servicePhone);
        console.log('拨打客服热线:', this.servicePhone);
    } catch (error) {
      console.error('拨号失败:', error);
      // 如果系统拨号失败，显示号码让用户手动拨打
      this.showToast('请手动拨打客服热线: ' + this.servicePhone);
    }
  }



  /**
   * 显示时间选择器
   */
  showTimePicker(): void {
    // 这里可以集成时间选择器组件
    console.log('显示时间选择器');
    this.showToast('时间选择功能开发中...');
    
    // 临时设置一个时间用于演示
    setTimeout(() => {
      this.selectedTime = '明天 14:00-15:00';
    }, 1000);
  }

  /**
   * 设置回电电话
   */
  setCallbackPhone(phone: string): void {
    this.callbackPhone = phone;
  }

  /**
   * 预约回电
   */
  scheduleCallback(): void {
    if (!this.selectedTime) {
      this.showToast('请选择预约时间');
      return;
    }
    
    if (!this.callbackPhone) {
      this.showToast('请输入联系电话');
      return;
    }
    
    if (!this.isValidPhone(this.callbackPhone)) {
      this.showToast('请输入正确的手机号码');
      return;
    }
    
    // 这里可以调用后端API提交预约信息
    console.log('预约回电:', {
      time: this.selectedTime,
      phone: this.callbackPhone
    });
    
    this.showToast('预约成功！我们会在指定时间联系您');
    
    // 清空表单
    this.selectedTime = '';
    this.callbackPhone = '';
  }

  /**
   * 切换FAQ展开状态
   */
  toggleFAQ(question: string): void {
    if (this.expandedFAQ === question) {
      this.expandedFAQ = '';
    } else {
      this.expandedFAQ = question;
    }
  }

  /**
   * 验证手机号格式
   */
  private isValidPhone(phone: string): boolean {
    const phoneRegex = /^1[3-9]\d{9}$/;
    return phoneRegex.test(phone);
  }

  /**
   * 显示提示信息
   */
  private showToast(message: string): void {
    // 这里可以集成Toast组件
    console.log('Toast:', message);
  }
}
