import { AuthService, LoginRequest, AuthResponse } from '../service/AuthService';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct LoginPage {
  private authService: AuthService = new AuthService();
  @State loginRequest: LoginRequest = new LoginRequest();
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  build() {
    Column() {
      // 头部标题
      Text('欢迎登录')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 80, bottom: 50 })

      // 账号输入框
      TextInput({
        placeholder: '请输入用户名或手机号',
        text: this.loginRequest.username
      })
        .width('90%')
        .height(50)
        .padding(10)
        .borderRadius(10)
        .backgroundColor(Color.White)
        .onChange((value: string) => {
          this.loginRequest.username = value;
          this.errorMessage = ''; // 清除错误信息
        })
        .margin({ bottom: 20 })

      // 密码输入框
      TextInput({
        placeholder: '请输入密码',
        text: this.loginRequest.password
      })
        .width('90%')
        .height(50)
        .padding(10)
        .borderRadius(10)
        .backgroundColor(Color.White)
        .type(InputType.Password)
        .onChange((value: string) => {
          this.loginRequest.password = value;
          this.errorMessage = ''; // 清除错误信息
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

      // 登录按钮
      Button('登录', { type: ButtonType.Capsule, stateEffect: true })
        .width('90%')
        .height(50)
        .backgroundColor('#007AFF')
        .fontColor(Color.White)
        .fontSize(18)
        .enabled(!this.isLoading)
        .onClick(() => {
          this.handleLogin();
        })
        .margin({ bottom: 20 })

      // 加载状态
      if (this.isLoading) {
        LoadingProgress()
          .width(30)
          .height(30)
          .margin({ bottom: 20 })
      }

      // 注册链接
      Row() {
        Text('还没有账号？')
          .fontSize(14)
          .fontColor('#666')
        Text('立即注册')
          .fontSize(14)
          .fontColor('#007AFF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/RegisterPage' });
          })
      }
      .margin({ top: 30 })

      // 填充剩余空间
      Blank()

    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#F5F5F5')
  }

  // 处理登录
  private async handleLogin(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const response: AuthResponse = await this.authService.login(this.loginRequest);

      if (response.success) {
        // 登录成功，跳转到首页
        router.replaceUrl({ url: 'pages/HomePage' });
      } else {
        this.errorMessage = response.message;
      }
    } catch (error) {
      console.error('Login error:', error);
      this.errorMessage = '登录失败，请稍后重试';
    } finally {
      this.isLoading = false;
    }
  }

}