import { AppDataManager } from 'common';

export class AuthStateService {
  private static instance: AuthStateService;
  private appDataManager: AppDataManager = AppDataManager.getInstance();

  public static getInstance(): AuthStateService {
    if (!AuthStateService.instance) {
      AuthStateService.instance = new AuthStateService();
    }
    return AuthStateService.instance;
  }

  async checkLoginStatus(): Promise<boolean> {
    try {
      // 先尝试加载当前用户数据
      await this.appDataManager.loadCurrentUser();
      
      // 然后检查登录状态
      const isLoggedIn = this.appDataManager.isLoggedIn();
      
      return isLoggedIn;
    } catch (error) {
      console.error('Check login status error:', error);
      return false;
    }
  }
}
