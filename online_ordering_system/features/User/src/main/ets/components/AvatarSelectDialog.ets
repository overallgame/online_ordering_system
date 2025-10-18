import { AvatarUploadService } from '../service/AvatarUploadService';

/**
 * 头像选择对话框组件
 */
@Component
export struct AvatarSelectDialog {
  @State isUploading: boolean = false;
  onAvatarSelected?: (avatarUri: string) => void;
  onCancel?: () => void;

  private avatarUploadService: AvatarUploadService = AvatarUploadService.getInstance();


  /**
   * 从相册选择
   */
  async selectFromGallery() {
    try {
      this.isUploading = true;
      const avatarUri = await this.avatarUploadService.selectAndUploadAvatar();
      if (avatarUri) {
        this.onAvatarSelected?.(avatarUri);
      }
    } catch (error) {
      console.error('选择头像失败:', error);
    } finally {
      this.isUploading = false;
    }
  }

  /**
   * 拍照
   */
  async takePhoto() {
    try {
      this.isUploading = true;
      const avatarUri = await this.avatarUploadService.takePhoto();
      if (avatarUri) {
        this.onAvatarSelected?.(avatarUri);
      }
    } catch (error) {
      console.error('拍照失败:', error);
    } finally {
      this.isUploading = false;
    }
  }

  /**
   * 取消选择
   */
  cancel() {
    this.onCancel?.();
  }

  build() {
    Stack() {
        // 半透明背景
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(0.5)
          .onClick(() => this.cancel())

        // 对话框内容
        Column() {
          // 标题
          Text('选择头像')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#000000')
            .margin({ bottom: 20 })

          // 选项按钮
          Column() {
            // 从相册选择
            Row() {
              Text('📷')
                .fontSize(24)
                .margin({ right: 12 })
              
              Text('从相册选择')
                .fontSize(16)
                .fontColor('#000000')
                .layoutWeight(1)
              
              if (this.isUploading) {
                LoadingProgress()
                  .width(20)
                  .height(20)
              }
            }
            .width('100%')
            .height(50)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .onClick(() => this.selectFromGallery())
            .enabled(!this.isUploading)

            // 拍照
            Row() {
              Text('📸')
                .fontSize(24)
                .margin({ right: 12 })
              
              Text('拍照')
                .fontSize(16)
                .fontColor('#000000')
                .layoutWeight(1)
            }
            .width('100%')
            .height(50)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .margin({ top: 12 })
            .onClick(() => this.takePhoto())
            .enabled(!this.isUploading)

            // 取消按钮
            Text('取消')
              .fontSize(16)
              .fontColor('#666666')
              .width('100%')
              .height(50)
              .textAlign(TextAlign.Center)
              .margin({ top: 20 })
              .onClick(() => this.cancel())
          }
          .width('100%')
        }
        .width('80%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius: 10, color: '#00000020', offsetX: 0, offsetY: 4 })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000)
  }
}
