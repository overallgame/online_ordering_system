import { User, AppDataManager ,UserPreferences} from 'common';

/**
 * 用户ViewModel - 处理用户相关的业务逻辑
 */
@Observed
export class UserViewModel {
  // 用户信息
  user: User | null = null;

  constructor() {
    this.loadUserInfo();
    // 监听AppDataManager的用户变化
    AppDataManager.getInstance().addUserListener((user: User | null) => {
      this.user = user;
    });
  }

  /**
   * 加载用户信息
   */
  async loadUserInfo(): Promise<void> {
    try {
      //const currentUser = AppDataManager.getInstance().getCurrentUser();
      //if (currentUser) {
        //this.user = currentUser;
      //} else {
        // 只有在没有用户数据时才创建默认用户
        this.user = new User();
        this.user.userId = "U123456789"; // 必填，唯一用户ID
        this.user.username = "张三";     // 必填，用户昵称
        this.user.phone = "13800138000"; // 必填，手机号
        this.user.email = "zhangsan@example.com"; // 可选，默认空字符串
        this.user.avatar = "https://example.com/avatar.jpg"; // 可选，头像URL
        this.user.address = "北京市朝阳区"; // 可选，默认地址
        this.user.createTime = Date.now(); // 必填，创建时间戳（鸿蒙建议使用系统时间API）
        this.user.isLoggedIn = true;     // 登录状态
        this.user.token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."; // 登录令牌
        this.user.lastLoginTime = Date.now(); // 最后登录时间

        this.user.preferences = new UserPreferences();
        this.user.preferences.theme = 'dark'; // 主题模式
        this.user.preferences.language = 'en-US'; // 语言设置
        this.user.preferences.notificationEnabled = true; // 通知开关
        this.user.preferences.autoLogin = false; // 自动登录
        
        // 将默认用户保存到AppDataManager
        //await AppDataManager.getInstance().setCurrentUser(this.user);
      //}
    } catch (error) {
      console.error('加载用户信息失败:', error);
    }
  }

  /**
   * 更新用户信息
   */
  updateUser(user: User | null): void {
    this.user = user;
  }

  /**
   * 更新用户头像
   */
  async updateAvatar(avatarUrl: string): Promise<boolean> {
    if (!this.user) {
      return false;
    }

    try {
      this.user.avatar = avatarUrl;
      await AppDataManager.getInstance().setCurrentUser(this.user);
      return true;
    } catch (error) {
      console.error('更新头像失败:', error);
      return false;
    }
  }

  /**
   * 更新用户名
   */
  async updateUsername(username: string): Promise<boolean> {
    if (!this.user) {
      return false;
    }

    try {
      this.user.username = username;
      await AppDataManager.getInstance().setCurrentUser(this.user);
      return true;
    } catch (error) {
      console.error('更新用户名失败:', error);
      return false;
    }
  }

  /**
   * 更新手机号
   */
  async updatePhone(phone: string): Promise<boolean> {
    if (!this.user) {
      return false;
    }

    try {
      this.user.phone = phone;
      await AppDataManager.getInstance().setCurrentUser(this.user);
      return true;
    } catch (error) {
      console.error('更新手机号失败:', error);
      return false;
    }
  }

  /**
   * 更新邮箱
   */
  async updateEmail(email: string): Promise<boolean> {
    if (!this.user) {
      return false;
    }

    try {
      this.user.email = email;
      await AppDataManager.getInstance().setCurrentUser(this.user);
      return true;
    } catch (error) {
      console.error('更新邮箱失败:', error);
      return false;
    }
  }

  /**
   * 更新地址
   */
  async updateAddress(address: string): Promise<boolean> {
    if (!this.user) {
      return false;
    }

    try {
      this.user.address = address;
      await AppDataManager.getInstance().setCurrentUser(this.user);
      return true;
    } catch (error) {
      console.error('更新地址失败:', error);
      return false;
    }
  }

  /**
   * 检查用户是否已登录
   */
  isLoggedIn(): boolean {
    return this.user !== null && this.user.isLoggedIn;
  }

  /**
   * 获取用户显示名称
   */
  getDisplayName(): string {
    if (!this.user) {
      return '未登录';
    }
    return this.user.username || this.user.phone || '用户';
  }

  /**
   * 获取用户头像URL
   */
  getAvatarUrl(): string {
    if (!this.user || !this.user.avatar) {
      return '';
    }
    return this.user.avatar;
  }

  /**
   * 清理资源
   */
  cleanup(): void {
    // 移除监听器
    AppDataManager.getInstance().removeUserListener((user: User | null) => {
      this.user = user;
    });
  }
}
