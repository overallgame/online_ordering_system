import { User } from '../model/User';
import { DatabaseManager } from '../database/DatabaseManager';
import common from '@ohos.app.ability.common';

export class AppDataManager {
  private static _instance: AppDataManager;
  private _currentUser: User | null = null;
  private _listeners: Array<(user: User | null) => void> = [];
  private dbManager: DatabaseManager = DatabaseManager.getInstance();
  private isInitialized: boolean = false;

  public static getInstance(): AppDataManager {
    if (!AppDataManager._instance) {
      AppDataManager._instance = new AppDataManager();
    }
    return AppDataManager._instance;
  }

  async initialize(context: common.Context): Promise<boolean> {
    if (this.isInitialized) {
      return true;
    }

    try {
      const success = await this.dbManager.initialize(context);
      if (success) {
        await this.loadCurrentUser();
        this.isInitialized = true;
        console.info('AppDataManager initialized successfully');
        return true;
      }
      return false;
    } catch (error) {
      console.error('AppDataManager initialization failed:', error);
      return false;
    }
  }

  async setCurrentUser(user: User | null): Promise<void> {
    this._currentUser = user;

    if (user) {
      await this.dbManager.saveUser(user);
    } else {
      if (this._currentUser) {
        await this.dbManager.logoutUser(this._currentUser.userId);
      }
    }

    this._notifyListeners();
  }

  getCurrentUser(): User | null {
    return this._currentUser;
  }

  async loadCurrentUser(): Promise<void> {
    try {
      const user = await this.dbManager.getCurrentUser();
      console.log(user?.userId+"jjjjj");
      if (user) {
        this._currentUser = user;
        this._notifyListeners();
      }
    } catch (error) {
      console.error('Load current user failed:', error);
    }
  }

  async logout(): Promise<boolean> {
    if (!this._currentUser) {
      console.warn('No current user to logout');
      return false;
    }

    try {
      const success = await this.dbManager.logoutUser(this._currentUser.userId);
      if (success) {
        this._currentUser = null;
        this._notifyListeners();
        console.info('User logged out successfully');
        return true;
      }
      return false;
    } catch (error) {
      console.error('Logout failed:', error);
      return false;
    }
  }

  // 添加检查登录状态的方法
  isLoggedIn(): boolean {
    this.loadCurrentUser()
    return !!this._currentUser && this._currentUser.isLoggedIn;
  }

  // 获取用户 token（用于 API 调用）
  getToken(): string {
    return this._currentUser?.token || '';
  }

  addUserListener(listener: (user: User | null) => void): void {
    this._listeners.push(listener);

    // 立即通知当前状态
    if (this.isInitialized) {
      try {
        listener(this._currentUser);
      } catch (error) {
        console.error('Error in initial user listener call:', error);
      }
    }
  }

  removeUserListener(listener: (user: User | null) => void): void {
    const index = this._listeners.indexOf(listener);
    if (index > -1) {
      this._listeners.splice(index, 1);
    }
  }

  private _notifyListeners(): void {

    this._listeners.forEach(listener => {
      try {
        listener(this._currentUser);
      } catch (error) {
        console.error('Error in user listener:', error);
      }
    });
  }

  // 清理资源
  async cleanup(): Promise<void> {
    this._listeners = [];
    await this.dbManager.close();
    this.isInitialized = false;
  }
}