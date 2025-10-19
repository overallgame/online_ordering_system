import { ApiClient, ApiEndpoints, ApiResponse,User } from 'common';

/**
 * 用户资料更新响应接口
 */
export interface UserProfileUpdateResponse {
  success: boolean;
}

export interface UserUpdate{
  avatar?: string;  // 头像
  name?: string;    // 姓名
  phone?: string;   // 手机号
  sex?: string;     // 性别
}

/**
 * 用户资料服务类 - 处理用户资料相关的API调用
 */
export class UserProfileService {
  private static instance: UserProfileService;
  private apiClient: ApiClient;

  private constructor() {
    this.apiClient = ApiClient.getInstance();
  }

  public static getInstance(): UserProfileService {
    if (!UserProfileService.instance) {
      UserProfileService.instance = new UserProfileService();
    }
    return UserProfileService.instance;
  }

  /**
   * 更新用户资料
   * @param userUpdateDTO 用户更新数据
   * @returns 更新结果
   */
  async updateUserProfile(user:User): Promise<ApiResponse<UserProfileUpdateResponse>> {
    try {

      const userUpdateData:UserUpdate={
        avatar:user.avatar,
        name:user.username,
        phone:user.phone,
        sex:user.sex
      }

      // 发送PUT请求到后端
      const response = await this.apiClient.put<UserProfileUpdateResponse>(
        ApiEndpoints.USER_UPDATE_PROFILE, userUpdateData
      );
      console.error(response.code?.toString()+"kkk");

      if (response.success) {
        // 检查后端返回的code字段
          console.log('更新用户资料成功');
          return {
            success: true
          };
      } else {
        console.error('更新用户资料失败:', response.error);
        return {
          success: false,
          error: response.error || '更新用户资料失败'
        };
      }
    } catch (error) {
      console.error('更新用户资料时发生错误:', error);
      return {
        success: false,
        error: '网络连接失败，请检查网络设置'
      };
    }
  }


}
