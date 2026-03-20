import { Logger } from '../common/Logger';
import { ToastUtil } from '../common/ToastUtil';
import { StorageService } from './StorageService';
import { TimerViewModel } from '../viewmodel/TimerViewModel';
import { TimerMode } from '../viewmodel/TimerMode';
import { TaskService } from './TaskService';
import { TaskConstant } from '../common/constants/TaskConstant';

/**
 * 计时器服务类
 * 管理计时器的状态、启动、暂停、恢复和停止
 */
export class TimerService {
  private static viewModel: TimerViewModel = new TimerViewModel();
  private static timerId: number = -1;
  private static initialized: boolean = false;
  private static timerStateChangeCallback: ((isRunning: boolean) => void) | null = null;
  private static timerTickCallback: ((remainingSeconds: number) => void) | null = null;
  private static timerCompleteCallback: ((mode: TimerMode) => void) | null = null;
  private static autoSaveTimerId: number = -1;
  private static readonly AUTO_SAVE_INTERVAL: number = 60 * 1000; // 每分钟自动保存

  private constructor() {} // 防止实例化

  /**
   * 初始化计时器服务
   * 从本地存储恢复计时器状态
   */
  static async init(): Promise<void> {
    if (TimerService.initialized) {
      Logger.warn('TimerService already initialized');
      return;
    }

    try {
      const savedState = await StorageService.restoreTimerState();
      if (savedState) {
        TimerService.viewModel = TimerViewModel.fromPersist(savedState);
        // 如果之前在运行，恢复为暂停状态
        if (TimerService.viewModel.isRunning) {
          TimerService.viewModel.isRunning = false;
          TimerService.viewModel.isPaused = true;
        }
        Logger.info('TimerService initialized with restored state');
      } else {
        Logger.info('TimerService initialized with default state');
      }
      TimerService.initialized = true;
    } catch (error) {
      Logger.error('Failed to initialize TimerService', error as Error);
      TimerService.initialized = true;
    }
  }

  /**
   * 设置计时器状态变化回调
   * @param callback 状态变化时的回调函数
   */
  static setTimerStateChangeListener(callback: (isRunning: boolean) => void): void {
    TimerService.timerStateChangeCallback = callback;
  }

  /**
   * 移除计时器状态变化回调
   */
  static removeTimerStateChangeListener(): void {
    TimerService.timerStateChangeCallback = null;
  }

  /**
   * 设置计时器tick回调（每秒调用）
   * @param callback tick回调函数
   */
  static setTimerTickCallback(callback: (remainingSeconds: number) => void): void {
    TimerService.timerTickCallback = callback;
  }

  /**
   * 移除计时器tick回调
   */
  static removeTimerTickCallback(): void {
    TimerService.timerTickCallback = null;
  }

  /**
   * 设置计时器完成回调
   * @param callback 完成时的回调函数
   */
  static setTimerCompleteCallback(callback: (mode: TimerMode) => void): void {
    TimerService.timerCompleteCallback = callback;
  }

  /**
   * 移除计时器完成回调
   */
  static removeTimerCompleteCallback(): void {
    TimerService.timerCompleteCallback = null;
  }

  /**
   * 触发计时器状态变化回调
   */
  private static notifyTimerStateChange(): void {
    if (TimerService.timerStateChangeCallback) {
      TimerService.timerStateChangeCallback(TimerService.viewModel.isRunning);
    }
  }

  /**
   * 触发计时器tick回调
   */
  private static notifyTimerTick(): void {
    if (TimerService.timerTickCallback) {
      TimerService.timerTickCallback(TimerService.viewModel.remainingSeconds);
    }
  }

  /**
   * 触发计时器完成回调
   */
  private static notifyTimerComplete(): void {
    if (TimerService.timerCompleteCallback) {
      TimerService.timerCompleteCallback(TimerService.viewModel.mode);
    }
  }

  /**
   * 保存计时器状态到本地存储
   */
  private static async saveState(): Promise<void> {
    try {
      await StorageService.saveTimerState(TimerService.viewModel.toPersist());
    } catch (error) {
      Logger.error('Failed to save timer state', error as Error);
    }
  }

  /**
   * 启动自动保存定时器
   */
  private static startAutoSave(): void {
    TimerService.stopAutoSave();
    TimerService.autoSaveTimerId = setInterval(() => {
      TimerService.saveState();
    }, TimerService.AUTO_SAVE_INTERVAL);
  }

