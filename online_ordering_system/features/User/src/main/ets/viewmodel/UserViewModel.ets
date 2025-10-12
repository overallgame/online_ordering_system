import { User } from 'common';

/**
 * 用户ViewModel - 处理用户相关的业务逻辑
 */
@Observed
export class UserViewModel {
  // 用户信息
  user: User = new User(
    '1',
    '小七七',
    '15936044956',
    'user@example.com',
    'dddaaa',
    '北京市朝阳区'
  );


  /**
   * 更新用户信息
   */
  updateUser(user: User): void {
    this.user = user;
  }



}
