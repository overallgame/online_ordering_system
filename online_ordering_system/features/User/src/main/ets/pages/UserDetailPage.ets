import { UserViewModel } from '../viewmodel/UserViewModel';
import { User, UserPreferences, AppDataManager } from 'common';
import { ToastComponent } from '../components/ToastComponent';
import {InfoItem} from '../view/InfoItemView'
@Component
export struct UserDetailPage {
  @Link userViewModel: UserViewModel;
  @Consume('navStack') navStack: NavPathStack;
  @State isEditing: boolean = false;
  @State editUser: User = new User();
  // @State showPhoneDialog: boolean = false;
  // @State showEmailDialog: boolean = false;
  // @State showAddressDialog: boolean = false;
  //@State toastComponent: ToastComponent = new ToastComponent();

  aboutToAppear() {
    this.loadUserInfo();
  }

  async loadUserInfo() {
    // 等待UserViewModel加载用户信息
    await this.userViewModel.loadUserInfo();
    
    const currentUser = this.userViewModel.user;
    if (currentUser) {
      // 由于UserViewModel现在使用监听器，这里只需要更新editUser
      this.editUser = this.copyUser(currentUser);
    } else {
      console.warn('当前没有登录用户');
      // 可以在这里添加跳转到登录页面的逻辑
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
      Image($r('app.media.setting'))
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
      // 头像区域
      this.buildAvatarSection()
      
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
  buildAvatarSection() {
    Column() {
      Stack() {
        Image(this.userViewModel.user?.avatar ? this.userViewModel.user.avatar : $r('app.media.default_avatar'))
          .width(100)
          .height(100)
          .borderRadius(50)
          .border({ width: 3, color: '#FFFFFF' })
          .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 4 })
        
        if (this.isEditing) {
          Image($r('app.media.setting'))
            .width(32)
            .height(32)
            .backgroundColor('#00000080')
            .borderRadius(16)
            .position({ x: 68, y: 68 })
            .onClick(() => {
              this.selectAvatar();
            })
        }
      }
      
      Text('点击更换头像')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 8 })
        .onClick(() => {
          if (this.isEditing) {
            this.selectAvatar();
          }
        })
    }
    .width('100%')
    .padding({ top: 20, bottom: 20 })
    .backgroundColor('#FFFFFF')
    .margin({ top: 16, left: 16, right: 16 })
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
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


      InfoItem({
        label: '用户名',
        value: this.editUser?.username || '未设置',
        onChange: (value: string) => {
          this.editUser.username = value;
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
        label: '注册时间',
        value: this.formatDate(this.editUser?.createTime || 0) || '未设置',
        onChange: null,
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
    this.editUser = this.copyUser(this.userViewModel.user);
  }


  async saveUserInfo() {
    try {
      // 直接通过AppDataManager保存用户信息
      // 这会自动触发监听器更新UserViewModel
      console.error(this.userViewModel.user?.username);
      //await AppDataManager.getInstance().setCurrentUser(this.editUser);
      this.userViewModel.user=this.editUser;
      
      console.error(this.userViewModel.user?.username);
      this.isEditing = false;
      console.error(this.userViewModel.user?.username);
      
      // 显示成功提示
      //this.showToast('保存成功');
    } catch (error) {
      console.error('保存用户信息失败:', error);
      this.showToast('保存失败，请重试');
    }
  }

  selectAvatar() {
    //this.showToast('头像选择功能开发中');
  }

  formatDate(timestamp: number): string {
    if (timestamp === 0) {
      return '未设置';
    }
    const date = new Date(timestamp);
    return date.toLocaleDateString('zh-CN');
  }

  showToast(message: string) {
    //this.toastComponent.show(message);
  }

  // 复制用户对象的方法
  private copyUser(user: User): User {
    if (!user) {
      console.error('copyUser: 用户对象为空');
      return new User();
    }
    
    const newUser = new User();
    newUser.userId = user.userId || '';
    newUser.username = user.username || '';
    newUser.phone = user.phone || '';
    newUser.email = user.email || '';
    newUser.avatar = user.avatar;
    newUser.address = user.address || '';
    newUser.createTime = user.createTime || 0;
    newUser.isLoggedIn = user.isLoggedIn || false;
    newUser.token = user.token;
    newUser.lastLoginTime = user.lastLoginTime || 0;
    newUser.preferences = user.preferences || new UserPreferences();
    return newUser;
  }
}
