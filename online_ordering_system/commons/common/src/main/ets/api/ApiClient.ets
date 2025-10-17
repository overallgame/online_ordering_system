import http from '@ohos.net.http';

export class ApiClient {
  private static instance: ApiClient;
  private baseURL: string = ' http://117.72.48.167:9848/';

  public static getInstance(): ApiClient {
    if (!ApiClient.instance) {
      ApiClient.instance = new ApiClient();
    }
    return ApiClient.instance;
  }

  async request<T>(
    method: http.RequestMethod,
    endpoint: string,
    data?: object
  ): Promise<ApiResponse<T>> {
    try {
      const url = `${this.baseURL}${endpoint}`;
      const httpRequest = http.createHttp();

      const options: http.HttpRequestOptions = {
        method: method,
        header: {
          'Content-Type': 'application/json',
        },
        readTimeout: 15000,
        connectTimeout: 15000
      };

      if (data && (method === http.RequestMethod.POST || method === http.RequestMethod.PUT)) {
        options.extraData = JSON.stringify(data);
      }

      const response = await httpRequest.request(url, options);

      if (response.responseCode === 200) {
        let result: T;
        if (typeof response.result === 'string') {
          result = JSON.parse(response.result) as T;
        } else {
          result = response.result as T;
        }

        return {
          success: true,
          data: result,
          code: response.responseCode
        };
      } else {
        return {
          success: false,
          error: this.getErrorMessage(response.responseCode),
          code: response.responseCode
        };
      }
    } catch (error) {
      console.error('API request failed:', error);
      return {
        success: false,
        error: '网络连接失败'
      };
    }
  }

  async get<T>(endpoint: string): Promise<ApiResponse<T>> {
    return this.request<T>(http.RequestMethod.GET, endpoint);
  }

  async post<T>(endpoint: string, data: object): Promise<ApiResponse<T>> {
    return this.request<T>(http.RequestMethod.POST, endpoint, data);
  }

  async put<T>(endpoint: string, data: object): Promise<ApiResponse<T>> {
    return this.request<T>(http.RequestMethod.PUT, endpoint, data);
  }

  // 添加 DELETE 方法
  async delete<T>(endpoint: string): Promise<ApiResponse<T>> {
    return this.request<T>(http.RequestMethod.DELETE, endpoint);
  }

  private getErrorMessage(code: number): string {
    const messages: Record<number, string> = {
      400: '请求参数错误',
      401: '未授权',
      403: '访问被拒绝',
      404: '资源不存在',
      500: '服务器错误'
    };
    return messages[code] || `请求失败: ${code}`;
  }
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  code?: number;
}

export class ApiEndpoints {
  static readonly LOGIN = '/user/user/login';
  static readonly REGISTER = '/user/user/register';
  static readonly LOGOUT = '/api/v1/auth/logout';
  static readonly USER_PROFILE = '/api/v1/user/profile';
  
  // 分类相关接口
  static readonly CATEGORY_LIST = '/user/category/list';
  
  // 菜品相关接口
  static readonly DISH_LIST_BY_CATEGORY = '/user/dish/list';
  
  // 套餐相关接口
  static readonly SETMEAL_LIST = '/user/setmeal/list';
  static readonly SETMEAL_DISH_LIST = '/user/setmeal/dish';
}