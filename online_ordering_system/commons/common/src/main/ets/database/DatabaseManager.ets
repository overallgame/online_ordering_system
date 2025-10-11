import relationalStore from '@ohos.data.relationalStore';
import { User, UserPreferences, PaymentMethod } from '../model/User';
import common from '@ohos.app.ability.common';

export class DatabaseManager {
  private static instance: DatabaseManager;
  private rdbStore: relationalStore.RdbStore | null = null;
  private readonly DB_NAME: string = 'food_delivery.db';

  public static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager();
    }
    return DatabaseManager.instance;
  }

  async initialize(context: common.Context): Promise<boolean> {
    try {
      const config: relationalStore.StoreConfig = {
        name: this.DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      };

      this.rdbStore = await relationalStore.getRdbStore(context, config);
      await this.createTables();
      console.info('Database initialized successfully');
      return true;
    } catch (error) {
      console.error('Database initialization failed:', error);
      return false;
    }
  }

  private async createTables(): Promise<void> {
    if (!this.rdbStore) {
      return;
    }

    const userTableSql = `
      CREATE TABLE IF NOT EXISTS users (
        user_id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        avatar TEXT,
        address TEXT,
        token TEXT,
        preferences TEXT,
        created_at INTEGER,
        updated_at INTEGER,
        last_login INTEGER,
        is_logged_in INTEGER DEFAULT 0
      )
    `;

    try {
      await this.rdbStore.executeSql(userTableSql);
      console.info('User table created successfully');
    } catch (error) {
      console.error('Create table failed:', error);
    }
  }

  async saveUser(user: User): Promise<boolean> {
    if (!this.rdbStore) {
      return false;
    }

    try {
      const valuesBucket: relationalStore.ValuesBucket = {
        'user_id': user.userId,
        'username': user.username,
        'phone': user.phone || '',
        'email': user.email || '',
        'avatar': user.avatar || '',
        'address': user.address || '',
        'token': user.token || '',
        'preferences': JSON.stringify({
          theme: user.preferences.theme,
          language: user.preferences.language,
          notificationEnabled: user.preferences.notificationEnabled,
          autoLogin: user.preferences.autoLogin,
          defaultPaymentMethod: user.preferences.defaultPaymentMethod
        }),
        'created_at': user.createTime,
        'updated_at': Date.now(),
        'last_login': user.lastLoginTime,
        'is_logged_in': user.isLoggedIn ? 1 : 0
      };

      // 检查用户是否已存在
      const existingUser = await this.getUserById(user.userId);
      if (existingUser) {
        // 更新现有用户
        const predicates = new relationalStore.RdbPredicates('users');
        predicates.equalTo('user_id', user.userId);
        await this.rdbStore.update(valuesBucket, predicates);
      } else {
        // 插入新用户
        await this.rdbStore.insert('users', valuesBucket);
      }

      console.info('User saved successfully:', user.userId);
      return true;
    } catch (error) {
      console.error('Save user failed:', error);
      return false;
    }
  }

  async getUserById(userId: string): Promise<User | null> {
    if (!this.rdbStore) {
      return null;
    }

    try {
      const predicates = new relationalStore.RdbPredicates('users');
      predicates.equalTo('user_id', userId);

      const resultSet = await this.rdbStore.query(predicates, ['*']);

      if (resultSet.goToFirstRow()) {
        return this.resultSetToUser(resultSet);
      }

      return null;
    } catch (error) {
      console.error('Get user by id failed:', error);
      return null;
    }
  }

  async getCurrentUser(): Promise<User | null> {
    if (!this.rdbStore) {
      return null;
    }

    try {
      const predicates = new relationalStore.RdbPredicates('users');
      predicates.equalTo('is_logged_in', 1);

      const resultSet = await this.rdbStore.query(predicates, ['*']);

      if (resultSet.goToFirstRow()) {
        return this.resultSetToUser(resultSet);
      }

      return null;
    } catch (error) {
      console.error('Get current user failed:', error);
      return null;
    }
  }

  async logoutUser(userId: string): Promise<boolean> {
    if (!this.rdbStore) {
      return false;
    }

    try {
      const valuesBucket: relationalStore.ValuesBucket = {
        'token': '',
        'is_logged_in': 0,
        'updated_at': Date.now()
      };

      const predicates = new relationalStore.RdbPredicates('users');
      predicates.equalTo('user_id', userId);

      await this.rdbStore.update(valuesBucket, predicates);
      console.info('User logged out successfully:', userId);
      return true;
    } catch (error) {
      console.error('Logout user failed:', error);
      return false;
    }
  }

  async clearAllUsers(): Promise<boolean> {
    if (!this.rdbStore) {
      return false;
    }

    try {
      const predicates = new relationalStore.RdbPredicates('users');
      await this.rdbStore.delete(predicates);
      console.info('All users cleared successfully');
      return true;
    } catch (error) {
      console.error('Clear all users failed:', error);
      return false;
    }
  }

  private resultSetToUser(resultSet: relationalStore.ResultSet): User {
    const user = new User();

    try {
      user.userId = resultSet.getString(resultSet.getColumnIndex('user_id'));
      user.username = resultSet.getString(resultSet.getColumnIndex('username'));
      user.phone = resultSet.getString(resultSet.getColumnIndex('phone'));
      user.email = resultSet.getString(resultSet.getColumnIndex('email'));
      user.avatar = resultSet.getString(resultSet.getColumnIndex('avatar'));
      user.address = resultSet.getString(resultSet.getColumnIndex('address'));
      user.token = resultSet.getString(resultSet.getColumnIndex('token'));
      user.createTime = resultSet.getLong(resultSet.getColumnIndex('created_at'));
      user.lastLoginTime = resultSet.getLong(resultSet.getColumnIndex('last_login'));
      user.isLoggedIn = resultSet.getLong(resultSet.getColumnIndex('is_logged_in')) === 1;

      // 解析偏好设置
      const preferencesStr = resultSet.getString(resultSet.getColumnIndex('preferences'));
      if (preferencesStr && preferencesStr !== '') {
        try {
          const prefsData = JSON.parse(preferencesStr) as UserPreferences;
          user.preferences.theme = prefsData.theme || 'light';
          user.preferences.language = prefsData.language || 'zh-CN';
          user.preferences.notificationEnabled = prefsData.notificationEnabled !== false;
          user.preferences.autoLogin = prefsData.autoLogin || false;
          user.preferences.defaultPaymentMethod = prefsData.defaultPaymentMethod || PaymentMethod.WECHAT;
        } catch (parseError) {
          console.error('Parse preferences failed:', parseError);
          // 使用默认偏好设置
          user.preferences = new UserPreferences();
        }
      }
    } catch (error) {
      console.error('Convert result set to user failed:', error);
    }

    return user;
  }

  // 关闭数据库连接
  async close(): Promise<void> {
    if (this.rdbStore) {
      try {
        this.rdbStore.close();
        this.rdbStore = null;
        console.info('Database closed successfully');
      } catch (error) {
        console.error('Close database failed:', error);
      }
    }
  }
}