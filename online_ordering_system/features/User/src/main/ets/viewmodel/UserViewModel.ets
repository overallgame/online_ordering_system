import { User, AppDataManager ,UserPreferences} from 'common';
import { UserService } from '../service/UserService';

/**
 * 用户ViewModel - 处理用户相关的业务逻辑
 */
@Observed
export class UserViewModel {
  // 用户信息
  user: User | null = null;
  // 用户服务
  private userService: UserService;
  // 同步状态
  isSyncing: boolean = false;
  lastSyncTime: number = 0;

  constructor() {
    this.userService = UserService.getInstance();
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
      const currentUser = AppDataManager.getInstance().getCurrentUser();
      if (currentUser) {
        this.user = currentUser;
      } else {
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

      }
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
      
      // 同步到后端
      await this.syncUserToServer();
      return true;
    } catch (error) {
      console.error('更新头像失败:', error);
      return false;
    }
  }

  /**
   * 同步用户资料到后端
   */
  async syncUserToServer(): Promise<boolean> {
    if (!this.user || !this.user.userId) {
      console.warn('无法同步：用户信息不完整');
      return false;
    }

    if (this.isSyncing) {
      console.warn('正在同步中，请稍候...');
      return false;
    }

    this.isSyncing = true;

    try {
      const response = await this.userService.updateUserProfile(this.user);
      
      if (response.success) {
        this.lastSyncTime = Date.now();
        console.log('用户资料同步成功');
        return true;
      } else {
        console.error('用户资料同步失败:', response.error);
        return false;
      }
    } catch (error) {
      console.error('同步用户资料时发生错误:', error);
      return false;
    } finally {
      this.isSyncing = false;
    }
  }

  // /**
  //  * 从后端获取用户资料
  //  */
  // async loadUserFromServer(): Promise<boolean> {
  //   if (!this.user || !this.user.userId) {
  //     console.warn('无法从服务器加载：用户ID不存在');
  //     return false;
  //   }
  //
  //   if (this.isSyncing) {
  //     console.warn('正在同步中，请稍候...');
  //     return false;
  //   }
  //
  //   this.isSyncing = true;
  //
  //   try {
  //     const response = await this.userService.getUserProfile(this.user.userId);
  //
  //     if (response.success && response.data) {
  //       // 保留本地的登录状态和token
  //       const localUser = this.user;
  //       this.user = response.data;
  //       this.user.isLoggedIn = localUser.isLoggedIn;
  //       this.user.token = localUser.token;
  //       this.user.lastLoginTime = localUser.lastLoginTime;
  //
  //       // 更新本地存储
  //       await AppDataManager.getInstance().setCurrentUser(this.user);
  //       this.lastSyncTime = Date.now();
  //       console.log('从服务器加载用户资料成功');
  //       return true;
  //     } else {
  //       console.error('从服务器加载用户资料失败:', response.error);
  //       return false;
  //     }
  //   } catch (error) {
  //     console.error('从服务器加载用户资料时发生错误:', error);
  //     return false;
  //   } finally {
  //     this.isSyncing = false;
  //   }
  // }

  /**
   * 更新用户资料（本地+后端同步）
   */
  async updateUserProfile(user: User): Promise<boolean> {
    if (!user) {
      return false;
    }

    try {
      // 先更新本地
      this.user = user;
      await AppDataManager.getInstance().setCurrentUser(this.user);
      
      // 再同步到后端
      const syncResult = await this.syncUserToServer();
      
      if (!syncResult) {
        console.warn('本地更新成功，但后端同步失败');
        // 可以选择是否回滚本地更改
      }
      
      return true;
    } catch (error) {
      console.error('更新用户资料失败:', error);
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

  // /**
  //  * 获取同步状态
  //  */
  // getSyncStatus(): { isSyncing: boolean; lastSyncTime: number } {
  //   return {
  //     isSyncing: this.isSyncing,
  //     lastSyncTime: this.lastSyncTime
  //   };
  // }

  // /**
  //  * 检查是否需要同步
  //  */
  // needsSync(): boolean {
  //   // 如果从未同步过，或者距离上次同步超过5分钟，则需要同步
  //   return this.lastSyncTime === 0 || (Date.now() - this.lastSyncTime) > 5 * 60 * 1000;
  // }

  /**
   * 清理资源
   */
  cleanup(): void {
    // 移除监听器
    AppDataManager.getInstance().removeUserListener((user: User | null) => {
      this.user = user;
    });
  }

   copyUser(user: User): User {
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
    newUser.preferences =  new UserPreferences();

    newUser.preferences.theme=user.preferences.theme;
    newUser.preferences.language=user.preferences.language;
    newUser.preferences.autoLogin=user.preferences.autoLogin;
    newUser.preferences.notificationEnabled=user.preferences.notificationEnabled;
    newUser.preferences.defaultPaymentMethod=user.preferences.defaultPaymentMethod;


    return newUser;
  }

}
