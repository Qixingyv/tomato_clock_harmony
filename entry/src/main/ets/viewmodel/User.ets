import { LoginType } from './LoginType';

/**
 * 用户信息数据模型
 * 存储用户的基本信息
 */
export class User {
  id: number = 0;
  nickname: string = '';
  avatar: string = '';
  loginType: LoginType = LoginType.WECHAT;
  createdAt: Date = new Date();

  get displayName(): string {
    return this.nickname || '番茄用户';
  }

  get avatarUrl(): string {
    return this.avatar || '';
  }
}
