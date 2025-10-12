import { User } from 'common';

/**
 * 用户ViewModel - 处理用户相关的业务逻辑
 */
@Observed
export class UserViewModel {
  // 用户信息
  user: User = new User();




  /**
   * 更新用户信息
   */
  updateUser(user: User): void {
    this.user = user;
  }



}
