import { User } from '../model/User';
import { DatabaseManager } from '../database/DatabaseManager';
import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

export class AppDataManager {
  private static _instance: AppDataManager;
  private _currentUser: User | null = null;
  private _listeners: Array<(user: User | null) => void> = [];
  private dbManager: DatabaseManager = DatabaseManager.getInstance();
  private preferences?: dataPreferences.Preferences;
  private isInitialized: boolean = false;
  
  // Preferences 键名常量
  private static readonly PREF_NAME = 'user_preferences';
  private static readonly KEY_USER_ID = 'user_id';
  private static readonly KEY_USERNAME = 'username';
  private static readonly KEY_TOKEN = 'token';
  private static readonly KEY_IS_LOGGED_IN = 'is_logged_in';
  private static readonly KEY_LAST_LOGIN_TIME = 'last_login_time';

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
      this.preferences = await dataPreferences.getPreferences(context, AppDataManager.PREF_NAME);
      await this.dbManager.initialize(context);
      await this.loadCurrentUser();
      
      this.isInitialized = true;
      console.info('AppDataManager initialized successfully');
      return true;
    } catch (error) {
      console.error('AppDataManager initialization failed:', error);
      return false;
    }
  }

  async setCurrentUser(user: User | null): Promise<void> {
    this._currentUser = user;

    if (user) {
      await this.dbManager.saveUser(user);
      await this.saveUserToPreferences(user);
    } else {
      if (this._currentUser) {
        await this.dbManager.logoutUser(this._currentUser.userId);
      }
      await this.clearUserFromPreferences();
    }

    this._notifyListeners();
  }

  async loadCurrentUser(): Promise<void> {
    try {
      const user = await this.dbManager.getCurrentUser();
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
      await this.dbManager.logoutUser(this._currentUser.userId);
      await this.clearUserFromPreferences();
      
      this._currentUser = null;
      this._notifyListeners();
      console.info('User logged out successfully');
      return true;
    } catch (error) {
      console.error('Logout failed:', error);
      return false;
    }
  }

  getCurrentUser(): User | null {
    return this._currentUser;
  }

  isLoggedIn(): boolean {
    return !!this._currentUser && this._currentUser.isLoggedIn;
  }

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

  private async saveUserToPreferences(user: User): Promise<void> {
    if (!this.preferences) {
      console.warn('Preferences not initialized');
      return;
    }

    try {
      await this.preferences.put(AppDataManager.KEY_USER_ID, user.userId);
      await this.preferences.put(AppDataManager.KEY_USERNAME, user.username);
      await this.preferences.put(AppDataManager.KEY_TOKEN, user.token || '');
      await this.preferences.put(AppDataManager.KEY_IS_LOGGED_IN, user.isLoggedIn);
      await this.preferences.put(AppDataManager.KEY_LAST_LOGIN_TIME, user.lastLoginTime);
      await this.preferences.flush();
      console.info('User data saved to preferences');
    } catch (error) {
      console.error('Failed to save user to preferences:', error);
    }
  }

  private async loadUserFromPreferences(): Promise<void> {
    if (!this.preferences) {
      console.warn('Preferences not initialized');
      return;
    }

    try {
      const isLoggedIn = await this.preferences.get(AppDataManager.KEY_IS_LOGGED_IN, false) as boolean;
      
      if (isLoggedIn) {
        const userId = await this.preferences.get(AppDataManager.KEY_USER_ID, '') as string;
        const username = await this.preferences.get(AppDataManager.KEY_USERNAME, '') as string;
        const token = await this.preferences.get(AppDataManager.KEY_TOKEN, '') as string;
        const lastLoginTime = await this.preferences.get(AppDataManager.KEY_LAST_LOGIN_TIME, 0) as number;

        if (userId && username) {
          const user = new User();
          user.userId = userId;
          user.username = username;
          user.token = token;
          user.isLoggedIn = isLoggedIn;
          user.lastLoginTime = lastLoginTime;

          this._currentUser = user;
          console.info('User loaded from preferences');
        }
      }
    } catch (error) {
      console.error('Failed to load user from preferences:', error);
    }
  }

  private async clearUserFromPreferences(): Promise<void> {
    if (!this.preferences) {
      console.warn('Preferences not initialized');
      return;
    }

    try {
      await this.preferences.delete(AppDataManager.KEY_USER_ID);
      await this.preferences.delete(AppDataManager.KEY_USERNAME);
      await this.preferences.delete(AppDataManager.KEY_TOKEN);
      await this.preferences.delete(AppDataManager.KEY_IS_LOGGED_IN);
      await this.preferences.delete(AppDataManager.KEY_LAST_LOGIN_TIME);
      await this.preferences.flush();
      console.info('User data cleared from preferences');
    } catch (error) {
      console.error('Failed to clear user from preferences:', error);
    }
  }

  async isLoggedInFromPreferences(): Promise<boolean> {
    if (!this.preferences) {
      return false;
    }

    try {
      const isLoggedIn = await this.preferences.get(AppDataManager.KEY_IS_LOGGED_IN, false) as boolean;
      return isLoggedIn;
    } catch (error) {
      console.error('Failed to check login status from preferences:', error);
      return false;
    }
  }

  async getTokenFromPreferences(): Promise<string> {
    if (!this.preferences) {
      return '';
    }

    try {
      const token = await this.preferences.get(AppDataManager.KEY_TOKEN, '') as string;
      return token;
    } catch (error) {
      console.error('Failed to get token from preferences:', error);
      return '';
    }
  }

  async cleanup(): Promise<void> {
    this._listeners = [];
    await this.dbManager.close();
    this.isInitialized = false;
  }
}