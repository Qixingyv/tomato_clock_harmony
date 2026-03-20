import { Logger } from '../common/Logger';
import { ToastUtil } from '../common/ToastUtil';
import { DateUtils } from '../common/DateUtils';
import { StorageService } from './StorageService';
import { TaskValidator, ValidationResult } from '../common/validator/TaskValidator';
import { ToDoListClass } from '../viewmodel/ToDoListClass';
import { TaskMode } from '../viewmodel/TaskMode';
import { TaskStatus } from '../viewmodel/TaskStatus';
import { AuthService } from './AuthService';
import { TaskConstant } from '../common/constants/TaskConstant';

/**
 * 任务更新选项接口
 */
interface TaskUpdateOptions {
  name?: string;
  tomatoMinutes?: number;
  restMinutes?: number;
  targetTomatoCount?: number;
  dailyTargetTomatoCount?: number;
  deadline?: Date;
}

/**
 * 任务服务类
 * 管理任务的CRUD操作和业务逻辑
 */
export class TaskService {
  private static tasks: ToDoListClass[] = [];
  private static taskIdCounter: number = 1;
  private static initialized: boolean = false;
  private static taskChangeCallback: (() => void) | null = null;

  private constructor() {} // 防止实例化

  /**
   * 初始化任务服务
   * 从本地存储恢复任务数据
   */
  static async init(): Promise<void> {
    if (TaskService.initialized) {
      Logger.warn('TaskService already initialized');
      return;
    }

    try {
      // 加载任务列表
      const loadedTasks = await StorageService.loadTasks();
      TaskService.tasks = loadedTasks;

      // 加载ID计数器
      TaskService.taskIdCounter = await StorageService.getTaskIdCounter();

      // 检查并重置今日计数
      TaskService.checkTodayReset();

      TaskService.initialized = true;
      Logger.info(`TaskService initialized with ${TaskService.tasks.length} tasks`);
    } catch (error) {
      Logger.error('Failed to initialize TaskService', error as Error);
      TaskService.tasks = [];
      TaskService.taskIdCounter = 1;
      TaskService.initialized = true;
    }
  }

  /**
   * 设置任务变化回调
   * @param callback 任务变化时的回调函数
   */
  static setTaskChangeListener(callback: () => void): void {
    TaskService.taskChangeCallback = callback;
  }

  /**
   * 移除任务变化回调
   */
  static removeTaskChangeListener(): void {
    TaskService.taskChangeCallback = null;
  }

  /**
   * 触发任务变化回调
   */
  private static notifyTaskChange(): void {
    if (TaskService.taskChangeCallback) {
      TaskService.taskChangeCallback();
    }
  }

  /**
   * 保存任务列表到本地存储
   */
  private static async saveTasks(): Promise<void> {
    try {
      await StorageService.saveTasks(TaskService.tasks);
      await StorageService.saveTaskIdCounter(TaskService.taskIdCounter);
    } catch (error) {
      Logger.error('Failed to save tasks', error as Error);
    }
  }

  /**
   * 检查并重置今日计数
   * 如果今天是新的一天，重置所有计划任务的今日计数
   */
  static checkTodayReset(): void {
    const today = DateUtils.getToday();
    let needsSave = false;

    for (const task of TaskService.tasks) {
      if (task.getMode === TaskMode.PLAN) {
        const lastReset = task.getLastResetDate;
        if (!lastReset || !DateUtils.isSameDay(lastReset, today)) {
          task.resetTodayCount();
          needsSave = true;
          Logger.debug(`Reset today count for task: ${task.getName}`);
        }
      }
    }

    if (needsSave) {
      TaskService.saveTasks();
    }
  }

  // ==================== CRUD操作 ====================

