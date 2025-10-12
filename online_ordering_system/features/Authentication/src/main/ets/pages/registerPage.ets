import { AuthService, RegisterRequest, AuthResponse } from '../service/AuthService';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct RegisterPage {
  private authService: AuthService = new AuthService();
  @State registerRequest: RegisterRequest = new RegisterRequest();
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State successMessage: string = '';

  build() {
    Column() {
      // 头部标题
      Text('用户注册')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 60, bottom: 40 })

      // 用户名输入框
      TextInput({
        placeholder: '请输入用户名',
        text: this.registerRequest.username
      })
        .width('90%')
        .height(50)
        .padding(10)
        .borderRadius(10)
        .backgroundColor(Color.White)
        .onChange((value: string) => {
          this.registerRequest.username = value;
          this.clearMessages();
        })
        .margin({ bottom: 15 })

      // 手机号输入框
      TextInput({
        placeholder: '请输入手机号',
        text: this.registerRequest.phone
      })
        .width('90%')
        .height(50)
        .padding(10)
        .borderRadius(10)
        .backgroundColor(Color.White)
        .onChange((value: string) => {
          this.registerRequest.phone = value;
          this.clearMessages();
        })
        .margin({ bottom: 15 })

      // 邮箱输入框
      TextInput({
        placeholder: '请输入邮箱（可选）',
        text: this.registerRequest.email
      })
        .width('90%')
        .height(50)
        .padding(10)
        .borderRadius(10)
        .backgroundColor(Color.White)
        .onChange((value: string) => {
          this.registerRequest.email = value;
          this.clearMessages();
        })
        .margin({ bottom: 15 })

      // 密码输入框
      TextInput({
        placeholder: '请输入密码',
        text: this.registerRequest.password
      })
        .width('90%')
        .height(50)
        .padding(10)
        .borderRadius(10)
        .backgroundColor(Color.White)
        .type(InputType.Password)
        .onChange((value: string) => {
          this.registerRequest.password = value;
          this.clearMessages();
        })
        .margin({ bottom: 15 })

      // 确认密码输入框
      TextInput({
        placeholder: '请确认密码',
        text: this.registerRequest.confirmPassword
      })
        .width('90%')
        .height(50)
        .padding(10)
        .borderRadius(10)
        .backgroundColor(Color.White)
        .type(InputType.Password)
        .onChange((value: string) => {
          this.registerRequest.confirmPassword = value;
          this.clearMessages();
        })
        .margin({ bottom: 20 })

      // 错误信息显示
      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor('#ff4757')
          .width('90%')
          .textAlign(TextAlign.Start)
          .margin({ bottom: 10 })
      }

      // 成功信息显示
      if (this.successMessage) {
        Text(this.successMessage)
          .fontSize(14)
          .fontColor('#2ed573')
          .width('90%')
          .textAlign(TextAlign.Start)
          .margin({ bottom: 10 })
      }

      // 注册按钮
      Button('注册', { type: ButtonType.Capsule, stateEffect: true })
        .width('90%')
        .height(50)
        .backgroundColor('#007AFF')
        .fontColor(Color.White)
        .fontSize(18)
        .enabled(!this.isLoading && this.isFormValid())
        .onClick(() => {
          this.handleRegister();
        })
        .margin({ bottom: 20 })

      // 加载状态
      if (this.isLoading) {
        LoadingProgress()
          .width(30)
          .height(30)
          .margin({ bottom: 20 })
      }

      // 登录链接
      Row() {
        Text('已有账号？')
          .fontSize(14)
          .fontColor('#666')
        Text('立即登录')
          .fontSize(14)
          .fontColor('#007AFF')
          .onClick(() => {
            router.back();
          })
      }
      .margin({ top: 30 })

      Blank()
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#F5F5F5')
  }

  // 处理注册
  private async handleRegister(): Promise<void> {
    this.isLoading = true;
    this.clearMessages();

    try {
      const response: AuthResponse = await this.authService.register(this.registerRequest);

      if (response.success) {
        this.successMessage = '注册成功！正在跳转...';
        // 注册成功后自动登录并跳转
        setTimeout(() => {
          router.replaceUrl({ url: 'pages/HomePage' });
        }, 1500);
      } else {
        this.errorMessage = response.message;
      }
    } catch (error) {
      console.error('Register error:', error);
      this.errorMessage = '注册失败，请稍后重试';
    } finally {
      this.isLoading = false;
    }
  }

  // 检查表单是否有效
  private isFormValid(): boolean {
    return this.registerRequest.username.trim().length > 0 &&
      this.registerRequest.phone.trim().length > 0 &&
      this.registerRequest.password.trim().length >= 6 &&
      this.registerRequest.password === this.registerRequest.confirmPassword
  }

  // 清除消息
  private clearMessages(): void {
    this.errorMessage = '';
    this.successMessage = '';
  }
}