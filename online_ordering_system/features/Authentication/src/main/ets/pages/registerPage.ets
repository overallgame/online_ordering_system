import { AuthService, RegisterRequest, AuthResponse } from '../service/AuthService';

@Component
export struct RegisterPage {
  @Consume('mainPathStack') mainPathStack: NavPathStack;
  private authService: AuthService = new AuthService();
  @State registerRequest: RegisterRequest = new RegisterRequest();
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State successMessage: string = '';

  build() {
    Column() {
      Text('用户注册')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 60, bottom: 40 })

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
        .margin({ bottom: 20 })

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
        .margin({ bottom: 20 })

      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor('#ff4757')
          .width('90%')
          .textAlign(TextAlign.Start)
          .margin({ bottom: 10 })
      }

      if (this.successMessage) {
        Text(this.successMessage)
          .fontSize(14)
          .fontColor('#2ed573')
          .width('90%')
          .textAlign(TextAlign.Start)
          .margin({ bottom: 10 })
      }

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

      if (this.isLoading) {
        LoadingProgress()
          .width(30)
          .height(30)
          .margin({ bottom: 20 })
      }

      Row() {
        Text('已有账号？')
          .fontSize(14)
          .fontColor('#666')
        Text('立即登录')
          .fontSize(14)
          .fontColor('#007AFF')
          .onClick(() => {
            this.mainPathStack.pop();
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

  private async handleRegister(): Promise<void> {
    this.isLoading = true;
    this.clearMessages();

    try {
      const response: AuthResponse = await this.authService.register(this.registerRequest);

      if (response.success) {
        this.successMessage = '注册成功！请返回登录页面登录';
        setTimeout(() => {
          this.mainPathStack.pop();
        }, 2000);
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

  private isFormValid(): boolean {
    return this.registerRequest.username.trim().length > 0 &&
      this.registerRequest.password.trim().length >= 6
  }

  private clearMessages(): void {
    this.errorMessage = '';
    this.successMessage = '';
  }
}