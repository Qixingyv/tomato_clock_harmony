import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import { Logger } from '../common/Logger';
import { StorageConstant } from '../common/constants/StorageConstant';
import { AuthState } from '../viewmodel/AuthState';
import { ToDoListClass } from '../viewmodel/ToDoListClass';
import { User } from '../viewmodel/User';
import { LoginType } from '../viewmodel/LoginType';

/**
 * 存储服务类
 * 封装Preferences API，提供统一的本地存储功能
 * 使用静态方法模式，防止实例化
 */
export class StorageService {
  private static store: preferences.Preferences | null = null;
  private static initialized: boolean = false;

  private constructor() {} // 防止实例化

  /**
   * 初始化存储服务
   * @param context 应用上下文
   */
  static async init(context: Context): Promise<void> {
    if (StorageService.initialized) {
      Logger.warn('StorageService already initialized');
      return;
    }

    try {
      StorageService.store = await preferences.getPreferences(context, StorageConstant.PREFERENCES_NAME);
      StorageService.initialized = true;
      Logger.info('StorageService initialized successfully');
    } catch (error) {
      Logger.error('Failed to initialize StorageService', error as Error);
    }
  }

  /**
   * 确保存储已初始化
   */
  private static ensureInitialized(): void {
    if (!StorageService.initialized || !StorageService.store) {
      const error = new Error('StorageService not initialized. Call init() first.');
      Logger.error('StorageService not initialized', error);
      throw (error as Error);
    }
  }

  // ==================== 通用存储方法 ====================

  /**
   * 保存字符串值
   * @param key 存储key
   * @param value 字符串值
   */
  static async putString(key: string, value: string): Promise<void> {
    StorageService.ensureInitialized();
    try {
      await StorageService.store!.put(key, value);
      await StorageService.store!.flush();
      Logger.debug(`Saved string: ${key}`);
    } catch (error) {
      Logger.error(`Failed to save string: ${key}`, error as Error);
    }
  }

  /**
   * 获取字符串值
   * @param key 存储key
   * @param defaultValue 默认值
   */
  static async getString(key: string, defaultValue: string): Promise<string> {
    StorageService.ensureInitialized();
    try {
      return await StorageService.store!.get(key, defaultValue) as string;
    } catch (error) {
      Logger.error(`Failed to get string: ${key}`, error as Error);
      throw (error as Error);
    }
  }

  /**
   * 保存数字值
   * @param key 存储key
   * @param value 数字值
   */
  static async putNumber(key: string, value: number): Promise<void> {
    StorageService.ensureInitialized();
    try {
      await StorageService.store!.put(key, value);
      await StorageService.store!.flush();
      Logger.debug(`Saved number: ${key} = ${value}`);
    } catch (error) {
      Logger.error(`Failed to save number: ${key}`, error as Error);
    }
  }

  /**
   * 获取数字值
   * @param key 存储key
   * @param defaultValue 默认值
   */
  static async getNumber(key: string, defaultValue: number): Promise<number> {
    StorageService.ensureInitialized();
    try {
      return await StorageService.store!.get(key, defaultValue) as number;
    } catch (error) {
      Logger.error(`Failed to get number: ${key}`, error as Error);
      throw (error as Error);
    }
  }

  /**
   * 保存布尔值
   * @param key 存储key
   * @param value 布尔值
   */
  static async putBoolean(key: string, value: boolean): Promise<void> {
    StorageService.ensureInitialized();
    try {
      await StorageService.store!.put(key, value);
      await StorageService.store!.flush();
      Logger.debug(`Saved boolean: ${key} = ${value}`);
    } catch (error) {
      Logger.error(`Failed to save boolean: ${key}`, error as Error);
      throw (error as Error);
    }
  }

  /**
   * 获取布尔值
   * @param key 存储key
   * @param defaultValue 默认值
   */
  static async getBoolean(key: string, defaultValue: boolean): Promise<boolean> {
    StorageService.ensureInitialized();
    try {
      return await StorageService.store!.get(key, defaultValue) as boolean;
    } catch (error) {
      Logger.error(`Failed to get boolean: ${key}`, error as Error);
      throw (error as Error);
    }
  }

  /**
   * 保存对象（JSON序列化）
   * @param key 存储key
   * @param value 对象值
   */
  static async putObject(key: string, value: Record<string, Object>): Promise<void> {
    StorageService.ensureInitialized();
    try {
      const jsonString = JSON.stringify(value);
      await StorageService.store!.put(key, jsonString);
      await StorageService.store!.flush();
      Logger.debug(`Saved object: ${key}`);
    } catch (error) {
      Logger.error(`Failed to save object: ${key}`, error as Error);
      throw (error as Error);
    }
  }

  /**
   * 获取对象（JSON反序列化）
   * @param key 存储key
   * @param defaultValue 默认值
   */
  static async getObject(key: string, defaultValue: Record<string, Object>): Promise<Record<string, Object>> {
    StorageService.ensureInitialized();
    try {
      const jsonString = await StorageService.store!.get(key, JSON.stringify(defaultValue)) as string;
      return JSON.parse(jsonString) as Record<string, Object>;
    } catch (error) {
      Logger.error(`Failed to get object: ${key}`, error as Error);
      throw (error as Error);
    }
  }

