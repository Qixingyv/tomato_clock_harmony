import { Logger } from '../Logger';
import { TaskMode } from '../../viewmodel/TaskMode';
import { TaskConstant } from '../constants/TaskConstant';

/**
 * 验证结果类
 * 包含验证状态和错误信息列表
 */
export class ValidationResult {
  valid: boolean;
  errors: string[];

  constructor(valid: boolean, errors: string[] = []) {
    this.valid = valid;
    this.errors = errors;
  }

  /**
   * 创建成功结果
   */
  static success(): ValidationResult {
    return new ValidationResult(true, []);
  }

  /**
   * 创建失败结果
   */
  static fail(errors: string[]): ValidationResult {
    return new ValidationResult(false, errors);
  }

  /**
   * 添加错误信息
   */
  addError(error: string): void {
    this.valid = false;
    this.errors.push(error);
  }

  /**
   * 合并另一个验证结果
   */
  merge(other: ValidationResult): void {
    if (!other.valid) {
      this.valid = false;
      this.errors.push(...other.errors);
    }
  }
}

/**
 * 任务验证器
 * 提供任务相关的数据验证功能
 */
export class TaskValidator {

  private constructor() {} // 防止实例化

  // ==================== 通用验证 ====================

  /**
   * 验证任务名称
   * @param name 任务名称
   */
  static validateName(name: string): ValidationResult {
    const errors: string[] = [];

    if (!name || name.trim().length === 0) {
      errors.push('任务名称不能为空');
    } else if (name.length > 50) {
      errors.push('任务名称不能超过50个字符');
    }

    return errors.length > 0 ? ValidationResult.fail(errors) : ValidationResult.success();
  }

  /**
   * 验证番茄时长
   * @param minutes 番茄时长（分钟）
   */
  static validateTomatoMinutes(minutes: number): ValidationResult {
    const errors: string[] = [];

    if (isNaN(minutes)) {
      errors.push('番茄时长必须是数字');
    } else if (minutes < 1) {
      errors.push('番茄时长不能小于1分钟');
    } else if (minutes > 120) {
      errors.push('番茄时长不能超过120分钟');
    }

    return errors.length > 0 ? ValidationResult.fail(errors) : ValidationResult.success();
  }

  /**
   * 验证休息时长
   * @param minutes 休息时长（分钟）
   */
  static validateRestMinutes(minutes: number): ValidationResult {
    const errors: string[] = [];

    if (isNaN(minutes)) {
      errors.push('休息时长必须是数字');
    } else if (minutes < 1) {
      errors.push('休息时长不能小于1分钟');
    } else if (minutes > 60) {
      errors.push('休息时长不能超过60分钟');
    }

    return errors.length > 0 ? ValidationResult.fail(errors) : ValidationResult.success();
  }

  /**
   * 验证任务模式
   * @param mode 任务模式
   */
  static validateMode(mode: number): ValidationResult {
    const errors: string[] = [];

    if (mode !== TaskMode.TODO && mode !== TaskMode.PLAN) {
      errors.push('任务模式必须是待办模式(1)或计划模式(2)');
    }

    return errors.length > 0 ? ValidationResult.fail(errors) : ValidationResult.success();
  }

  // ==================== 待办模式验证 ====================

  /**
   * 验证待办模式的目标番茄数
   * @param count 目标番茄数
   */
  static validateTargetTomatoCount(count: number | null): ValidationResult {
    const errors: string[] = [];

    if (count === null || count === undefined) {
      errors.push('待办模式必须设置目标番茄数');
    } else if (isNaN(count)) {
      errors.push('目标番茄数必须是数字');
    } else if (count < 1) {
      errors.push('目标番茄数不能小于1');
    } else if (count > 100) {
      errors.push('目标番茄数不能超过100');
    }

    return errors.length > 0 ? ValidationResult.fail(errors) : ValidationResult.success();
  }

  // ==================== 计划模式验证 ====================

  /**
   * 验证计划模式的每日目标番茄数
   * @param count 每日目标番茄数
   */
  static validateDailyTargetTomatoCount(count: number | null): ValidationResult {
    const errors: string[] = [];

    if (count === null || count === undefined) {
      errors.push('计划模式必须设置每日目标番茄数');
    } else if (isNaN(count)) {
      errors.push('每日目标番茄数必须是数字');
    } else if (count < 1) {
      errors.push('每日目标番茄数不能小于1');
    } else if (count > 50) {
      errors.push('每日目标番茄数不能超过50');
    }

    return errors.length > 0 ? ValidationResult.fail(errors) : ValidationResult.success();
  }

