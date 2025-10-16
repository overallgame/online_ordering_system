import promptAction from '@ohos.promptAction';

/**
 * Toast组件 - 显示用户反馈信息
 */
export class ToastComponent {
  private static instance: ToastComponent;

  public static getInstance(): ToastComponent {
    if (!ToastComponent.instance) {
      ToastComponent.instance = new ToastComponent();
    }
    return ToastComponent.instance;
  }

  /**
   * 显示Toast消息
   * @param message 要显示的消息
   * @param duration 显示时长（毫秒），默认2000ms
   */
  show(message: string, duration: number = 2000): void {
    try {
      promptAction.showToast({
        message: message,
        duration: duration
      });
    } catch (error) {
      console.error('显示Toast失败:', error);
    }
  }

  /**
   * 显示成功消息
   * @param message 要显示的消息
   */
  showSuccess(message: string): void {
    this.show(`✅ ${message}`, 2000);
  }

  /**
   * 显示错误消息
   * @param message 要显示的消息
   */
  showError(message: string): void {
    this.show(`❌ ${message}`, 3000);
  }

  /**
   * 显示警告消息
   * @param message 要显示的消息
   */
  showWarning(message: string): void {
    this.show(`⚠️ ${message}`, 2500);
  }

  /**
   * 显示信息消息
   * @param message 要显示的消息
   */
  showInfo(message: string): void {
    this.show(`ℹ️ ${message}`, 2000);
  }
}