  /**
   * 停止自动保存定时器
   */
  private static stopAutoSave(): void {
    if (TimerService.autoSaveTimerId !== -1) {
      clearInterval(TimerService.autoSaveTimerId);
      TimerService.autoSaveTimerId = -1;
    }
  }

  /**
   * 获取计时器视图模型
   */
  static getViewModel(): TimerViewModel {
    return TimerService.viewModel;
  }

  /**
   * 获取当前剩余秒数
   */
  static getRemainingSeconds(): number {
    return TimerService.viewModel.remainingSeconds;
  }

  /**
   * 获取格式化的时间字符串
   */
  static getFormattedTime(): string {
    return TimerService.viewModel.formattedTime;
  }

  /**
   * 获取进度百分比
   */
  static getProgress(): number {
    return TimerService.viewModel.progress;
  }

  /**
   * 判断是否正在运行
   */
  static isRunning(): boolean {
    return TimerService.viewModel.isRunning;
  }

  /**
   * 判断是否暂停
   */
  static isPaused(): boolean {
    return TimerService.viewModel.isPaused;
  }

  /**
   * 获取当前模式
   */
  static getMode(): TimerMode {
    return TimerService.viewModel.mode;
  }

  /**
   * 获取关联的任务ID
   */
  static getTaskId(): number {
    return TimerService.viewModel.taskId;
  }

  // ==================== 计时器控制 ====================

  /**
   * 启动计时器
   * @param taskId 关联的任务ID，可选
   */
  static async start(taskId?: number): Promise<void> {
    if (TimerService.viewModel.isRunning) {
      Logger.warn('Timer is already running');
      return;
    }

    try {
      if (taskId !== undefined) {
        TimerService.viewModel.taskId = taskId;
      }

      TimerService.viewModel.start();
      TimerService.startTimerInternal();
      TimerService.startAutoSave();
      await TimerService.saveState();

      TimerService.notifyTimerStateChange();

      const taskName = taskId ? TaskService.getTaskById(taskId)?.getName : '当前任务';
      Logger.info(`Timer started for task: ${taskName}`);
    } catch (error) {
      Logger.error('Failed to start timer', error as Error);
    }
  }

  /**
   * 内部启动计时器（使用setInterval）
   */
  private static startTimerInternal(): void {
    TimerService.timerId = setInterval(() => {
      if (TimerService.viewModel.remainingSeconds > 0) {
        TimerService.viewModel.remainingSeconds--;
        TimerService.notifyTimerTick();
      } else {
        // 时间到
        TimerService.onTimerComplete();
      }
    }, 1000);
  }

  /**
   * 暂停计时器
   */
  static async pause(): Promise<void> {
    if (!TimerService.viewModel.isRunning || TimerService.viewModel.isPaused) {
      Logger.warn('Timer is not running or already paused');
      return;
    }

    try {
      TimerService.viewModel.pause();
      TimerService.stopTimerInternal();
      TimerService.stopAutoSave();
      await TimerService.saveState();

      TimerService.notifyTimerStateChange();
      Logger.info('Timer paused');
    } catch (error) {
      Logger.error('Failed to pause timer', error as Error);
    }
  }

  /**
   * 恢复计时器
   */
  static async resume(): Promise<void> {
    if (!TimerService.viewModel.isPaused) {
      Logger.warn('Timer is not paused');
      return;
    }

    try {
      TimerService.viewModel.resume();
      TimerService.startTimerInternal();
      TimerService.startAutoSave();
      await TimerService.saveState();

      TimerService.notifyTimerStateChange();
      Logger.info('Timer resumed');
    } catch (error) {
      Logger.error('Failed to resume timer', error as Error);
    }
  }

  /**
   * 停止计时器
   */
  static async stop(): Promise<void> {
    if (!TimerService.viewModel.isRunning) {
      Logger.warn('Timer is not running');
      return;
    }

    try {
      TimerService.viewModel.stop();
      TimerService.stopTimerInternal();
      TimerService.stopAutoSave();

      // 重置时间
      TimerService.viewModel.remainingSeconds = TimerService.viewModel.totalSeconds;
      await TimerService.saveState();

      TimerService.notifyTimerStateChange();
      Logger.info('Timer stopped');
    } catch (error) {
      Logger.error('Failed to stop timer', error as Error);
    }
  }

  /**
   * 内部停止计时器
   */
  private static stopTimerInternal(): void {
    if (TimerService.timerId !== -1) {
      clearInterval(TimerService.timerId);
      TimerService.timerId = -1;
    }
  }

