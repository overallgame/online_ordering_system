import { User } from "common/src/main/ets/model/User";

export class LoginRequest {
  account: string = '';
  password: string = '';

  validate(): ValidationResult {
    if (!this.account.trim()) {
      return { isValid: false, message: '请输入用户名或手机号' };
    }
    if (!this.password.trim()) {
      return { isValid: false, message: '请输入密码' };
    }
    if (this.password.length < 6) {
      return { isValid: false, message: '密码长度不能少于6位' };
    }
    return { isValid: true, message: '' };
  }
}

export class RegisterRequest {
  username: string = '';
  password: string = '';
  phone: string = '';

  validate(): ValidationResult {
    if (!this.username.trim()) {
      return { isValid: false, message: '请输入用户名' };
    }
    if (!this.password.trim()) {
      return { isValid: false, message: '请输入密码' };
    }
    if (this.password.length < 6) {
      return { isValid: false, message: '密码长度不能少于6位' };
    }
    if (!this.phone.trim()) {
      return { isValid: false, message: '请输入手机号' };
    }
    if (!this.isValidPhone(this.phone)) {
      return { isValid: false, message: '请输入正确的手机号格式' };
    }
    return { isValid: true, message: '' };
  }

  private isValidPhone(phone: string): boolean {
    const phoneRegex = /^1[3-9]\d{9}$/;
    return phoneRegex.test(phone);
  }
}

export interface ValidationResult {
  isValid: boolean;
  message: string;
}

export interface LoginRequestBody {
  account: string;
  password: string;
}

export interface RegisterRequestBody {
  username: string;
  password: string;
  phone: string;
}

// API响应结构
export interface ApiResult<T> {
  code: number;
  data: T;
  msg: string;
}

// 用户登录响应数据
export interface UserLoginVO {
  id: number;
  token: string;
}

// 登录API响应
export type LoginApiResponse = ApiResult<UserLoginVO>;

// 注册API响应
export type RegisterApiResponse = ApiResult<object>;

// 应用层登录响应
export class AuthResponse {
  success: boolean = false;
  message: string = '';
  user?: User;
  token?: string;
}