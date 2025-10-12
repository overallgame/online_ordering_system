export class User {
  userId: string = '';
  username: string = '';
  phone: string = '';
  email: string = '';
  avatar?: string;
  address?: string;
  createTime: number = 0;

  // 用户偏好设置
  preferences: UserPreferences = new UserPreferences();

  // 登录状态
  isLoggedIn: boolean = false;
  token?: string;
  lastLoginTime: number = 0;


  constructor(
    userId:string,
    username: string,
    phone: string,
    email: string ,
    avatar?: string,
    address?: string) {
    this.userId=userId;
    this.username=username;
    this.phone=phone;
    this.email=email;
    this.avatar=avatar;
    this.address=address;
  }
}

export class UserPreferences {
  theme: 'light' | 'dark' = 'light';
  language: string = 'zh-CN';
  notificationEnabled: boolean = true;
  autoLogin: boolean = false;
  defaultPaymentMethod: PaymentMethod = PaymentMethod.WECHAT;
}

export enum PaymentMethod {
  WECHAT = 'wechat',
  ALIPAY = 'alipay',
  CREDIT_CARD = 'credit_card',
  CASH = 'cash'
}