  /**
   * 创建新任务
   * @param name 任务名称
   * @param mode 任务模式（1=待办，2=计划）
   * @param tomatoMinutes 番茄时长
   * @param restMinutes 休息时长
   * @param targetTomatoCount 目标番茄数（待办模式）
   * @param dailyTargetTomatoCount 每日目标番茄数（计划模式）
   * @param deadline 截止日期（计划模式）
   * @returns 创建的任务对象，失败返回null
   */
  static async createTask(
    name: string,
    mode: number,
    tomatoMinutes: number = TaskConstant.DEFAULT_TOMATO_MINUTES,
    restMinutes: number = TaskConstant.DEFAULT_REST_MINUTES,
    targetTomatoCount: number | null = null,
    dailyTargetTomatoCount: number | null = null,
    deadline: Date | null = null
  ): Promise<ToDoListClass | null> {
    // 验证参数
    const validation = TaskValidator.validateTaskCreation(
      name,
      mode,
      tomatoMinutes,
      restMinutes,
      targetTomatoCount,
      dailyTargetTomatoCount,
      deadline
    );

    if (!validation.valid) {
      const errorMsg = validation.errors.join('; ');
      Logger.error(`Task validation failed: ${errorMsg}`);
      ToastUtil.showError(errorMsg);
      return null;
    }

    try {
      // 获取当前用户ID
      const user = AuthService.getCurrentUser();
      const userId = user ? user.id : 0;

      // 创建任务
      const task = new ToDoListClass(
        TaskService.taskIdCounter++,
        userId,
        name.trim(),
        mode,
        tomatoMinutes,
        restMinutes,
        targetTomatoCount,
        dailyTargetTomatoCount,
        0, // finished_tomato_count
        0, // today_finished_count
        deadline,
        mode === TaskMode.PLAN ? DateUtils.getToday() : null, // last_reset_date
        TaskStatus.WORKING // status
      );

      TaskService.tasks.push(task);
      await TaskService.saveTasks();

      TaskService.notifyTaskChange();
      ToastUtil.showSuccess('任务创建成功');
      Logger.info(`Task created: ${name} (ID: ${task.getId})`);

      return task;
    } catch (error) {
      Logger.error('Failed to create task', error as Error);
      ToastUtil.showError('任务创建失败');
      return null;
    }
  }

  /**
   * 更新任务
   * @param taskId 任务ID
   * @param updates 要更新的字段
   */
  static async updateTask(
    taskId: number,
    updates: TaskUpdateOptions
  ): Promise<boolean> {
    const task = TaskService.tasks.find(t => t.getId === taskId);
    if (!task) {
      Logger.warn(`Task not found: ${taskId}`);
      ToastUtil.showError('任务不存在');
      return false;
    }

    try {
      // 应用更新并进行验证
      if (updates.name !== undefined) {
        const validation = TaskValidator.validateName(updates.name);
        if (!validation.valid) {
          ToastUtil.showError(validation.errors[0]);
          return false;
        }
        task.setName(updates.name);
      }

      if (updates.tomatoMinutes !== undefined) {
        const validation = TaskValidator.validateTomatoMinutes(updates.tomatoMinutes);
        if (!validation.valid) {
          ToastUtil.showError(validation.errors[0]);
          return false;
        }
        task.setTomatoMinutes(updates.tomatoMinutes);
      }

      if (updates.restMinutes !== undefined) {
        const validation = TaskValidator.validateRestMinutes(updates.restMinutes);
        if (!validation.valid) {
          ToastUtil.showError(validation.errors[0]);
          return false;
        }
        task.setRestMinutes(updates.restMinutes);
      }

      if (updates.targetTomatoCount !== undefined && task.getMode === TaskMode.TODO) {
        const validation = TaskValidator.validateTargetTomatoCount(updates.targetTomatoCount);
        if (!validation.valid) {
          ToastUtil.showError(validation.errors[0]);
          return false;
        }
        task.setTargetTomatoCount(updates.targetTomatoCount);
      }

      if (updates.dailyTargetTomatoCount !== undefined && task.getMode === TaskMode.PLAN) {
        const validation = TaskValidator.validateDailyTargetTomatoCount(updates.dailyTargetTomatoCount);
        if (!validation.valid) {
          ToastUtil.showError(validation.errors[0]);
          return false;
        }
        task.setDailyTargetTomatoCount(updates.dailyTargetTomatoCount);
      }

      if (updates.deadline !== undefined && task.getMode === TaskMode.PLAN) {
        const validation = TaskValidator.validateDeadline(updates.deadline);
        if (!validation.valid) {
          ToastUtil.showError(validation.errors[0]);
          return false;
        }
        task.setDeadline(updates.deadline);
      }

      await TaskService.saveTasks();
      TaskService.notifyTaskChange();

      Logger.info(`Task updated: ${taskId}`);
      return true;
    } catch (error) {
      Logger.error('Failed to update task', error as Error);
      ToastUtil.showError('任务更新失败');
      return false;
    }
  }

  /**
   * 删除任务
   * @param taskId 任务ID
   */
  static async deleteTask(taskId: number): Promise<boolean> {
    const index = TaskService.tasks.findIndex(t => t.getId === taskId);
    if (index === -1) {
      Logger.warn(`Task not found: ${taskId}`);
      ToastUtil.showError('任务不存在');
      return false;
    }

    try {
      TaskService.tasks.splice(index, 1);
      await TaskService.saveTasks();

      TaskService.notifyTaskChange();
      ToastUtil.showSuccess('任务已删除');
      Logger.info(`Task deleted: ${taskId}`);

      return true;
    } catch (error) {
      Logger.error('Failed to delete task', error as Error);
      ToastUtil.showError('任务删除失败');
      return false;
    }
  }

  /**
   * 获取所有任务
   */
  static getAllTasks(): ToDoListClass[] {
    return [...TaskService.tasks];
  }

