/**
 * Toast提示组件
 */
@Component
export struct ToastComponent {
  @State message: string = '';
  @State isVisible: boolean = false;
  @State timer: number = -1;

  show(message: string, duration: number = 2000) {
    this.message = message;
    this.isVisible = true;
    
    // 清除之前的定时器
    if (this.timer !== -1) {
      clearTimeout(this.timer);
    }
    
    // 设置新的定时器
    this.timer = setTimeout(() => {
      this.hide();
    }, duration);
  }

  hide() {
    this.isVisible = false;
    if (this.timer !== -1) {
      clearTimeout(this.timer);
      this.timer = -1;
    }
  }

  build() {
    if (this.isVisible) {
      Text(this.message)
        .fontSize(14)
        .fontColor('#FFFFFF')
        .backgroundColor('#00000080')
        .borderRadius(20)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .position({ x: '50%', y: '80%' })
        .translate({ x: -50, y: -50 })
        .zIndex(9999)
        .animation({
          duration: 300,
          curve: Curve.EaseInOut
        })
    }
  }
}
