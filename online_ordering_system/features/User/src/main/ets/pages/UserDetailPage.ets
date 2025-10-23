import { UserViewModel } from '../viewmodel/UserViewModel';
import { User, UserPreferences, AppDataManager } from 'common';
import { ToastComponent } from '../components/ToastComponent';
import { InfoItem } from '../view/InfoItemView';
import { AvatarUploadService } from '../service/AvatarUploadService';
@Component
export struct UserDetailPage {
  @Link userViewModel: UserViewModel;
  @Consume('navStack') navStack: NavPathStack;
  @State isEditing: boolean = false;
  @State editUser: User = new User();
  @State isAvatarDialogVisible: boolean = false;

  aboutToAppear() {
    this.loadUserInfo();
  }

  async loadUserInfo() {
    const currentUser = this.userViewModel.user;
    if (currentUser) {
      // 由于UserViewModel现在使用监听器，这里只需要更新editUser
      this.editUser = this.userViewModel.copyUser(currentUser);
      console.log("test："+this.editUser.sex);
      console.log("test："+this.editUser.username);
    } else {
      console.warn('当前没有登录用户');
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
        this.buildTopBar()
        
        // 个人信息详情
        Scroll(){
          this.buildUserDetailContent()
        }

        // 头像选择对话框
        if (this.isAvatarDialogVisible) {
          this.buildAvatarSelectDialog()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('个人信息')
    .hideTitleBar(true)
  }

  @Builder
  buildTopBar() {
    Row() {
      Image($r('app.media.back'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.navStack.pop();
        })
      
      Text('个人信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      if (this.isEditing) {
        Text('保存')
          .fontSize(16)
          .fontColor('#007AFF')
          .onClick(() => {
            this.saveUserInfo();
          })
      } else {
        Text('编辑')
          .fontSize(16)
          .fontColor('#007AFF')
          .onClick(() => {
            this.startEdit();
          })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildUserDetailContent() {
    Column() {
      // 基本信息
      this.buildBasicInfoSection()
      
      // 联系方式
      this.buildContactSection()
      
      // 其他信息
      this.buildOtherInfoSection()
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  buildBasicInfoSection() {
    Column() {
      Text('基本信息')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      Row() {
        Text("头像")
          .fontSize(14)
          .fontColor('#666666')
          .width(80)
          .textAlign(TextAlign.Start)
        Column() {
          Image(this.editUser.avatar ? this.editUser.avatar : $r('app.media.default_avatar'))
            .width(60)
            .height(60)
            .borderRadius(50)
            .border({ width: 3, color: '#FFFFFF' })
            .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 4 })
            .objectFit(ImageFit.Cover)
            .margin({right:10})
          if(this.isEditing)
          {
            Text('点击更换头像')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 8 })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.End)
        .onClick(() => {
          if (this.isEditing) {
            this.selectAvatar();
          }
        })
      }


      InfoItem({
        label: '用户名',
        value: this.editUser?.username || '未设置',
        onChange: (value: string) => {
          this.editUser.username = value;
        },
        isEditing: this.isEditing,
        readonly:false
      })

      // 性别选择
      this.buildSexSelector()

    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .backgroundColor('#FFFFFF')
    .margin({ top: 16, left: 16, right: 16 })
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildContactSection() {
    Column() {
      Text('联系方式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      InfoItem({
        label: '手机号',
        value: this.editUser?.phone || '未设置',
        onChange: (value: string) => {
          this.editUser.phone = value;
        },
        isEditing: this.isEditing,
        readonly:false
      })

      InfoItem({
        label: '邮箱',
        value: this.editUser?.email || '未设置',
        onChange: (value: string) => {
          this.editUser.email = value;
        },
        isEditing: this.isEditing,
        readonly:false
      })



    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .backgroundColor('#FFFFFF')
    .margin({ top: 16, left: 16, right: 16 })
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildOtherInfoSection() {
    Column() {
      Text('其他信息')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      InfoItem({
        label: '地址',
        value: this.editUser?.address || '未设置',
        onChange: (value: string) => {
          this.editUser.address = value;
        },
        isEditing: this.isEditing,
        readonly:false
      })


      InfoItem({
        label: '登录时间',
        value: this.formatDate(this.editUser?.lastLoginTime || 0) || '未设置',
        onChange: null,
        isEditing: this.isEditing,
        readonly:false
      })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .backgroundColor('#FFFFFF')
    .margin({ top: 16, left: 16, right: 16, bottom: 20 })
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildSexSelector() {
    Row() {
      Text('性别')
        .fontSize(14)
        .fontColor('#666666')
        .width(80)
        .textAlign(TextAlign.Start)
      
      if (this.isEditing) {
        Row() {
          Button('男')
            .fontSize(14)
            .fontColor(this.editUser.sex === '男' ? '#FFFFFF' : '#007AFF')
            .backgroundColor(this.editUser.sex === '男' ? '#007AFF' : '#F0F0F0')
            .borderRadius(16)
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            .onClick(() => {
              this.editUser.sex = '男';
            })
          
          Button('女')
            .fontSize(14)
            .fontColor(this.editUser.sex === '女' ? '#FFFFFF' : '#007AFF')
            .backgroundColor(this.editUser.sex === '女' ? '#007AFF' : '#F0F0F0')
            .borderRadius(16)
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            .margin({ left: 12 })
            .onClick(() => {
              this.editUser.sex = '女';
            })
          
          Button('未知')
            .fontSize(14)
            .fontColor(this.editUser.sex === '未知' ? '#FFFFFF' : '#007AFF')
            .backgroundColor(this.editUser.sex === '未知' ? '#007AFF' : '#F0F0F0')
            .borderRadius(16)
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            .margin({ left: 12 })
            .onClick(() => {
              this.editUser.sex = '未知';
            })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)
      } else {
        Text(this.editUser.sex? this.editUser.sex:"未设置")
          .fontSize(16)
          .fontColor('#000000')
          .layoutWeight(1)
          .textAlign(TextAlign.End)
          .margin({right:20})
      }
    }
    .width('100%')
    .height(50)
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 16 })
  }

  @Builder
  buildInfoItem(label: string, value: string, onChange?: (value: string) => void, readonly: boolean = false) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .width(80)
        .textAlign(TextAlign.Start)
      
      if (this.isEditing && !readonly && onChange) {
        TextInput({ placeholder: `请输入${label}` })
          .onChange(onChange)
          .fontSize(16)
          .fontColor('#000000')
          .backgroundColor('#F8F8F8')
          .borderRadius(8)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .layoutWeight(1)
      } else {
        Text(value)
          .fontSize(16)
          .fontColor('#000000')
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
    }
    .width('100%')
    .height(50)
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 16 })
  }

  // 编辑相关方法
  startEdit() {
    if (!this.userViewModel.user) {
      console.error('无法开始编辑：用户信息为空');
      this.showToast('用户信息加载失败，请重试');
      return;
    }
    
    this.isEditing = true;
    this.editUser = this.userViewModel.copyUser(this.userViewModel.user);
  }


  async saveUserInfo() {
    try {
      // 显示保存中状态
      this.showToast('正在保存...');
      
      // 使用UserViewModel的updateUserProfile方法，这会同时更新本地和同步到后端
      const success = await this.userViewModel.updateUserProfile(this.editUser);
      
      if (success) {
        this.isEditing = false;
        this.showToast('保存成功');
      } else {
        this.showToast('保存失败，请重试');
      }
    } catch (error) {
      console.error('保存用户信息失败:', error);
      this.showToast('保存失败，请重试');
    }
  }

  selectAvatar() {
    this.isAvatarDialogVisible = true;
  }

  /**
   * 构建头像选择对话框
   */
  @Builder
  buildAvatarSelectDialog() {
    Stack() {
      // 半透明背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')
        .opacity(0.5)
        .onClick(() => {
          this.isAvatarDialogVisible = false;
        })

      // 底部对话框
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
          }
          .width('100%')
          .height(50)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .onClick(() => {
            this.selectFromGallery();
          })

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
          .onClick(() => {
            this.takePhoto();
          })

          // 取消按钮
          Text('取消')
            .fontSize(16)
            .fontColor('#666666')
            .width('100%')
            .height(50)
            .textAlign(TextAlign.Center)
            .margin({ top: 20 })
            .onClick(() => {
              this.isAvatarDialogVisible = false;
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 12, topRight: 12 })
      .position({ x: 0, y: '60%' })
      .shadow({ radius: 10, color: '#00000020', offsetX: 0, offsetY: -4 })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }

  /**
   * 从相册选择头像
   */
  async selectFromGallery() {
    try {
      const avatarUploadService = AvatarUploadService.getInstance();
      const avatarUri = await avatarUploadService.selectAndUploadAvatar();
      
      if (avatarUri) {
        this.editUser.avatar = avatarUri;
        this.isAvatarDialogVisible = false;
        this.showToast('头像已更新');
      }
    } catch (error) {
      console.error('选择头像失败:', error);
      this.showToast('选择头像失败');
    }
  }

  /**
   * 拍照选择头像
   */
  async takePhoto() {
    try {
      const avatarUploadService = AvatarUploadService.getInstance();
      const avatarUri = await avatarUploadService.takePhoto();
      
      if (avatarUri) {
        this.editUser.avatar = avatarUri;
        this.isAvatarDialogVisible = false;
        this.showToast('头像已更新');
      } else {
        this.showToast('拍照功能暂未实现');
      }
    } catch (error) {
      console.error('拍照失败:', error);
      this.showToast('拍照失败');
    }
  }

  formatDate(timestamp: number): string {
    if (timestamp === 0) {
      return '未设置';
    }
    const date = new Date(timestamp);
    return date.toLocaleDateString('zh-CN');
  }

  showToast(message: string) {
    ToastComponent.getInstance().show(message);
  }


  // 复制用户对象的方法

}
