import { Logger } from '../common/Logger';
import { ToastUtil } from '../common/ToastUtil';
import { StorageService } from './StorageService';
import { AuthState } from '../viewmodel/AuthState';
import { User } from '../viewmodel/User';
import { LoginType } from '../viewmodel/LoginType';

/**
 * 认证服务类
 * 管理用户登录、登出和认证状态
 */
export class AuthService {
  private static authState: AuthState = new AuthState();
  private static initialized: boolean = false;
  private static authStateChangeCallback: ((isLoggedIn: boolean) => void) | null = null;

  private constructor() {} // 防止实例化

  /**
   * 初始化认证服务
   * 从本地存储恢复认证状态
   */
  static async init(): Promise<void> {
    if (AuthService.initialized) {
      Logger.warn('AuthService already initialized');
      return;
    }

    try {
      const savedState = await StorageService.getAuthState();
      if (savedState) {
        AuthService.authState = savedState;
        // 检查token是否过期
        if (AuthService.authState.isTokenExpired()) {
          Logger.info('Stored token expired, clearing auth state');
          await AuthService.clearAuthState();
        } else {
          Logger.info('AuthService initialized, user logged in');
        }
      } else {
        Logger.info('AuthService initialized, no saved auth state');
      }
      AuthService.initialized = true;
    } catch (error) {
      Logger.error('Failed to initialize AuthService', error as Error);
      AuthService.initialized = true;
    }
  }

  /**
   * 设置认证状态变化回调
   * @param callback 状态变化时的回调函数
   */
  static setAuthStateChangeListener(callback: (isLoggedIn: boolean) => void): void {
    AuthService.authStateChangeCallback = callback;
  }

  /**
   * 移除认证状态变化回调
   */
  static removeAuthStateChangeListener(): void {
    AuthService.authStateChangeCallback = null;
  }

  /**
   * 触发认证状态变化回调
   */
  private static notifyAuthStateChange(): void {
    if (AuthService.authStateChangeCallback) {
      AuthService.authStateChangeCallback(AuthService.authState.isLoggedIn);
    }
  }

  /**
   * 获取当前认证状态
   */
  static getAuthState(): AuthState {
    return AuthService.authState;
  }

  /**
   * 检查用户是否已登录
   */
  static isLoggedIn(): boolean {
    return AuthService.authState.isLoggedIn && !AuthService.authState.isTokenExpired();
  }

  /**
   * 获取当前用户
   */
  static getCurrentUser(): User | null {
    return AuthService.isLoggedIn() ? AuthService.authState.user : null;
  }

