import { ApiClient, ApiEndpoints, ApiResponse, AppDataManager, User, UserPreferences } from "common";
import { AuthResponse, LoginRequest, LoginRequestBody, RegisterRequest, RegisterRequestBody } from "../model/Auth";

export class AuthService {
  private apiClient: ApiClient = ApiClient.getInstance();
  private appDataManager: AppDataManager = AppDataManager.getInstance();

  async login(loginRequest: LoginRequest): Promise<AuthResponse> {
    // 验证输入
    const validation = loginRequest.validate();
    if (!validation.isValid) {
      return {
        success: false,
        message: validation.message
      };
    }

    try {
      const requestBody: LoginRequestBody = {
        username: loginRequest.username,
        password: loginRequest.password
      };

      // 调用网络请求
      const response: ApiResponse<AuthResponse> = await this.apiClient.post(
        ApiEndpoints.LOGIN,
        requestBody
      );

      if (response.success && response.data) {
        // 创建用户对象
        const user = this.createUserFromResponse(response.data);
        user.isLoggedIn = true;
        user.lastLoginTime = Date.now();

        // 保存到全局状态
        await this.appDataManager.setCurrentUser(user);

        return {
          success: true,
          message: '登录成功',
          user: user,
          token: response.data.token
        };
      } else {
        return {
          success: false,
          message: response.error || '登录失败'
        };
      }
    } catch (error) {
      console.error('Login request error:', error);
      return {
        success: false,
        message: '网络连接失败'
      };
    }
  }

  async register(registerRequest: RegisterRequest): Promise<AuthResponse> {
    const validation = registerRequest.validate();
    if (!validation.isValid) {
      return {
        success: false,
        message: validation.message
      };
    }

    try {
      const requestBody: RegisterRequestBody = {
        username: registerRequest.username,
        phone: registerRequest.phone,
        email: registerRequest.email,
        password: registerRequest.password
      };

      const response: ApiResponse<AuthResponse> = await this.apiClient.post(
        ApiEndpoints.REGISTER,
        requestBody
      );

      if (response.success && response.data) {
        const user = this.createUserFromResponse(response.data);
        user.isLoggedIn = true;
        user.lastLoginTime = Date.now();

        await this.appDataManager.setCurrentUser(user);

        return {
          success: true,
          message: '注册成功',
          user: user,
          token: response.data.token
        };
      } else {
        return {
          success: false,
          message: response.error || '注册失败'
        };
      }
    } catch (error) {
      console.error('Register request error:', error);
      return {
        success: false,
        message: '网络连接失败'
      };
    }
  }

  async autoLogin(): Promise<boolean> {
    try {
      // 检查是否已有登录用户
      if (this.appDataManager.isLoggedIn()) {
        return true;
      }

      // 尝试从数据库加载用户
      await this.appDataManager.loadCurrentUser();
      return this.appDataManager.isLoggedIn();
    } catch (error) {
      console.error('Auto login error:', error);
      return false;
    }
  }

  async logout(): Promise<boolean> {
    try {
      await this.appDataManager.logout()
    } catch (error) {
      console.error('Logout API call failed:', error);
    }

    // 清除本地状态
    return await this.appDataManager.logout();
  }

  // 获取当前用户信息
  getCurrentUser(): User | null {
    return this.appDataManager.getCurrentUser();
  }

  // 检查登录状态
  isLoggedIn(): boolean {
    return this.appDataManager.isLoggedIn();
  }

  private createUserFromResponse(data: AuthResponse): User {
    const user = new User();
    user.userId = data.user?.userId || this.generateUserId();
    user.username = data.user?.username || '';
    user.phone = data.user?.phone || '';
    user.email = data.user?.email || '';
    user.avatar = data.user?.avatar || '';
    user.token = data.token || '';
    user.createTime = data.user?.createTime || Date.now();
    user.preferences = new UserPreferences();

    return user;
  }

  private generateUserId(): string {
    return 'user_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
  }
}