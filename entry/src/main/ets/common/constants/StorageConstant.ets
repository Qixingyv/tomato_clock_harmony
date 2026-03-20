/**
 * 存储相关常量定义
 * 用于Preferences API的key和默认值管理
 */
export class StorageConstant {
  /**
   * Preferences存储名称
   */
  static readonly PREFERENCES_NAME: string = 'TomatoClockPreferences';

  // ==================== 认证相关 ====================

  /**
   * 认证状态存储key
   */
  static readonly KEY_AUTH_STATE: string = 'auth_state';

  // ==================== 任务相关 ====================

  /**
   * 任务列表存储key
   */
  static readonly KEY_TASKS: string = 'tasks';

  /**
   * 任务ID计数器key（用于生成唯一ID）
   */
  static readonly KEY_TASK_ID_COUNTER: string = 'task_id_counter';

  // ==================== 计时器相关 ====================

  /**
   * 计时器状态存储key
   */
  static readonly KEY_TIMER_STATE: string = 'timer_state';

  // ==================== 默认值 ====================

  /**
   * 默认任务ID起始值
   */
  static readonly DEFAULT_TASK_ID: number = 1;

  /**
   * 空任务列表
   */
  static readonly EMPTY_TASKS: string = '[]';

  /**
   * 空计时器状态
   */
  static readonly EMPTY_TIMER_STATE: string = '{}';
}
