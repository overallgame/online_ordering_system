import { ApiClient, ApiEndpoints, ApiResponse, AppDataManager, User, UserPreferences } from "common";
import { AuthResponse, LoginRequest, LoginRequestBody, RegisterRequest, RegisterRequestBody, LoginApiResponse, UserLoginVO, RegisterApiResponse } from "../model/Auth";

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
        account: loginRequest.account,
        password: loginRequest.password
      };

      const response: ApiResponse<LoginApiResponse> = await this.apiClient.post(
        ApiEndpoints.LOGIN,
        requestBody,
        false
      );

      if (response.success && response.data) {
        const apiResult = response.data;

        if (apiResult.code === 1) {
          const user = this.createUserFromLoginVO(apiResult.data);
          user.isLoggedIn = true;
          user.lastLoginTime = Date.now();

          await this.appDataManager.setCurrentUser(user);

          return {
            success: true,
            message: apiResult.msg || '登录成功',
            user: user,
            token: apiResult.data.token
          };
        } else {
          return {
            success: false,
            message: apiResult.msg || '登录失败'
          };
        }
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
        password: registerRequest.password,
        phone: registerRequest.phone
      };

      const response: ApiResponse<RegisterApiResponse> = await this.apiClient.post(
        ApiEndpoints.REGISTER,
        requestBody,
        false
      );

      if (response.success && response.data) {
        const apiResult = response.data;

        if (apiResult.code === 1) {
          return {
            success: true,
            message: apiResult.msg || '注册成功'
          };
        } else {
          return {
            success: false,
            message: apiResult.msg || '注册失败'
          };
        }
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

  private createUserFromLoginVO(data: UserLoginVO): User {
    const user = new User();
    user.userId = data.id.toString();
    user.username = '';
    user.phone = '';
    user.email = '';
    user.avatar = '';
    user.token = data.token;
    user.createTime = Date.now();
    user.preferences = new UserPreferences();

    return user;
  }
}

export { AuthResponse, LoginRequest, RegisterRequest };