  /**
   * 重置计时器
   */
  static async reset(): Promise<void> {
    try {
      TimerService.viewModel.stop();
      TimerService.stopTimerInternal();
      TimerService.stopAutoSave();

      TimerService.viewModel.remainingSeconds = TimerService.viewModel.totalSeconds;
      await TimerService.saveState();

      TimerService.notifyTimerStateChange();
      Logger.info('Timer reset');
    } catch (error) {
      Logger.error('Failed to reset timer', error as Error);
    }
  }

  /**
   * 计时器完成处理
   */
  private static async onTimerComplete(): Promise<void> {
    try {
      TimerService.stopTimerInternal();
      TimerService.stopAutoSave();

      const mode = TimerService.viewModel.mode;
      const taskId = TimerService.viewModel.taskId;

      // 更新任务完成数
      if (mode === TimerMode.WORKING && taskId > 0) {
        await TaskService.completeTomato(taskId);
      }

      // 播放提示
      TimerService.showCompletionToast(mode);

      // 触发完成回调
      TimerService.notifyTimerComplete();

      // 重置状态
      TimerService.viewModel.isRunning = false;
      TimerService.viewModel.isPaused = false;
      TimerService.viewModel.remainingSeconds = TimerService.viewModel.totalSeconds;
      await TimerService.saveState();

      TimerService.notifyTimerStateChange();

      Logger.info(`Timer completed: ${mode}`);
    } catch (error) {
      Logger.error('Failed to handle timer complete', error as Error);
    }
  }

  /**
   * 显示完成提示
   */
  private static showCompletionToast(mode: TimerMode): void {
    if (mode === TimerMode.WORKING) {
      ToastUtil.showSuccess('专注时间结束，休息一下吧！');
    } else {
      ToastUtil.showToast('休息时间结束，准备开始专注！');
    }
  }

  // ==================== 模式切换 ====================

  /**
   * 切换到专注模式
   * @param minutes 番茄时长，可选
   */
  static async switchToWorking(minutes?: number): Promise<void> {
    try {
      // 先停止当前计时器
      if (TimerService.viewModel.isRunning) {
        await TimerService.stop();
      }

      TimerService.viewModel.mode = TimerMode.WORKING;
      if (minutes !== undefined) {
        TimerService.setDuration(minutes);
      } else {
        TimerService.viewModel.setDuration(TaskConstant.DEFAULT_TOMATO_MINUTES);
      }

      await TimerService.saveState();
      Logger.info('Switched to working mode');
    } catch (error) {
      Logger.error('Failed to switch to working mode', error as Error);
    }
  }

  /**
   * 切换到休息模式
   * @param minutes 休息时长，可选
   */
  static async switchToResting(minutes?: number): Promise<void> {
    try {
      // 先停止当前计时器
      if (TimerService.viewModel.isRunning) {
        await TimerService.stop();
      }

      TimerService.viewModel.mode = TimerMode.RESTING;
      if (minutes !== undefined) {
        TimerService.setDuration(minutes);
      } else {
        TimerService.viewModel.setDuration(TaskConstant.DEFAULT_REST_MINUTES);
      }

      await TimerService.saveState();
      Logger.info('Switched to resting mode');
    } catch (error) {
      Logger.error('Failed to switch to resting mode', error as Error);
    }
  }

  /**
   * 设置计时器时长
   * @param minutes 时长（分钟）
   */
  static async setDuration(minutes: number): Promise<void> {
    try {
      TimerService.viewModel.setDuration(minutes);
      await TimerService.saveState();
      Logger.info(`Timer duration set to ${minutes} minutes`);
    } catch (error) {
      Logger.error('Failed to set timer duration', error as Error);
    }
  }

  /**
   * 设置关联任务
   * @param taskId 任务ID
   */
  static async setTask(taskId: number): Promise<void> {
    try {
      TimerService.viewModel.taskId = taskId;
      await TimerService.saveState();
      Logger.info(`Timer task set to: ${taskId}`);
    } catch (error) {
      Logger.error('Failed to set timer task', error as Error);
    }
  }

  /**
   * 清除关联任务
   */
  static async clearTask(): Promise<void> {
    try {
      TimerService.viewModel.taskId = 0;
      await TimerService.saveState();
      Logger.info('Timer task cleared');
    } catch (error) {
      Logger.error('Failed to clear timer task', error as Error);
    }
  }
}