  /**
   * 删除指定key的值
   * @param key 存储key
   */
  static async remove(key: string): Promise<void> {
    StorageService.ensureInitialized();
    try {
      await StorageService.store!.delete(key);
      await StorageService.store!.flush();
      Logger.debug(`Removed key: ${key}`);
    } catch (error) {
      Logger.error(`Failed to remove key: ${key}`, error as Error);
      throw (error as Error);
    }
  }

  // ==================== 认证状态存储 ====================

  /**
   * 保存认证状态
   * @param state 认证状态对象
   */
  static async saveAuthState(state: AuthState): Promise<void> {
    try {
      const data: Record<string, Object> = {
        'isLoggedIn': state.isLoggedIn,
        'accessToken': state.accessToken,
        'refreshToken': state.refreshToken,
        'tokenExpiresAt': state.tokenExpiresAt.getTime()
      };
      // Only include user if not null (Object type doesn't accept null in ArkTS)
      if (state.user !== null) {
        data['user'] = StorageService.userToObj(state.user);
      }
      await StorageService.putObject(StorageConstant.KEY_AUTH_STATE, data);
      Logger.info('AuthState saved successfully');
    } catch (error) {
      Logger.error('Failed to save AuthState', error as Error);
      throw (error as Error);
    }
  }

  /**
   * 获取认证状态
   */
  static async getAuthState(): Promise<AuthState | null> {
    try {
      const data = await StorageService.getObject(StorageConstant.KEY_AUTH_STATE, {});
      if (Object.keys(data).length === 0) {
        return null;
      }

      const state = new AuthState();
      state.isLoggedIn = (data['isLoggedIn'] as boolean) || false;
      state.user = (data['user'] as Record<string, Object> | null) ?
        StorageService.objToUser(data['user'] as Record<string, Object>) : null;
      state.accessToken = (data['accessToken'] as string) || '';
      state.refreshToken = (data['refreshToken'] as string) || '';
      state.tokenExpiresAt = new Date((data['tokenExpiresAt'] as number) || Date.now());

      return state;
    } catch (error) {
      Logger.error('Failed to get AuthState', error as Error);
      return null;
    }
  }

  /**
   * 删除认证状态
   */
  static async removeAuthState(): Promise<void> {
    await StorageService.remove(StorageConstant.KEY_AUTH_STATE);
    Logger.info('AuthState removed');
  }

  // ==================== 任务列表存储 ====================

  /**
   * 保存任务列表
   * @param tasks 任务数组
   */
  static async saveTasks(tasks: ToDoListClass[]): Promise<void> {
    try {
      const tasksData = tasks.map(task => task.toJson());
      await StorageService.putObject(StorageConstant.KEY_TASKS, { 'tasks': tasksData });
      Logger.info(`Tasks saved: ${tasks.length} items`);
    } catch (error) {
      Logger.error('Failed to save tasks', error as Error);
      throw (error as Error);
    }
  }

  /**
   * 获取任务列表
   */
  static async loadTasks(): Promise<ToDoListClass[]> {
    try {
      const data = await StorageService.getObject(StorageConstant.KEY_TASKS, { 'tasks': [] });
      const tasksData = data['tasks'] as Record<string, Object>[];
      return tasksData.map(taskData => ToDoListClass.fromJson(taskData));
    } catch (error) {
      Logger.error('Failed to load tasks', error as Error);
      throw (error as Error);
    }
  }

  /**
   * 保存任务ID计数器
   * @param counter 计数器值
   */
  static async saveTaskIdCounter(counter: number): Promise<void> {
    await StorageService.putNumber(StorageConstant.KEY_TASK_ID_COUNTER, counter);
  }

  /**
   * 获取任务ID计数器
   */
  static async getTaskIdCounter(): Promise<number> {
    return await StorageService.getNumber(StorageConstant.KEY_TASK_ID_COUNTER, StorageConstant.DEFAULT_TASK_ID);
  }

  // ==================== 计时器状态存储 ====================

  /**
   * 保存计时器状态
   * @param state 计时器状态对象
   */
  static async saveTimerState(state: Record<string, Object>): Promise<void> {
    await StorageService.putObject(StorageConstant.KEY_TIMER_STATE, state);
    Logger.debug('TimerState saved');
  }

  /**
   * 获取计时器状态
   */
  static async restoreTimerState(): Promise<Record<string, Object> | null> {
    try {
      const state = await StorageService.getObject(StorageConstant.KEY_TIMER_STATE, {});
      if (Object.keys(state).length === 0) {
        return null;
      }
      return state;
    } catch (error) {
      Logger.error('Failed to restore timer state', error as Error);
      return null;
    }
  }

  // ==================== 辅助方法 ====================

  /**
   * 将User对象转换为可存储的Record
   */
  private static userToObj(user: User): Record<string, Object> {
    return {
      'id': user.id,
      'nickname': user.nickname,
      'avatar': user.avatar,
      'loginType': user.loginType,
      'createdAt': user.createdAt.getTime()
    };
  }

  /**
   * 将Record转换为User对象
   */
  private static objToUser(obj: Record<string, Object>): User {
    const user = new User();
    user.id = (obj['id'] as number) || 0;
    user.nickname = (obj['nickname'] as string) || '';
    user.avatar = (obj['avatar'] as string) || '';
    user.loginType = (obj['loginType'] as LoginType) || LoginType.WECHAT;
    user.createdAt = new Date((obj['createdAt'] as number) || Date.now());
    return user;
  }
}
