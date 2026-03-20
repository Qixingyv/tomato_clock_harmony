import { User } from './User';

/**
 * 认证状态数据模型
 * 用于管理用户登录状态和token信息
 */
export class AuthState {
  isLoggedIn: boolean = false;
  user: User | null = null;
  accessToken: string = '';
  refreshToken: string = '';
  tokenExpiresAt: Date = new Date();

  /**
   * 判断token是否已过期
   */
  isTokenExpired(): boolean {
    return new Date() >= this.tokenExpiresAt;
  }

  /**
   * 判断是否需要刷新token（提前1天）
   */
  shouldRefreshToken(): boolean {
    const now = new Date();
    const expiresAt = this.tokenExpiresAt;
    const refreshTime = new Date(expiresAt.getTime() - 24 * 60 * 60 * 1000);
    return now >= refreshTime;
  }
}