  /**
   * 验证截止日期
   * @param deadline 截止日期
   */
  static validateDeadline(deadline: Date | null): ValidationResult {
    const errors: string[] = [];

    if (deadline === null || deadline === undefined) {
      errors.push('计划模式必须设置截止日期');
      return ValidationResult.fail(errors);
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const deadlineDay = new Date(deadline);
    deadlineDay.setHours(0, 0, 0, 0);

    if (deadlineDay.getTime() < today.getTime()) {
      errors.push('截止日期不能是过去的日期');
    }

    // 检查截止日期是否过远（不超过1年）
    const maxDate = new Date();
    maxDate.setFullYear(maxDate.getFullYear() + 1);
    if (deadlineDay.getTime() > maxDate.getTime()) {
      errors.push('截止日期不能超过1年');
    }

    return errors.length > 0 ? ValidationResult.fail(errors) : ValidationResult.success();
  }

  // ==================== 综合验证 ====================

  /**
   * 验证任务创建参数（待办模式）
   * @param name 任务名称
   * @param tomatoMinutes 番茄时长
   * @param restMinutes 休息时长
   * @param targetTomatoCount 目标番茄数
   */
  static validateTodoTaskCreation(
    name: string,
    tomatoMinutes: number,
    restMinutes: number,
    targetTomatoCount: number | null
  ): ValidationResult {
    const result = ValidationResult.success();

    result.merge(TaskValidator.validateName(name));
    result.merge(TaskValidator.validateTomatoMinutes(tomatoMinutes));
    result.merge(TaskValidator.validateRestMinutes(restMinutes));
    result.merge(TaskValidator.validateTargetTomatoCount(targetTomatoCount));

    return result;
  }

  /**
   * 验证任务创建参数（计划模式）
   * @param name 任务名称
   * @param tomatoMinutes 番茄时长
   * @param restMinutes 休息时长
   * @param dailyTargetTomatoCount 每日目标番茄数
   * @param deadline 截止日期
   */
  static validatePlanTaskCreation(
    name: string,
    tomatoMinutes: number,
    restMinutes: number,
    dailyTargetTomatoCount: number | null,
    deadline: Date | null
  ): ValidationResult {
    const result = ValidationResult.success();

    result.merge(TaskValidator.validateName(name));
    result.merge(TaskValidator.validateTomatoMinutes(tomatoMinutes));
    result.merge(TaskValidator.validateRestMinutes(restMinutes));
    result.merge(TaskValidator.validateDailyTargetTomatoCount(dailyTargetTomatoCount));
    result.merge(TaskValidator.validateDeadline(deadline));

    return result;
  }

  /**
   * 验证任务创建参数（通用）
   * @param name 任务名称
   * @param mode 任务模式
   * @param tomatoMinutes 番茄时长
   * @param restMinutes 休息时长
   * @param targetTomatoCount 目标番茄数（待办模式）
   * @param dailyTargetTomatoCount 每日目标番茄数（计划模式）
   * @param deadline 截止日期（计划模式）
   */
  static validateTaskCreation(
    name: string,
    mode: number,
    tomatoMinutes: number,
    restMinutes: number,
    targetTomatoCount: number | null,
    dailyTargetTomatoCount: number | null,
    deadline: Date | null
  ): ValidationResult {
    const result = ValidationResult.success();

    // 通用验证
    result.merge(TaskValidator.validateName(name));
    result.merge(TaskValidator.validateMode(mode));
    result.merge(TaskValidator.validateTomatoMinutes(tomatoMinutes));
    result.merge(TaskValidator.validateRestMinutes(restMinutes));

    // 模式特定验证
    if (mode === TaskMode.TODO) {
      result.merge(TaskValidator.validateTargetTomatoCount(targetTomatoCount));
    } else if (mode === TaskMode.PLAN) {
      result.merge(TaskValidator.validateDailyTargetTomatoCount(dailyTargetTomatoCount));
      result.merge(TaskValidator.validateDeadline(deadline));
    }

    return result;
  }

  /**
   * 验证任务更新参数
   * @param taskName 任务名称
   */
  static validateTaskUpdate(taskName: string): ValidationResult {
    return TaskValidator.validateName(taskName);
  }

  /**
   * 验证完成番茄数
   * @param completed 已完成番茄数
   * @param target 目标番茄数
   */
  static validateCompletedTomato(completed: number, target: number): ValidationResult {
    const errors: string[] = [];

    if (isNaN(completed)) {
      errors.push('已完成番茄数必须是数字');
    } else if (completed < 0) {
      errors.push('已完成番茄数不能为负数');
    } else if (completed > target) {
      errors.push('已完成番茄数不能超过目标数');
    }

    return errors.length > 0 ? ValidationResult.fail(errors) : ValidationResult.success();
  }
}