  /**
   * 模拟微信登录
   * 实际项目中应调用微信SDK
   * @param code 微信授权码
   */
  static async loginWithWeChat(code: string): Promise<boolean> {
    try {
      Logger.info('WeChat login with code');

      // TODO: 实际项目中调用微信SDK和后端API
      // const wechatResult = await wechatAuthProvider.login(code);
      // const apiResult = await ApiClient.wechatLogin(code);

      // 模拟登录成功
      const user = new User();
      user.id = Date.now();
      user.nickname = '微信用户';
      user.avatar = '';
      user.loginType = LoginType.WECHAT;
      user.createdAt = new Date();

      // 模拟token，实际应从后端获取
      const now = new Date();
      const expiresAt = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000); // 30天后过期

      AuthService.authState.isLoggedIn = true;
      AuthService.authState.user = user;
      AuthService.authState.accessToken = `mock_access_token_${Date.now()}`;
      AuthService.authState.refreshToken = `mock_refresh_token_${Date.now()}`;
      AuthService.authState.tokenExpiresAt = expiresAt;

      // 持久化
      await StorageService.saveAuthState(AuthService.authState);

      AuthService.notifyAuthStateChange();
      ToastUtil.showSuccess('登录成功');
      Logger.info('WeChat login successful');

      return true;
    } catch (error) {
      Logger.error('WeChat login failed', error as Error);
      ToastUtil.showError('登录失败');
      return false;
    }
  }

  /**
   * 模拟华为账号登录
   * 实际项目中应调用华为Account Kit
   * @param accessToken 华为访问令牌
   */
  static async loginWithHuawei(accessToken: string): Promise<boolean> {
    try {
      Logger.info('Huawei login');

      // TODO: 实际项目中调用华为Account Kit和后端API
      // const huaweiResult = await accountAuthProvider.login(accessToken);
      // const apiResult = await ApiClient.huaweiLogin(accessToken);

      // 模拟登录成功
      const user = new User();
      user.id = Date.now();
      user.nickname = '华为用户';
      user.avatar = '';
      user.loginType = LoginType.HUAWEI;
      user.createdAt = new Date();

      // 模拟token，实际应从后端获取
      const now = new Date();
      const expiresAt = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000); // 30天后过期

      AuthService.authState.isLoggedIn = true;
      AuthService.authState.user = user;
      AuthService.authState.accessToken = `mock_huawei_access_token_${Date.now()}`;
      AuthService.authState.refreshToken = `mock_huawei_refresh_token_${Date.now()}`;
      AuthService.authState.tokenExpiresAt = expiresAt;

      // 持久化
      await StorageService.saveAuthState(AuthService.authState);

      AuthService.notifyAuthStateChange();
      ToastUtil.showSuccess('登录成功');
      Logger.info('Huawei login successful');

      return true;
    } catch (error) {
      Logger.error('Huawei login failed', error as Error);
      ToastUtil.showError('登录失败');
      return false;
    }
  }

  /**
   * 游客模式登录
   * 用于快速体验应用功能
   */
  static async loginAsGuest(): Promise<boolean> {
    try {
      Logger.info('Guest login');

      const user = new User();
      user.id = Date.now();
      user.nickname = '游客用户';
      user.avatar = '';
      user.loginType = LoginType.WECHAT; // 默认使用微信类型
      user.createdAt = new Date();

      const now = new Date();
      const expiresAt = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000); // 30天后过期

      AuthService.authState.isLoggedIn = true;
      AuthService.authState.user = user;
      AuthService.authState.accessToken = `guest_token_${Date.now()}`;
      AuthService.authState.refreshToken = '';
      AuthService.authState.tokenExpiresAt = expiresAt;

      // 持久化
      await StorageService.saveAuthState(AuthService.authState);

      AuthService.notifyAuthStateChange();
      Logger.info('Guest login successful');

      return true;
    } catch (error) {
      Logger.error('Guest login failed', error as Error);
      return false;
    }
  }

  /**
   * 登出
   */
  static async logout(): Promise<void> {
    try {
      Logger.info('Logout');

      // 清除认证状态
      await AuthService.clearAuthState();

      AuthService.notifyAuthStateChange();
      ToastUtil.showToast('已退出登录');
      Logger.info('Logout successful');
    } catch (error) {
      Logger.error('Logout failed', error as Error);
    }
  }

  /**
   * 清除认证状态
   */
  private static async clearAuthState(): Promise<void> {
    AuthService.authState = new AuthState();
    await StorageService.removeAuthState();
  }

  /**
   * 刷新token
   * 实际项目中应调用后端API
   */
  static async refreshToken(): Promise<boolean> {
    try {
      if (!AuthService.authState.refreshToken) {
        Logger.warn('No refresh token available');
        return false;
      }

      // TODO: 实际项目中调用后端API刷新token
      // const result = await ApiClient.refreshToken(AuthService.authState.refreshToken);

      // 模拟刷新成功，延长过期时间
      const now = new Date();
      AuthService.authState.tokenExpiresAt = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

      await StorageService.saveAuthState(AuthService.authState);
      Logger.info('Token refreshed successfully');
      return true;
    } catch (error) {
      Logger.error('Token refresh failed', error as Error);
      return false;
    }
  }

  /**
   * 检查并自动刷新token
   * 如果token即将过期，自动刷新
   */
  static async checkAndRefreshToken(): Promise<void> {
    if (AuthService.isLoggedIn() && AuthService.authState.shouldRefreshToken()) {
      Logger.info('Token should be refreshed, refreshing...');
      await AuthService.refreshToken();
    }
  }

  /**
   * 更新用户信息
   * @param nickname 昵称（可选）
   * @param avatar 头像（可选）
   */
  static async updateUser(nickname?: string, avatar?: string): Promise<boolean> {
    try {
      if (!AuthService.authState.user) {
        Logger.warn('No user logged in');
        return false;
      }

      // 更新字段
      if (nickname !== undefined) {
        AuthService.authState.user.nickname = nickname;
      }
      if (avatar !== undefined) {
        AuthService.authState.user.avatar = avatar;
      }

      // 持久化
      await StorageService.saveAuthState(AuthService.authState);

      Logger.info('User info updated');
      return true;
    } catch (error) {
      Logger.error('Failed to update user info', error as Error);
      return false;
    }
  }

  /**
   * 获取访问令牌
   */
  static getAccessToken(): string {
    return AuthService.authState.accessToken;
  }

  /**
   * 验证访问令牌是否有效
   */
  static isAccessTokenValid(): boolean {
    return AuthService.isLoggedIn() && !AuthService.authState.isTokenExpired();
  }
}
