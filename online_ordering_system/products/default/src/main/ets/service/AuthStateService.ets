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
      const isLoggedIn = this.appDataManager.isLoggedIn();

      if (isLoggedIn) {
        await this.appDataManager.loadCurrentUser();
      }

      return isLoggedIn;
    } catch (error) {
      console.error('Check login status error:', error);
      return false;
    }
  }
}
