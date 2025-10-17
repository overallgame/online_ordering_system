import { AuthService, LoginRequest, AuthResponse } from '../service/AuthService';

@Component
export struct LoginPage {
  @Consume('mainPathStack') mainPathStack: NavPathStack;
  private authService: AuthService = new AuthService();
  @State loginRequest: LoginRequest = new LoginRequest();
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  build() {
    NavDestination(){
      Column() {
        Text('欢迎登录')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 80, bottom: 50 })

        TextInput({
          placeholder: '请输入用户名或手机号',
          text: this.loginRequest.account
        })
          .width('90%')
          .height(50)
          .padding(10)
          .borderRadius(10)
          .backgroundColor(Color.White)
          .onChange((value: string) => {
            this.loginRequest.account = value;
            this.errorMessage = '';
          })
          .margin({ bottom: 20 })

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
            this.errorMessage = '';
          })
          .margin({ bottom: 20 })

        if (this.errorMessage) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#ff4757')
            .width('90%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 10 })
        }

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

        if (this.isLoading) {
          LoadingProgress()
            .width(30)
            .height(30)
            .margin({ bottom: 20 })
        }

        Row() {
          Text('还没有账号？')
            .fontSize(14)
            .fontColor('#666')
          Text('立即注册')
            .fontSize(14)
            .fontColor('#007AFF')
            .onClick(() => {
              this.mainPathStack.pushPathByName('register', null);
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
    .hideTitleBar(true)
  }

  // 处理登录
  private async handleLogin(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const response: AuthResponse = await this.authService.login(this.loginRequest);

      if (response.success) {
        this.mainPathStack.pop();
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