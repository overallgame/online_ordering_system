import { User } from "common/src/main/ets/model/User";

export class LoginRequest {
  username: string = '';
  password: string = '';
  rememberMe: boolean = false;

  validate(): ValidationResult {
    if (!this.username.trim()) {
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
  phone: string = '';
  email: string = '';
  password: string = '';
  confirmPassword: string = '';
  agreeToTerms: boolean = false;

  validate(): ValidationResult {
    if (!this.username.trim()) {
      return { isValid: false, message: '请输入用户名' };
    }
    if (!this.phone.trim()) {
      return { isValid: false, message: '请输入手机号' };
    }
    if (!this.isValidPhone(this.phone)) {
      return { isValid: false, message: '请输入正确的手机号格式' };
    }
    if (!this.email.trim()) {
      return { isValid: false, message: '请输入邮箱' };
    }
    if (!this.isValidEmail(this.email)) {
      return { isValid: false, message: '请输入正确的邮箱格式' };
    }
    if (!this.password.trim()) {
      return { isValid: false, message: '请输入密码' };
    }
    if (this.password.length < 6) {
      return { isValid: false, message: '密码长度不能少于6位' };
    }
    if (this.password !== this.confirmPassword) {
      return { isValid: false, message: '两次输入的密码不一致' };
    }
    if (!this.agreeToTerms) {
      return { isValid: false, message: '请同意用户协议和隐私政策' };
    }
    return { isValid: true, message: '' };
  }

  private isValidPhone(phone: string): boolean {
    const phoneRegex = /^1[3-9]\d{9}$/;
    return phoneRegex.test(phone);
  }

  private isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }
}

export interface LoginRequestBody {
  username: string;
  password: string;
}

export interface RegisterRequestBody {
  username: string;
  phone: string;
  email: string;
  password: string;
}

export class AuthResponse {
  success: boolean = false;
  message: string = '';
  user?: User;
  token?: string;
}

export interface ValidationResult {
  isValid: boolean;
  message: string;
}