  /**
   * 根据ID获取任务
   * @param taskId 任务ID
   */
  static getTaskById(taskId: number): ToDoListClass | null {
    return TaskService.tasks.find(t => t.getId === taskId) || null;
  }

  /**
   * 根据状态获取任务
   * @param status 任务状态
   */
  static getTasksByStatus(status: TaskStatus): ToDoListClass[] {
    return TaskService.tasks.filter(t => t.getStatus === status);
  }

  /**
   * 根据模式获取任务
   * @param mode 任务模式
   */
  static getTasksByMode(mode: TaskMode): ToDoListClass[] {
    return TaskService.tasks.filter(t => t.getMode === mode);
  }

  /**
   * 获取进行中的任务
   */
  static getActiveTasks(): ToDoListClass[] {
    return TaskService.tasks.filter(t => t.getStatus === TaskStatus.WORKING);
  }

  /**
   * 获取已完成的任务
   */
  static getCompletedTasks(): ToDoListClass[] {
    return TaskService.tasks.filter(t => t.getStatus === TaskStatus.COMPLETED);
  }

  // ==================== 任务状态操作 ====================

  /**
   * 完成一个番茄钟
   * @param taskId 任务ID
   */
  static async completeTomato(taskId: number): Promise<boolean> {
    const task = TaskService.tasks.find(t => t.getId === taskId);
    if (!task) {
      Logger.warn(`Task not found: ${taskId}`);
      return false;
    }

    try {
      task.incrementCompletedTomatoNum();

      // 检查是否完成整个任务
      if (task.getMode === TaskMode.TODO) {
        const target = task.getTargetTomatoCount;
        if (target && task.getFinishedTomatoCount >= target) {
          task.setStatus(TaskStatus.COMPLETED);
          ToastUtil.showSuccess('恭喜！任务已完成');
        }
      }

      await TaskService.saveTasks();
      TaskService.notifyTaskChange();

      Logger.info(`Tomato completed for task: ${task.getName}`);
      return true;
    } catch (error) {
      Logger.error('Failed to complete tomato', error as Error);
      return false;
    }
  }

  /**
   * 设置任务状态
   * @param taskId 任务ID
   * @param status 新状态
   */
  static async setTaskStatus(taskId: number, status: TaskStatus): Promise<boolean> {
    const task = TaskService.tasks.find(t => t.getId === taskId);
    if (!task) {
      Logger.warn(`Task not found: ${taskId}`);
      return false;
    }

    try {
      // 更新状态
      task.setStatus(status);

      await TaskService.saveTasks();
      TaskService.notifyTaskChange();

      Logger.info(`Task status changed: ${taskId} -> ${status}`);
      return true;
    } catch (error) {
      Logger.error('Failed to set task status', error as Error);
      return false;
    }
  }

  /**
   * 取消任务
   * @param taskId 任务ID
   */
  static async cancelTask(taskId: number): Promise<boolean> {
    return await TaskService.setTaskStatus(taskId, TaskStatus.CANCELLED);
  }

  /**
   * 检查并更新过期任务
   * 检查计划任务的截止日期，标记已过期的任务
   */
  static async checkExpiredTasks(): Promise<void> {
    const today = DateUtils.getToday();
    let needsSave = false;

    for (const task of TaskService.tasks) {
      if (task.getMode === TaskMode.PLAN && task.getStatus === TaskStatus.WORKING) {
        const deadline = task.getDeadline;
        if (deadline && deadline < today) {
          task.setStatus(TaskStatus.EXPIRED);
          needsSave = true;
          Logger.info(`Task expired: ${task.getName}`);
        }
      }
    }

    if (needsSave) {
      await TaskService.saveTasks();
      TaskService.notifyTaskChange();
    }
  }

  // ==================== 统计相关 ====================

  /**
   * 获取任务总数
   */
  static getTaskCount(): number {
    return TaskService.tasks.length;
  }

  /**
   * 获取进行中任务数
   */
  static getActiveTaskCount(): number {
    return TaskService.tasks.filter(t => t.getStatus === TaskStatus.WORKING).length;
  }

  /**
   * 获取已完成任务数
   */
  static getCompletedTaskCount(): number {
    return TaskService.tasks.filter(t => t.getStatus === TaskStatus.COMPLETED).length;
  }

  /**
   * 获取今日已完成番茄总数
   */
  static getTodayCompletedTomatoes(): number {
    let total = 0;
    for (const task of TaskService.tasks) {
      if (task.getMode === TaskMode.PLAN) {
        total += task.getTodayFinishedCount;
      }
    }
    return total;
  }

  /**
   * 获取所有已完成番茄总数（历史累计）
   */
  static getTotalCompletedTomatoes(): number {
    let total = 0;
    for (const task of TaskService.tasks) {
      total += task.getFinishedTomatoCount;
    }
    return total;
  }
}
