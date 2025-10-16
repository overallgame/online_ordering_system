import { ApiClient, ApiEndpoints, ApiResponse } from 'common';
import { User } from 'common';

interface UpdateUserData{
  userId: string;
  username: string;
  phone: string;
  email?: string;
  address?: string;
}



/**
 * 用户服务类 - 处理用户相关的API调用
 */
export class UserService {
  private static instance: UserService;
  private apiClient: ApiClient;

  private constructor() {
    this.apiClient = ApiClient.getInstance();
  }

  public static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService();
    }
    return UserService.instance;
  }

  async updateUserProfile(user: User): Promise<ApiResponse<User>> {
    try {
      // 准备要发送的用户数据，排除敏感信息
      const userData :UpdateUserData= {
        userId: user.userId,
        username: user.username,
        phone: user.phone,
        email: user.email,
        address: user.address,
      };

      const response = await this.apiClient.put<User>(ApiEndpoints.UPDATE_USER_PROFILE, userData);
      
      if (response.success && response.data) {
        console.log('用户资料更新成功');
        return response;
      } else {
        console.error('用户资料更新失败:', response.error);
        return response;
      }
    } catch (error) {
      console.error('更新用户资料时发生错误:', error);
      return {
        success: false,
        error: '网络连接失败，请检查网络设置'
      };
    }
  }

  /**
   * 更新用户头像
   * @param userId 用户ID
   * @param avatarUrl 头像URL
   * @returns 更新结果
   */
  // async updateUserAvatar(userId: string, avatarUrl: string): Promise<ApiResponse<{ avatar: string }>> {
  //   try {
  //     const avatarData = {
  //       userId: userId,
  //       avatar: avatarUrl
  //     };
  //
  //     const response = await this.apiClient.put<{ avatar: string }>(ApiEndpoints.UPDATE_USER_AVATAR, avatarData);
  //
  //     if (response.success) {
  //       console.log('用户头像更新成功');
  //       return response;
  //     } else {
  //       console.error('用户头像更新失败:', response.error);
  //       return response;
  //     }
  //   } catch (error) {
  //     console.error('更新用户头像时发生错误:', error);
  //     return {
  //       success: false,
  //       error: '网络连接失败，请检查网络设置'
  //     };
  //   }
  // }

  /**
   * 获取用户资料
   * @param userId 用户ID
   * @returns 用户资料
   */
//   async getUserProfile(userId: string): Promise<ApiResponse<User>> {
//     try {
//       const response = await this.apiClient.get<User>(`${ApiEndpoints.USER_PROFILE}/${userId}`);
//
//       if (response.success) {
//         console.log('获取用户资料成功');
//         return response;
//       } else {
//         console.error('获取用户资料失败:', response.error);
//         return response;
//       }
//     } catch (error) {
//       console.error('获取用户资料时发生错误:', error);
//       return {
//         success: false,
//         error: '网络连接失败，请检查网络设置'
//       };
//     }
//   }
 }
